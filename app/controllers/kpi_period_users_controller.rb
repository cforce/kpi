class KpiPeriodUsersController < ApplicationController
    before_filter :find_period_user, :only => [:edit_hours, :edit_base_salary, :update_hours, :update_base_salary]
    #before_filter :find_user, :only => [:disable, :enable, :update_plan, :update_fact, :edit_plan, :edit_fact]

    helper :kpi
    include KpiHelper

    def edit_hours
        render "edit_hours", :layout => false
    end

    def edit_base_salary
        render "edit_base_salary", :layout => false
    end

    def update_hours
        find_user
        @period_user.hours=params[:kpi_period_user][:hours]
        @period_user.save if @period_user.check_user_for_hours_update?(@user)
        period = @period_user.kpi_calc_period
        #Rails.logger.debug "fffffffffffffff #{period.inspect}"
        respond_to do |format|
          format.js {
            render(:update) {|page|
              page.replace_html "calc_period_#{period.id}", :partial => 'kpi/period_effectiveness', :locals => { :period => period, :i => period.id } 
              page.call :portable_data_apply
              # users.each {|user| page.visual_effect(:highlight, "user-#{user.id}") }
            }
          }
        end
    end 

    def update_base_salary
        find_user
        @period_user.base_salary=params[:kpi_period_user][:base_salary]
        @period_user.save if @period_user.check_user_for_salary_update?(@user)
        period = @period_user.kpi_calc_period
        #Rails.logger.debug "fffffffffffffff #{period.inspect}"
        respond_to do |format|
          format.js {
            render(:update) {|page|
              page.replace_html "calc_period_#{period.id}", :partial => 'kpi/period_effectiveness', :locals => { :period => period, :i => period.id } 
              page.call :portable_data_apply
              # users.each {|user| page.visual_effect(:highlight, "user-#{user.id}") }
            }
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