# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/application")

namespace :redmine do
  task :make_kpi_mark_fact_calc => :environment do
    KpiCalcPeriod.active_opened.each do |p|
      puts "------------------------------"
      date = "#{p.date.month}.#{p.date.year}"
      puts "Period date is - #{date}"
      users = p.users.includes(:memberships)

      p.kpi_period_indicators.where("#{KpiPeriodIndicator.table_name}.pattern IS NOT NULL").each do |i|
          kpi_marks = i.kpi_marks
          case Indicator::FACT_PATTERNS[i.pattern.to_s]
          when "avg_custom_field_mark_in_current_period"
            puts "Pattern is 'avg_custom_field_mark_in_current_period'"
            Issue.joins(:custom_values, {:fixed_version => :milestones})
                 .select("AVG(custom_values.value) AS 'fact', #{Setting.plugin_kpi['executor_id_issue_field']} AS 'executor_id'")
                 .where("#{Setting.plugin_kpi['executor_id_issue_field']} IN (?) AND custom_field_id=? AND DATE_FORMAT(#{Milestone.table_name}.effective_date, '%c.%Y')=?", users, i.pattern_settings['mark_custom_field'], date)
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
                           AND custom_field_id=? ", i.pattern_settings['role'], users, date, i.pattern_settings['mark_custom_field'])
                          .order("#{Project.table_name}.name")
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