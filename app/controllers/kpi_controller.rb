
class KpiController < ApplicationController
	#before_filter :find_date, :only => [:marks]
	before_filter :find_marks, :only => [:marks, :update_marks]
	before_filter :find_actual_period_dates, :only => [:marks]
	before_filter :find_user_period_dates, :only => [:effectiveness]
	before_filter :check_user, :only => [:effectiveness]

	def index

	end

	def marks
		
	end

	def effectiveness
		find_user
		find_date
		@periods = @user.kpi_calc_periods.active.where("date = ?", @date)
	end

	def update_marks
		params[:mark].each{|k,v|
			km=KpiMark.find(k)
			km.fact_value=v
			km.save
			# km.errors.full_messages.each do |error_msg| 
			#       @saved_errors.push(error_msg)
			#     end 			
			}	


	    respond_to do |format|
	      format.html { redirect_to :controller => 'kpi', :action => 'marks'}
	      format.js {
	        render(:update) {|page|
	          page.replace_html "kpi_marks", :partial => 'kpi/marks_form'
	        }
	      }
	    end
	end

	private 
	def find_marks
		find_date
		find_user
		@marks = @user.get_my_marks.joins(:user).where("start_date >= ? AND end_date <= ?", @date, @date.at_end_of_month).includes(:kpi_indicator_inspector => [{:kpi_period_indicator => [:indicator => :kpi_unit]}]).order("#{User.table_name}.lastname", :end_date)
	end

	def find_actual_period_dates
		@period_dates = KpiCalcPeriod.actual.select(:date).group(:date).order(:date)
	end

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
		render_403 if User.current != @user and not @user.subordinate? and not User.current.admin?
	end
end