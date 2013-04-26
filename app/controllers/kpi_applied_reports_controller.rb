class KpiAppliedReportsController < ApplicationController
  before_filter :authorized_globaly?, :except => [:show]
  before_filter :find_period_dates, :only => [:show,  :apply, :cancel]
  before_filter :find_date, :only => [:show, :apply, :cancel]
    
  helper :kpi
  include KpiHelper

  def show
    #@users_with_open_period = User.joins(:kpi_calc_periods).where("#{KpiCalcPeriod.table_name}.date = ? AND #{KpiCalcPeriod.table_name}.locked = ? AND #{KpiCalcPeriod.table_name}.active = ? AND #{KpiPeriodUser.table_name}.locked = ? ", @date, false, true, false)
    
    find_user_periods #unless @users_with_open_period.any?

    @department_period_states = {}
    @departments = {}

    @all_surcharges_names = KpiSurcharge.joins(:kpi_period_surcharges).where("kpi_calc_period_id IN (?)", @user_periods.map{|up| up.kpi_calc_period.id}.uniq).group("#{KpiSurcharge.table_name}.id")
    @totals = {:salary => {}, :surcharges => {}, :calculated_salary => {}, :salary_whithout_deduction => {}, :deductions => {}, :users => {}}
    @subdivision_totals = {:salary => {}, :surcharges => {}, :calculated_salary => {}, :salary_whithout_deduction => {}, :deductions => {}, :users => {}}
  end

  def apply
    #department = UserDepartment.find(params[:department_id])
    @department_id = params[:department_id]

    #@user_who_approved = User.current
    @applied_report = KpiAppliedReport.includes(:user).where("#{KpiAppliedReport.table_name}.date = ? AND #{KpiAppliedReport.table_name}.user_department_id = ? ", @date, @department_id).try(:first)

    @applied_report = KpiAppliedReport.new
    @applied_report.date = @date
    @applied_report.user_id = User.current.id
    @applied_report.user_department_id = @department_id #department.id
    @applied_report.save

    respond_to do |format| format.js { render "kpi_applied_reports/apply" }
    end

    # @applied_report.kpi_calc_periods << KpiCalcPeriod.where("#{KpiCalcPeriod.table_name}.locked = ?
                                                            # AND #{KpiCalcPeriod.table_name}.date = ?", true, @date)
  end

  def cancel
    @department_id = params[:department_id]
    KpiAppliedReport.where(:date => @date, :user_department_id => params[:department_id]).each do |ar|
      ar.destroy
    end

    respond_to do |format| format.js { render "kpi_applied_reports/cancel" } 
    end
  end

  private

  def find_period_dates
    # if  User.current.global_permission_to?('kpi_applied_reports', 'apply')
    #   @period_dates = KpiCalcPeriod.active.select(:date).group(:date).order(:date)
    # else
    #   @period_dates = KpiAppliedReport.select(:date).group(:date).order(:date)
    # end
    @period_dates = KpiCalcPeriod.active.select(:date).group(:date).order(:date)
  end

  def find_user_periods
    if User.current.global_permission_to?('kpi_applied_reports', 'show') or User.current.global_permission_to?('kpi_applied_reports', 'apply')
      @user_periods = KpiPeriodUser.joins(:kpi_calc_period, :user => [{:user_department => :node}, :user_title])                                          
                                    .where("#{KpiCalcPeriod.table_name}.date = ?",
                                            @date)
                                    .includes(:kpi_calc_period, :user => [{:user_department => :node}, :user_title])
                                    .order("#{UserDepartmentTree.table_name}.lft,
                                            CASE WHEN #{UserDepartment.table_name}.manager_id=#{KpiPeriodUser.table_name}.user_id THEN 0 ELSE 1 END,
                                            #{UserTitle.table_name}.name,
                                            #{User.table_name}.lastname")
    else
      conds = User.current.sql_conditions_for_periods

      @user_periods = KpiPeriodUser.joins(:kpi_calc_period, :user => [{:user_department => :node}, :user_title, :user_tree]).joins("LEFT JOIN #{UserTree.table_name} AS ut ON ut.id=#{KpiCalcPeriod.table_name}.user_id")                                          
                                            .where("#{KpiCalcPeriod.table_name}.date = ?
                                                    AND (
                                                        #{conds['cond1']}
                                                        OR #{conds['cond2']}
                                                        )",
                                                    @date)
                                            .includes(:kpi_calc_period, :user => [{:user_department => :node}, :user_title])
                                            .order("#{UserDepartmentTree.table_name}.lft,
                                                     CASE WHEN #{UserDepartment.table_name}.manager_id=#{KpiPeriodUser.table_name}.user_id THEN 0 ELSE 1 END,
                                                    #{UserTitle.table_name}.name,
                                                    #{User.table_name}.lastname")
    end
  end

  def find_date
    @date = params[:date].nil? ? @period_dates.last.date : Date.parse(params[:date])
  end 
end