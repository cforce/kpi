
class KpiController < ApplicationController
	#before_filter :find_date, :only => [:marks]
	#before_filter :find_marks, :only => [:marks, :update_marks]
	#before_filter :find_actual_period_dates, :only => [:marks]
	before_filter :find_user_period_dates, :only => [:effectiveness]
	before_filter :find_managed_periods, :only => [:effectiveness]
	before_filter :check_user, :only => [:effectiveness]

	helper :kpi
	include KpiHelper

	def index

	end
=begin
	def marks
		
	end
=end


	def effectiveness
		#find_user
		#find_date

		if User.current == @user or User.current.admin? or User.current.global_permission_to?(params[:controller], 'effectiveness')
			@periods = @user.kpi_calc_periods.active
											.where("#{KpiCalcPeriod.table_name}.date = ?", @date)
											.includes(:kpi_pattern, :kpi_period_categories => [:kpi_category, {:kpi_period_indicators => {:kpi_marks => :inspector, :indicator => :kpi_unit}}])
		else
	    conds = User.current.sql_conditions_for_periods
			@periods = KpiCalcPeriod.active
															.includes(:kpi_pattern, :kpi_period_categories => [:kpi_category, {:kpi_period_indicators => {:kpi_marks => :inspector, :indicator => :kpi_unit}}])
															.joins(:users => :user_tree)
															.joins("LEFT JOIN #{UserTree.table_name} AS ut ON ut.id=#{KpiCalcPeriod.table_name}.user_id")
															.where("#{KpiPeriodUser.table_name}.user_id = ? AND #{KpiCalcPeriod.table_name}.date = ?
	                                    AND (#{conds['cond1']} OR #{conds['cond2']})
																			", @user.id, @date)
		end



	end

	private 
=begin
	def find_marks
		find_date
		find_user
		@marks = @user.get_my_marks.joins(:user).where("start_date >= ? AND end_date <= ?", @date, @date.at_end_of_month).includes(:user, :kpi_indicator_inspector => [{:kpi_period_indicator => [:indicator => :kpi_unit]}]).order("#{User.table_name}.lastname", :end_date)
		@estimated_users = @marks.map{|m| m.user}.uniq
	end

	def find_actual_period_dates
		@period_dates = KpiCalcPeriod.actual.select(:date).group(:date).order(:date)
	end
=end

	def find_date
		@date = params[:date].nil? ? @user.find_default_effectiveness_date : Date.parse(params[:date])
	end

	def find_managed_periods
		@managed_periods = @user.kpi_calc_periods.where("#{KpiCalcPeriod.table_name}.user_id = ?", User.current.id)
	end

	def find_user_period_dates
		find_user
		find_date
		@period_dates = @user.kpi_calc_periods.active.select(:date).group(:date).order(:date)
	end

	def find_user
		@user = params[:user_id].nil? ? User.current : User.find(params[:user_id])
	end

	def check_user
		render_403 if User.current != @user and not @user.under? and not @user.substitutable_employees_under? and not User.current.admin? and not User.current.global_permission_to?(params[:controller], 'effectiveness') and not @managed_periods.any?
	end
end