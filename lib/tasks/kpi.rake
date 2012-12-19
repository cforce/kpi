# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/application")

namespace :redmine do

  task :copy_calc_periods => :environment do
    puts "Copy Calc Period task is executing"
    puts "-----------------------------------" 
    KpiCalcPeriod.joins("LEFT JOIN #{KpiCalcPeriod.table_name} AS p ON p.parent_id=#{KpiCalcPeriod.table_name}.id AND p.date = #{Date.today.at_beginning_of_month}")
                 .where("#{KpiCalcPeriod.table_name}.date = ? AND p.id IS NULL AND #{KpiCalcPeriod.table_name}.active = ?", 
                         Date.today.at_beginning_of_month-1.months,
                         true)
                 .each do |original_period|
      #puts "Original period date - #{original_period.date}"
      period = KpiCalcPeriod.new

      period.kpi_pattern_id = original_period.kpi_pattern_id
      period.date = original_period.date+1.months
      period.parent_id = original_period.id

      if period.save
        puts "New period has been saved #{period.date}"
        period.copy_from_pattern
        new_period_indicators = period.kpi_period_indicators
        original_period.kpi_indicator_inspectors.select("#{KpiIndicatorInspector.table_name}.*, #{KpiPeriodIndicator.table_name}.indicator_id AS 'indicator_id' ")
                                                .where("#{KpiPeriodIndicator.table_name}.indicator_id IN (?)", new_period_indicators.map{|i| i.indicator_id}).each do |inspector|
          
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
    KpiCalcPeriod.novel.each do |p|
      puts "------------------------------"
      date = "#{p.date.month}.#{p.date.year}"
      puts "Period date is - #{date}"
      p.kpi_period_indicators.where("#{KpiPeriodIndicator.table_name}.pattern_plan IS NOT NULL").each do |i|

        case Indicator::FACT_PATTERNS[i.pattern_plan.to_s]
        when "import_from_other_system"
            puts "Pattern is 'import_from_other_system'"
            imported_value = KpiImportedValue.find(i.pattern_plan_settings['imported_value_id'])
            if ! imported_value.nil?
              i.plan_value = (imported_value.value.to_f * i.pattern_plan_settings['imported_value_percent'].to_f) / 100
              i.save 
            end
        end
        end

    end
  end

  task :make_kpi_mark_fact_calc => :environment do
    KpiCalcPeriod.active_opened.each do |p|
      puts "------------------------------"
      date = "#{p.date.month}.#{p.date.year}"
      puts "Period date is - #{date}"
      users = p.users.includes(:memberships)

      p.kpi_period_indicators.where("#{KpiPeriodIndicator.table_name}.pattern IS NOT NULL").each do |i|
          kpi_marks = i.kpi_marks

          case Indicator::FACT_PATTERNS[i.pattern.to_s]
          when "import_from_other_system"
            puts "Pattern is 'import_from_other_system'"
            kpi_marks.each{|m|
              m.fact_value=KpiImportedValue.find(i.pattern_settings['imported_value_id']).try(:value)
              m.save unless m.fact_value.nil?
            }
          when "avg_custom_field_mark_in_current_period"
            puts "Pattern is 'avg_custom_field_mark_in_current_period'"
            Issue.joins(:custom_values, {:fixed_version => :milestones})
                 .select("AVG(#{CustomValue.table_name}.value) AS 'fact', #{Setting.plugin_kpi['executor_id_issue_field']} AS 'executor_id'")
                 .where("#{Setting.plugin_kpi['executor_id_issue_field']} IN (?) 
                        AND custom_field_id=? 
                        AND DATE_FORMAT(#{Milestone.table_name}.effective_date, '%c.%Y')=?
                        AND (#{CustomValue.table_name}.value!='' AND #{CustomValue.table_name}.value IS NOT NULL) ", users, i.pattern_settings['mark_custom_field'], date)
                 .group("#{Setting.plugin_kpi['executor_id_issue_field']}").map do |f|

              puts "Fact is - #{f.fact}"
              puts "Executor ID is - #{f.executor_id}"

              mark = kpi_marks.where("#{KpiMark.table_name}.user_id = ? ", f.executor_id).first
              mark.fact_value = f.fact
              mark.save
            end

          when 'issue_hours_in_current_period'
            puts "Pattern is 'issue_hours_in_current_period'"

            Issue.joins(:status, {:fixed_version => :milestones})
                 .select("SUM(estimated_hours) AS 'fact', #{Setting.plugin_kpi['executor_id_issue_field']} AS 'executor_id'")
                 .where("#{Setting.plugin_kpi['executor_id_issue_field']} IN (?) AND DATE_FORMAT(#{Milestone.table_name}.effective_date, '%c.%Y')=? AND #{IssueStatus.table_name}.is_closed = ?", users, date, true)
                 .group("#{Setting.plugin_kpi['executor_id_issue_field']}").map do |f|

                puts "Estimated Hours is - #{f.fact}"
                puts "Executor ID is - #{f.executor_id}"

                mark = kpi_marks.where("#{KpiMark.table_name}.user_id = ? ", f.executor_id).first
                mark.fact_value = f.fact
                mark.save
              end
          when 'issue_lag_in_current_period'
            puts "Pattern is 'issue_lag_in_current_period'"

            Issue.joins(:status, {:fixed_version => :milestones})
                 .select("AVG(CASE WHEN DATEDIFF(#{Setting.plugin_kpi['check_date_issue_field']}, due_date) < 0 THEN 0 ELSE DATEDIFF(#{Setting.plugin_kpi['check_date_issue_field']}, due_date) END) AS 'fact',
                         #{Setting.plugin_kpi['executor_id_issue_field']} AS 'executor_id'")
                 .where("#{Setting.plugin_kpi['executor_id_issue_field']} IN (?) AND DATE_FORMAT(#{Milestone.table_name}.effective_date, '%c.%Y')=? AND #{IssueStatus.table_name}.is_closed = ?", users, date, true)
                 .group("#{Setting.plugin_kpi['executor_id_issue_field']}").map do |f|


                puts "Lag is - #{f.fact}"
                puts "Executor ID is - #{f.executor_id}"

                mark = kpi_marks.where("#{KpiMark.table_name}.user_id = ? ", f.executor_id).first
                mark.fact_value = f.fact
                mark.save
              end
          when 'self_and_executors_issues_avg_custom_field_mark'
            puts "Pattern is 'self_and_executors_issues_avg_custom_field_mark'"
            #Rails.logger.debug("sssssssssssssssssssssssssssssssssssssssssssssssssss")
            Project.joins({:all_members => [:member_roles, :user]}, {:issues => [:custom_values, {:fixed_version => :milestones}]})
                   .select("AVG(#{CustomValue.table_name}.value) AS 'fact', #{User.table_name}.id AS 'user_id'")
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

              mark = kpi_marks.where("#{KpiMark.table_name}.user_id = ? ", f.user_id).first
              mark.fact_value = f.fact
              mark.save              
              end

          when 'self_and_executors_issues_lag'
            puts "Pattern is 'self_and_executors_issues_lag'"

            Project.joins({:all_members => [:member_roles, :user]}, {:issues => {:fixed_version => :milestones}})
                   .select("AVG(CASE WHEN DATEDIFF(#{Setting.plugin_kpi['check_date_issue_field']}, due_date) < 0 THEN 0 ELSE DATEDIFF(#{Setting.plugin_kpi['check_date_issue_field']}, due_date) END) AS 'fact',
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
              puts "User ID is - #{f.user_id}"

              mark = kpi_marks.where("#{KpiMark.table_name}.user_id = ? ", f.user_id).first
              mark.fact_value = f.fact
              mark.save              
              end              
          end    
        end
      end
  end
end