# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/application")

namespace :redmine do

  task :copy_time_clock => :environment do
    KpiCalcPeriod.active_opened.order("date").each do |p|

      p.kpi_period_users.includes(:user).each do |pu|
        user_month_value = ImUserMonthValue.where(:user_guid => pu.user.ldap_guid, :user_login => pu.user.login, :date => p.date)
        if user_month_value.any?
        pu.hours = user_month_value.first.time_clock
        pu.save 
        puts "Time clocks has been copied. User - #{pu.user.login}. Hours - #{pu.time_clock}. Month - #{p.date}"
        end
      end
    end
  end

  task :copy_calc_periods => :environment do

    if ENV['source_date'].nil?
      target_date = Date.today
    else
      target_date = Date.today+1.months
    end
    puts "Copy Calc Period task is executing. Target date is #{target_date}"
    puts "-----------------------------------" 

    KpiCalcPeriod.joins("LEFT JOIN #{KpiCalcPeriod.table_name} AS p ON p.parent_id=#{KpiCalcPeriod.table_name}.id AND p.date = #{target_date.at_beginning_of_month} 
                         INNER JOIN #{KpiPattern.table_name} ON #{KpiPattern.table_name}.id = #{KpiCalcPeriod.table_name}.kpi_pattern_id ")
                 .where("#{KpiCalcPeriod.table_name}.date = ? AND p.id IS NULL AND #{KpiCalcPeriod.table_name}.active = ?", 
                         target_date.at_beginning_of_month-1.months,
                         true)
                 .each do |original_period|
      #puts "Original period date - #{original_period.date}"
      period = KpiCalcPeriod.new

      period.kpi_pattern_id = original_period.kpi_pattern_id
      period.date = original_period.date+1.months
      period.parent_id = original_period.id
      period.base_salary_pattern = original_period.base_salary_pattern
      period.exclude_time_ratio = original_period.exclude_time_ratio
      period.kpi_imported_value_id = original_period.kpi_imported_value_id
      period.base_salary = original_period.base_salary
      period.user_id = original_period.user_id
      period.who_can_disable_mark = original_period.who_can_disable_mark
      period.allowed_change_salary = original_period.allowed_change_salary


      if period.save
        puts "New period has been saved #{period.date}"
        original_period.kpi_period_surcharges.each do |s|
            attributes = s.attributes.dup.except('id', 'created_at', 'updated_at', 'kpi_calc_period_id')
            attributes['kpi_calc_period_id'] = period.id
            surcharge = KpiPeriodSurcharge.new(attributes)
            surcharge.save
          end

        period.copy_from_pattern
        new_period_indicators = period.kpi_period_indicators
        original_period.kpi_indicator_inspectors.joins(:user)
                                                .select("#{KpiIndicatorInspector.table_name}.*, #{KpiPeriodIndicator.table_name}.indicator_id AS 'indicator_id' ")
                                                .where("#{KpiPeriodIndicator.table_name}.indicator_id IN (?) AND #{User.table_name}.status=?", new_period_indicators.map{|i| i.indicator_id}, User::STATUS_ACTIVE).each do |inspector|
          
          attributes = inspector.attributes.dup.except('id', 'created_at', 'updated_at', "kpi_period_indicator_id", "indicator_id")
          puts "kpi_indicator_inspector id - #{inspector.id}"

          #attributes["kpi_period_indicator_id"] = new_period_indicators.inject(nil){|v, e| e.id if e.indicator_id == inspector.attributes['indicator_id']}
          #new_period_indicators.inject(nil){|v, e| puts "#{e.indicator_id.inspect} == #{inspector.attributes['indicator_id'].inspect}"}
          attributes["kpi_period_indicator_id"] = new_period_indicators.find{|v| v.indicator_id == inspector.attributes['indicator_id']}.id
          puts attributes.inspect
          new_inspector = KpiIndicatorInspector.new(attributes)
          new_inspector.save
        end
      end
    end

  
    if Setting.plugin_kpi['auto_activating_date'].to_s == Date.today.day.to_s
      puts "Activate Calc Periods task is executing" 
      puts "---------------------------------------" 
      KpiCalcPeriod.where("date = ? AND parent_id IS NOT NULL AND active = ?", Date.today.at_beginning_of_month, false).each do |period|
        if period.for_activating?
          puts "Period with id #{period.id} has been activated" if period.activate
        else
          puts "Period with id #{period.id} is not integral" 
        end
      end
    end

  end

  task :make_kpi_mark_plan_calc => :environment do
    if ENV['UNLOCKED_MARKS'].nil? 
      KpiCalcPeriod.novel.each do |p|
        puts "------------------------------"
        date = "#{p.date.month}.#{p.date.year}"
        puts "Period date is - #{date} Period id is - #{p.id} "
        p.kpi_period_indicators.where("#{KpiPeriodIndicator.table_name}.pattern_plan IS NOT NULL").each do |i|
          puts "Period id is - #{i.id}. Period pattern_plan is - #{i.pattern_plan.to_s}. Period pattern name is #{Indicator::PLAN_PATTERNS[i.pattern_plan.to_s]}"

          case Indicator::PLAN_PATTERNS[i.pattern_plan.to_s]
          when "import_from_other_system"
              puts "Pattern is 'import_from_other_system'"
              imported_value = KpiImportedMonthValue.joins(:kpi_imported_value).where("#{KpiImportedValue.table_name}.id=? AND #{KpiImportedMonthValue.table_name}.date=?", i.pattern_plan_settings['imported_value_id'], p.date).first
              if ! imported_value.nil? && ! imported_value.plan_value.nil?
                i.plan_value = (imported_value.plan_value.to_f * i.pattern_plan_settings['imported_value_percent'].to_f) / 100
                i.save 
              end
          end
          end
      end
    else
      puts "Updating unlocked marks"
      KpiMark.not_locked.select("#{KpiMark.table_name}.*,
                                 #{KpiPeriodIndicator.table_name}.pattern_plan AS pattern_plan,
                                 #{KpiPeriodIndicator.table_name}.pattern_plan_settings AS pattern_plan_settings,
                                 #{KpiCalcPeriod.table_name}.date AS period_date")
                        .joins(:kpi_period_indicator => :kpi_calc_period).where("pattern_plan IS NOT NULL AND #{KpiCalcPeriod.table_name}.locked=?", false).each do |mark|
          puts "------------------------------"
          puts "Mark period - #{mark.start_date} - #{mark.end_date}"
          case Indicator::PLAN_PATTERNS[mark.attributes['pattern_plan'].to_s]
          when "import_from_other_system"
              puts "Pattern is 'import_from_other_system'"
              pattern_plan_settings = YAML.load(mark.attributes['pattern_plan_settings'])
              imported_value = KpiImportedMonthValue.joins(:kpi_imported_value).where("#{KpiImportedValue.table_name}.id=? AND #{KpiImportedMonthValue.table_name}.date=?", pattern_plan_settings['imported_value_id'], mark.attributes['period_date']).first

              if ! imported_value.nil? && ! imported_value.plan_value.nil?
                puts "Mark ID is  #{mark.id}. user_id id #{mark.user_id}"

                mark.plan_value = (imported_value.plan_value.to_f * pattern_plan_settings['imported_value_percent'].to_f) / 100
                mark.save 
              end
          end    
      end
    end
  end

  task :make_kpi_mark_fact_calc => :environment do
    KpiCalcPeriod.active_opened.each do |p|
      puts "------------------------------"
      date = "#{p.date.month}.#{p.date.year}"
      puts "Period date is - #{date}. Period id is - #{p.id}"
      users = p.users.includes(:memberships)

      p.kpi_period_indicators.where("#{KpiPeriodIndicator.table_name}.pattern IS NOT NULL").each do |i|
          kpi_marks = i.kpi_marks

          case Indicator::FACT_PATTERNS[i.pattern.to_s]
          when "avg_from_unders"
            puts "Pattern is 'avg_from_unders'"
            kpi_marks.each{|m|
              puts "User name #{m.user.name}"
              # m.fact_value = KpiMark.joins(:kpi_period_indicator)
                                    # .where("#{KpiMark.table_name}.user_id IN (?) 
                                            # AND #{KpiPeriodIndicator.table_name}.indicator_id =? ", m.user.unders, i.pattern_settings['indicator_id'])
              KpiMark.joins(:kpi_period_indicator).select("AVG(#{KpiMark.table_name}.fact_value) AS 'fact',
                                                                          GROUP_CONCAT(CONCAT(#{KpiMark.table_name}.user_id, '&', #{KpiMark.table_name}.start_date, '&', #{KpiMark.table_name}.end_date, '&', #{KpiMark.table_name}.fact_value, '&', 'true') ORDER BY #{User.table_name}.lastname SEPARATOR '|') AS 'involved_marks'")
                                                  .joins(:kpi_period_indicator, :user)
                                                  .where("#{KpiMark.table_name}.user_id IN (?) 
                                                  AND #{KpiMark.table_name}.disabled = ?
                                                  AND #{KpiPeriodIndicator.table_name}.indicator_id =? 
                                                  AND #{KpiMark.table_name}.start_date BETWEEN ? AND ?", 
                                                  m.user.unders, 
                                                  false,
                                                  i.pattern_settings['indicator_id'], 
                                                  m.start_date,
                                                  m.end_date
                                                  ).each do |f|

                  description = {}
                  k = 0 
                  f.involved_marks.to_s.split("|").each do |e|
                    data = e.split('&') 
                               
                    if data[4] == 'true'
                      description[k] = {}
                      description[k]['user_id'] = data[0]
                      description[k]['start_date'] = data[1]
                      description[k]['end_date'] = data[2]
                      description[k]['fact_value'] = data[3]
                    end
                    k+=1
                  end

                  puts "Average value is - #{f.fact}"
                  puts "Average value is - #{description.inspect}"

                  m.fact_date = Time.now
                  m.fact_value = f.fact              
                  m.issues = description
                  m.save unless m.fact_value.nil?
                  
                end
              }
          when "import_from_other_system"
            puts "Pattern is 'import_from_other_system'"
            kpi_marks.each{|m|
              m.fact_value=KpiImportedMonthValue.joins(:kpi_imported_value).where("#{KpiImportedValue.table_name}.id=? AND #{KpiImportedMonthValue.table_name}.date=?", i.pattern_settings['imported_value_id'], p.date).first.try(:fact_value)
              m.fact_date = Time.now
              m.save unless m.fact_value.nil?
            }
          when "avg_custom_field_mark_in_current_period"
            puts "Pattern is 'avg_custom_field_mark_in_current_period'"
            Issue.joins(:custom_values, {:fixed_version => :milestones})
                 .select("AVG(#{CustomValue.table_name}.value) AS 'fact',
                        GROUP_CONCAT(CONCAT(#{Issue.table_name}.id, '&', #{CustomValue.table_name}.value, '&', 'true') ORDER BY #{Issue.table_name}.id SEPARATOR '|') AS 'involved_issues',
                         #{Setting.plugin_kpi['executor_id_issue_field']} AS 'executor_id'")
                 .where("#{Setting.plugin_kpi['executor_id_issue_field']} IN (?) 
                        AND custom_field_id=? 
                        AND DATE_FORMAT(#{Milestone.table_name}.effective_date, '%c.%Y')=?
                        AND (#{CustomValue.table_name}.value!='' AND #{CustomValue.table_name}.value IS NOT NULL) ", users, i.pattern_settings['mark_custom_field'], date)
                 .group("#{Setting.plugin_kpi['executor_id_issue_field']}").map do |f|

              puts "Fact is - #{f.fact}"
              puts "Executor ID is - #{f.executor_id}"
              puts "Issues - #{f.involved_issues.to_s.split("|").inspect}"

              description = {}

              f.involved_issues.to_s.split("|").each do |e|
                data = e.split('&')                
                if data[2] == 'true'
                  description[data[0]] = data[1]
                end
              end

              mark = kpi_marks.where("#{KpiMark.table_name}.user_id = ? ", f.executor_id).first
              mark.fact_value = f.fact
              mark.issues = description
              mark.fact_date = Time.now
              mark.save
            end

          when 'issue_hours_in_current_period'
            puts "Pattern is 'issue_hours_in_current_period'"

            Issue.joins(:status, {:fixed_version => :milestones})
                 .select("SUM(estimated_hours) AS 'fact',
                         GROUP_CONCAT(CONCAT(#{Issue.table_name}.id, '&', estimated_hours, '&', 'true') ORDER BY #{Issue.table_name}.id SEPARATOR '|') AS 'involved_issues',
                         #{Setting.plugin_kpi['executor_id_issue_field']} AS 'executor_id'")
                 .where("#{Setting.plugin_kpi['executor_id_issue_field']} IN (?) 
                  AND DATE_FORMAT(#{Milestone.table_name}.effective_date, '%c.%Y')=? 
                  AND #{IssueStatus.table_name}.is_closed = ?", users, date, true)
                 .group("#{Setting.plugin_kpi['executor_id_issue_field']}").map do |f|

                puts "Estimated Hours is - #{f.fact}"
                puts "Executor ID is - #{f.executor_id}"
                puts "Issues - #{f.involved_issues.to_s.split("|").inspect}"

                description = {}

                f.involved_issues.to_s.split("|").each do |e|
                  data = e.split('&')
                  if data[2] == 'true'
                    description[data[0]] = data[1]
                  end
                end

                mark = kpi_marks.where("#{KpiMark.table_name}.user_id = ? ", f.executor_id).first
                mark.fact_value = f.fact
                mark.issues = description
                mark.fact_date = Time.now
                mark.save
              end
          when 'issue_lag_in_current_period'
            puts "Pattern is 'issue_lag_in_current_period'"

            Issue.joins(:status, {:fixed_version => :milestones})
                 .select("AVG(CASE WHEN DATEDIFF(#{Setting.plugin_kpi['check_date_issue_field']}, due_date) < 0 THEN 0 ELSE DATEDIFF(#{Setting.plugin_kpi['check_date_issue_field']}, due_date) END) AS 'fact',
                          GROUP_CONCAT(CONCAT(#{Issue.table_name}.id, '&', #{Setting.plugin_kpi['check_date_issue_field']}, '&', due_date, '&', 'true') ORDER BY #{Issue.table_name}.id SEPARATOR '|') AS 'involved_issues',
                         #{Setting.plugin_kpi['executor_id_issue_field']} AS 'executor_id'")
                 .where("#{Setting.plugin_kpi['executor_id_issue_field']} IN (?) AND DATE_FORMAT(#{Milestone.table_name}.effective_date, '%c.%Y')=? AND #{IssueStatus.table_name}.is_closed = ?", users, date, true)
                 .group("#{Setting.plugin_kpi['executor_id_issue_field']}").map do |f|


                puts "Lag is - #{f.fact}"
                puts "Executor ID is - #{f.executor_id}"
                puts "Issues - #{f.involved_issues.to_s.split("|").inspect}"

                description = {}
                f.involved_issues.to_s.split("|").each do |e|
                  data = e.split('&')
                  if data[3] == 'true'
                    description[data[0]] = {}
                    description[data[0]]['check_date'] = data[1]
                    description[data[0]]['due_date'] = data[2]
                  end
                end

                mark = kpi_marks.where("#{KpiMark.table_name}.user_id = ? ", f.executor_id).first
                mark.fact_value = f.fact
                mark.issues = description
                mark.fact_date = Time.now
                mark.save
              end
          when 'self_and_executors_issues_avg_custom_field_mark'
            puts "Pattern is 'self_and_executors_issues_avg_custom_field_mark'"
            #Rails.logger.debug("sssssssssssssssssssssssssssssssssssssssssssssssssss")
            Project.joins({:all_members => [:member_roles, :user]}, {:issues => [:custom_values, {:fixed_version => :milestones}]})
                   .select("AVG(#{CustomValue.table_name}.value) AS 'fact',
                           GROUP_CONCAT(CONCAT(#{Issue.table_name}.id, '&', #{CustomValue.table_name}.value, '&', 'true') ORDER BY #{Issue.table_name}.id SEPARATOR '|') AS 'involved_issues',
                           #{User.table_name}.id AS 'user_id'")
                   .where("#{User.table_name}.type='User' 
                           AND #{User.table_name}.status=#{User::STATUS_ACTIVE} 
                           AND #{MemberRole.table_name}.role_id = ? 
                           AND #{User.table_name}.id IN (?) 
                           AND DATE_FORMAT(#{Milestone.table_name}.effective_date, '%c.%Y')=?
                           AND (#{CustomValue.table_name}.value!='' AND #{CustomValue.table_name}.value IS NOT NULL) 
                           AND custom_field_id=? ", i.pattern_settings['role'], users, date, i.pattern_settings['mark_custom_field'])
                          .group("#{User.table_name}.id")
                          .each do |f|

              puts "Fact is - #{f.fact}"
              puts "User ID is - #{f.user_id}"
              puts "Issues - #{f.involved_issues.to_s.split("|").inspect}"

              description = {}

              f.involved_issues.to_s.split("|").each do |e|
                data = e.split('&')                
                if data[2] == 'true'
                  description[data[0]] = data[1]
                end
              end


              mark = kpi_marks.where("#{KpiMark.table_name}.user_id = ? ", f.user_id).first
              mark.fact_value = f.fact
              mark.issues = description
              mark.fact_date = Time.now
              mark.save              
              end

          when 'self_and_executors_issues_lag'
            puts "Pattern is 'self_and_executors_issues_lag'"

            Project.joins({:all_members => [:member_roles, :user]}, {:issues => {:fixed_version => :milestones}})
                   .select("AVG(CASE WHEN DATEDIFF(#{Setting.plugin_kpi['check_date_issue_field']}, due_date) < 0 THEN 0 ELSE DATEDIFF(#{Setting.plugin_kpi['check_date_issue_field']}, due_date) END) AS 'fact',
                           GROUP_CONCAT(CONCAT(#{Issue.table_name}.id, '&', #{Setting.plugin_kpi['check_date_issue_field']}, '&', due_date, '&', 'true') ORDER BY #{Issue.table_name}.id SEPARATOR '|') AS 'involved_issues',
                           #{User.table_name}.id AS 'user_id'")
                   .where("#{User.table_name}.type='User' 
                           AND #{User.table_name}.status=#{User::STATUS_ACTIVE} 
                           AND #{MemberRole.table_name}.role_id = ? 
                           AND #{User.table_name}.id IN (?) 
                           AND DATE_FORMAT(#{Milestone.table_name}.effective_date, '%c.%Y')=?
                           ", i.pattern_settings['role'], users, date)
                          .group("#{User.table_name}.id")
                          .each do |f|

              puts "Fact is - #{f.fact}"
              puts "User ID is - #{f.user_id}  "
              puts "Issues - #{f.involved_issues.to_s.split("|").inspect}"

              description = {}
              f.involved_issues.to_s.split("|").each do |e|
                data = e.split('&')
                if data[3] == 'true'
                  description[data[0]] = {}
                  description[data[0]]['check_date'] = data[1]
                  description[data[0]]['due_date'] = data[2]
                end
              end

              mark = kpi_marks.where("#{KpiMark.table_name}.user_id = ? ", f.user_id).first
              mark.fact_value = f.fact
              mark.issues = description
              mark.fact_date = Time.now
              mark.save              
              end              
          end    
        end
      end
  end
end