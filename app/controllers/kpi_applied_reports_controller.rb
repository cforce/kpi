class KpiAppliedReportsController < ApplicationController
  before_filter :authorized_globaly?
  before_filter :find_period_dates, :only => [:show,  :apply, :redo]
  before_filter :find_date, :only => [:show, :apply, :redo]
    
  helper :kpi
  include KpiHelper

  def show
    @applied_report = KpiAppliedReport.where(:date => @date).try(:first)

    @users_with_open_period = User.joins(:kpi_calc_periods).where("#{KpiCalcPeriod.table_name}.date = ? AND #{KpiCalcPeriod.table_name}.locked = ? AND #{KpiCalcPeriod.table_name}.active = ? AND #{KpiPeriodUser.table_name}.locked = ? ", @date, false, true, false)
    
    find_closed_user_periods unless @users_with_open_period.any?

  end

  def apply
    @applied_report = KpiAppliedReport.new
    @applied_report.date = @date
    @applied_report.user_id = User.current.id
    @applied_report.save

    find_closed_user_periods

    #find_closed_user_periods.each{|cup| @applied_report << cup }
    @applied_report.kpi_calc_periods << KpiCalcPeriod.where("#{KpiCalcPeriod.table_name}.locked = ?
                                                            AND #{KpiCalcPeriod.table_name}.date = ?", true, @date)

    redirect_to :action => 'show', :date => @date
  end

  def redo
    KpiAppliedReport.where(:date => @date).each do |ar|
    ar.destroy
    end

    redirect_to :action => 'show', :date => @date
  end

  private

  def find_period_dates
    if  User.current.global_permission_to?('kpi_applied_reports', 'apply')
      @period_dates = KpiCalcPeriod.active.select(:date).group(:date).order(:date)
    else
      @period_dates = KpiAppliedReport.select(:date).group(:date).order(:date)
    end
  end

  def find_closed_user_periods
      @closed_user_periods = KpiPeriodUser.joins(:kpi_calc_period, :user => [{:user_department => :node}, :user_title])                                          
                                          .where("#{KpiCalcPeriod.table_name}.locked = ?
                                                  AND #{KpiCalcPeriod.table_name}.date = ?",
                                                  true,  @date)
                                          .includes(:kpi_calc_period, :user => [{:user_department => :node}, :user_title])
                                          .order("#{UserDepartmentTree.table_name}.lft")
  end

  def find_date
    @date = params[:date].nil? ? @period_dates.last.date : Date.parse(params[:date])
  end 
end