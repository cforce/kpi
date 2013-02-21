class KpiUserSurchargesController < ApplicationController
    before_filter :find_period_user, :only => [:show_surcharges, :add_surcharge]

    helper :kpi
    include KpiHelper

    def show_surcharges
        @user_surcharge = KpiUserSurcharge.new

        period_surcharges = @period_user.kpi_calc_period.kpi_surcharges
        @period_not_null_surcharges = period_surcharges.where("default_value IS NOT NULL").select("default_value, #{KpiSurcharge.table_name}.*")
        @user_surcharges = @period_user.kpi_user_surcharges.includes(:kpi_surcharge)

        @available_surcharges = @period_user.available_surcharges(@user_surcharges, period_surcharges, @period_not_null_surcharges)

        #Rails.logger.debug "fffffffffffffffffff"
        render "show_surcharges", :layout => false
    end


    def add_surcharge
        find_user

        @user_surcharge = KpiUserSurcharge.new(params[:kpi_user_surcharge])
        @user_surcharge.value = 0-@user_surcharge.value if @user_surcharge.is_deduction and @user_surcharge.value>0
        @user_surcharge.save if @period_user.check_user_for_surcharge_update?(@user)

        @period = @period_user.kpi_calc_period 

        respond_to do |format|
          format.js {
            render "kpi/effectiveness"
            }
        end
    end 

    def destroy
        find_user_surcharge
        @period_user = @user_surcharge.kpi_period_user
        find_user
        @period = @period_user.kpi_calc_period
        @user_surcharge.destroy if @period_user.check_user_for_surcharge_update?(@user)
        
        #Rails.logger.debug "fffffffffffffff #{@period_user.inspect}"
        respond_to do |format|
          format.js {
            render "kpi/effectiveness"
            }
        end
    end

    private
    def find_user_surcharge
        @user_surcharge = KpiUserSurcharge.find(params[:id])
    end

    def find_period_user
        @period_user = KpiPeriodUser.find(params[:id])
    end

    def find_user
        @user = @period_user.user
    end


end