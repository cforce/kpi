class KpiMarksController < ApplicationController
	before_filter :find_mark, :only => [:disable, :enable, :update_plan, :edit_fact, :edit_plan, :update_fact, :show_info]
	#before_filter :find_user, :only => [:update_plan, :update_fact, :edit_plan, :edit_fact]

	helper :kpi
	include KpiHelper

	def index
	find_actual_period_dates
	find_marks
	end

	def edit_plan
		@user = @mark.user
		render "edit_plan", :layout => false
	end

	def user_marks
		
	end

	def disable
		@user = @mark.user
		period=@mark.kpi_indicator_inspector.kpi_period_indicator.kpi_period_category.kpi_calc_period
		period_user = period.kpi_period_users.where(:user_id => @user.id).first
		@mark.disabled=true
		@mark.save if @user.user_kpi_marks_can_be_disabled?(period_user)
	
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


	def enable
		@user = @mark.user
		period=@mark.kpi_indicator_inspector.kpi_period_indicator.kpi_period_category.kpi_calc_period
		period_user = period.kpi_period_users.where(:user_id => @user.id).first
		@mark.disabled=false
		@mark.save if @user.user_kpi_marks_can_be_disabled?(period_user)
	
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

	def show_info
		@issues = Issue.where("id IN (?)", @mark.issues.map{|k,v| k}) unless @mark.issues.nil?
		@period_indicator = @mark.kpi_period_indicator
		render_403 unless @mark.check_user_for_info_showing?
		render "show_info", :layout => false
	end

	def update_user_marks
		marks = KpiMark.find(params[:mark].map{|k, v| k})

		marks.each{|mark|
			mark.fact_value=params[:mark][mark.id.to_s]
			mark.explanation=params[:explanation][mark.id.to_s]
			mark.save if mark.check_user_for_fact_update		
			}	
		find_marks
		#should be optimized

	    respond_to do |format|
	      format.html { redirect_to :controller => 'kpi', :action => 'marks'}
	      format.js {
	        render(:update) {|page|
	          page.replace_html "tab-content-kpi-marks-#{@user.id}", :partial => 'kpi_marks/user_marks', :locals => {:tab => {:user_id => @user.id} } 
	        }
	      }
	    end
	end

	def update_plan
		@user = @mark.user
		#user_id = params[:kpi_mark][:user_id] || params[:user_id]
		period=@mark.kpi_indicator_inspector.kpi_period_indicator.kpi_period_category.kpi_calc_period
		@mark.plan_value=params[:kpi_mark][:plan_value]
		@mark.save if @mark.check_user_for_plan_update
	
	    respond_to do |format|
	      format.js {
	        render(:update) {|page|
	          page.replace_html "calc_period_#{period.id}", :partial => 'kpi/period_effectiveness', :locals => { :period => period, :i => params[:kpi_mark][:i] } 
	          page.call :portable_data_apply
	          # users.each {|user| page.visual_effect(:highlight, "user-#{user.id}") }
	        }
	      }
	    end
	end

	def edit_fact
		@user = @mark.user
		render "edit_fact", :layout => false
	end

	def update_fact
		@user = @mark.user
		period=@mark.kpi_indicator_inspector.kpi_period_indicator.kpi_period_category.kpi_calc_period
		@mark.fact_value=params[:kpi_mark][:fact_value]
		@mark.explanation=params[:kpi_mark][:explanation]
		@mark.save if @mark.check_user_for_fact_update
	
	    respond_to do |format|
	      format.js {
	        render(:update) {|page|
	          page.replace_html "calc_period_#{period.id}", :partial => 'kpi/period_effectiveness', :locals => { :period => period, :i => params[:kpi_mark][:i] } 
	          page.call :portable_data_apply
	          # users.each {|user| page.visual_effect(:highlight, "user-#{user.id}") }
	        }
	      }
	    end
	end	

	private
	def find_actual_period_dates
		@period_dates = KpiCalcPeriod.active_opened.select(:date).group(:date).order(:date)
	end

	def find_marks
		find_user
		find_date
		@marks = User.current.get_my_marks.joins(:user).where("start_date >= ? AND end_date <= ?", @date, @date.at_end_of_month).includes(:user, :kpi_indicator_inspector => [{:kpi_period_indicator => [:indicator => :kpi_unit]}]).order("#{User.table_name}.lastname", :end_date)
		@estimated_users = @marks.map{|m| m.user}.uniq
	end

	def find_date
		@date = params[:date].nil? ? @user.find_default_kpi_mark_date : Date.parse(params[:date])
	end	

	def find_mark
		@mark = KpiMark.find(params[:id])
	end

	def find_user
		@user ||= params[:user_id].nil? ? User.current : User.find(params[:user_id])
	end	


end