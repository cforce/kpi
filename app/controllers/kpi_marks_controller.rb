class KpiMarksController < ApplicationController
	before_filter :find_mark
	before_filter :find_user, :only => [:update_plan, :update_fact, :edit_plan]

	helper :kpi
	include KpiHelper

	def edit_plan
		render "edit_plan", :layout => false
	end

	def update_plan
		#user_id = params[:kpi_mark][:user_id] || params[:user_id]
		period=@mark.kpi_indicator_inspector.kpi_period_indicator.kpi_period_category.kpi_calc_period
		@mark.plan_value=params[:kpi_mark][:plan_value]
		@mark.save
	
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
	
	end

	def update_fact

	end	

	private
	def find_mark
		@mark = KpiMark.find(params[:id])
	end

	def find_user
		# if not params[:kpi_mark].nil?
			# @user = User.find(params[:kpi_mark][:user_id]) 

		# else
			@user = params[:user_id].nil? ? User.current : User.find(params[:user_id])
		# end
	end	
end