
class KpiController < ApplicationController
	#before_filter :find_date, :only => [:marks]
	#before_filter :find_marks, :only => [:marks, :update_marks]
	#before_filter :find_actual_period_dates, :only => [:marks]
	before_filter :find_user_period_dates, :only => [:effectiveness]
	before_filter :check_user, :only => [:effectiveness]

	def index

	end
=begin
	def marks
		
	end
=end


	def effectiveness
		find_user
		find_date
		@periods = @user.kpi_calc_periods.active.where("date = ?", @date)

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
		@date = params[:date].nil? ? Date.current.at_beginning_of_month : Date.parse(params[:date])
	end

	def find_user_period_dates
		find_date
		find_user
		@period_dates = @user.kpi_calc_periods.active.select(:date).group(:date).order(:date)
	end

	def find_user
		@user = params[:user_id].nil? ? User.current : User.find(params[:user_id])
	end

	def check_user
		render_403 if User.current != @user and not @user.subordinate? and not User.current.admin? and not User.current.global_permission_to?(params[:controller], 'effectiveness')
	end
end