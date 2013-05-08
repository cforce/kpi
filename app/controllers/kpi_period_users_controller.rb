class KpiPeriodUsersController < ApplicationController
    before_filter :find_period_user, :only => [:reopen_message, :close_message, :edit_hours, :edit_base_salary, :update_hours, :update_base_salary, :edit_jobprise, :update_jobprise, :close, :reopen]
    #before_filter :find_user, :only => [:disable, :enable, :update_plan, :update_fact, :edit_plan, :edit_fact]

    helper :kpi
    include KpiHelper


    def close
        @period_user.close
        redirect_to :controller => 'kpi', :action => 'effectiveness', :user_id => @period_user.user_id, :date => @period_user.kpi_calc_period.date
    end

    def close_message
        @not_set_marks_in_period = KpiMark.not_set.where("#{KpiMark.table_name}.inspector_id = ? 
                                                        AND #{KpiMark.table_name}.start_date BETWEEN ? AND ?
                                                        AND #{KpiMark.table_name}.disabled = ?", 
                                                        @period_user.user_id,
                                                        @period_user.kpi_calc_period.date,
                                                        @period_user.kpi_calc_period.date.at_end_of_month,
                                                        false
                                                        )

        # @isues_requiring_attention = Issue.joins("INNER JOIN #{CustomValue.table_name} AS cv_cus ON cv_cus.custom_field_id = #{Setting.plugin_kpi['customer_custom_field_id']} 
        #                                                                                             AND cv_cus.value = #{@period_user.user_id}
        #                                           LEFT JOIN #{CustomValue.table_name} AS cv_mark ON cv_mark.custom_field_id = #{Setting.plugin_kpi['mark_custom_field_that_should_be_set_id']}"
        #                                         )
        #                                   .where("cv_mark.custom_field_id IS NULL")

        @isues_requiring_attention = Issue.joins({:fixed_version => :milestones}).where(:assigned_to_id => @period_user.user_id, :status_id => Setting.plugin_kpi['issue_status_id']).where("DATE_FORMAT(#{Milestone.table_name}.effective_date, '%c.%Y') = ? ", "#{@period_user.kpi_calc_period.date.month}.#{@period_user.kpi_calc_period.date.year}")
        
        render "close_message", :layout => false
    end

    def reopen_message
        @applied_report = KpiAppliedReport.where(:user_department_id => @period_user.user.top_department.id, :date => @period_user.kpi_calc_period.date)
        render "reopen_message", :layout => false
    end

    def reopen
        @period_user.reopen
        redirect_to :controller => 'kpi', :action => 'effectiveness', :user_id => @period_user.user_id, :date => @period_user.kpi_calc_period.date
    end

    def edit_hours
        render "edit_hours", :layout => false
    end

    def edit_base_salary
        render "edit_base_salary", :layout => false
    end

    def edit_jobprise
        render "edit_jobprise", :layout => false
    end

    def update_hours
        find_user
        @period_user.hours=params[:kpi_period_user][:hours]
        @period_user.save if @period_user.check_user_for_hours_update?(@user)
        @period = @period_user.kpi_calc_period
        #Rails.logger.debug "fffffffffffffff #{period.inspect}"
        respond_to do |format|
          format.js {
            render "kpi/effectiveness"
            }
        end
    end 

    def update_base_salary
        find_user
        @period_user.base_salary=params[:kpi_period_user][:base_salary]
        @period_user.save if @period_user.check_user_for_salary_update?(@user)
        @period = @period_user.kpi_calc_period
        #Rails.logger.debug "fffffffffffffff #{period.inspect}"
        respond_to do |format|
          format.js {
            render "kpi/effectiveness"
            }
        end
    end 

    def update_jobprise
        find_user
        @period_user.jobprise=params[:kpi_period_user][:jobprise]
        @period_user.save if @period_user.check_user_for_jobprise_update?(@user)
        @period = @period_user.kpi_calc_period
        #Rails.logger.debug "fffffffffffffff #{period.inspect}"
        respond_to do |format|
          format.js {
            render "kpi/effectiveness"
            }
        end
    end 

    private
    def find_period_user
        @period_user = KpiPeriodUser.find(params[:id])
    end

    def find_user
        @user = @period_user.user
    end

end