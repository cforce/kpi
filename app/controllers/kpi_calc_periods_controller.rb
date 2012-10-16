class KpiCalcPeriodsController < ApplicationController
	before_filter :find_period, :only => [:edit, :update, :destroy, :autocomplete_for_user, :add_inspectors, :remove_inspector, :update_inspectors, :update_plans]
	before_filter :find_patterns, :only => [:new, :edit]
	before_filter :find_calc_periods, :only => [:index]
	before_filter :find_indicators, :only => [:edit, :add_inspectors, :remove_inspector, :update_inspectors, :update_plans]
	before_filter :find_users, :only => [:edit, :add_inspectors, :remove_inspector, :update_inspectors, :update_plans]


	def index
		
	end

	def new
		@period = KpiCalcPeriod.new
	end

	def edit
		#@period ||= KpiCalcPeriod.find(params[:id])
		get_integrity_warnings
	end

	def update
	    #@period = KpiCalcPeriod.find(params[:id])
	    start_date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1)
	    @period.date=start_date
	    if request.put? and @period.update_attributes(params[:kpi_calc_period])
	      flash[:notice] = l(:notice_successful_update)
	      redirect_to :controller => 'kpi_calc_periods', :action => 'edit', :id => @period, :tab => 'general'
	      return
	    end
	   	find_patterns
	    render :action => 'edit', :tab => 'general'
	end

	def create
	@period = KpiCalcPeriod.new(params[:kpi_calc_period])
	start_date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1)
	@period.date=start_date
	    if request.post? and @period.save
	    	#Rails.logger.debug("#{@period.planned_indicators.inspect}ssssssssssssssss")
	    	@period.copy_from_pattern

		   	flash[:notice] = l(:notice_successful_create)
		    redirect_to(edit_kpi_calc_period_path(@period))
		else
			find_patterns
		    render :action => 'new'
		end
    end

	def destroy
	    #@period = KpiCalcPeriod.find(params[:id])
	    @period.destroy

=begin
	    if @indicator.errors.any?
		   flash[:error] = @indicator.errors.full_messages.join("<br>").html_safe
		   redirect_to :action => 'index'
	    else
	    end
=end
	    redirect_to :action => 'index'
	
	end    

	def autocomplete_for_user
	    @users = User.active.like(params[:q]).all(:limit => 100)
	    render 'groups/autocomplete_for_user', :layout => false
	end

	def add_inspectors
	    if request.post?
	    indicators=[]
	    params[:user_ids].each do |user_id|
	    	indicator_inspector=KpiIndicatorInspector.new
	    	indicator_inspector.user_id=user_id
	    	indicator_inspector.indicator_id=params[:inspector][:indicator_id]
	    	indicator_inspector.kpi_calc_period_id=@period.id
	    	indicator_inspector.save
	    	indicators.push(indicator_inspector)
	    	end
	    end

	    get_integrity_warnings

	    respond_to do |format|
	      format.html { redirect_to :controller => 'kpi_calc_periods', :action => 'edit', :id => @period, :tab => 'users' }
	      format.js {
	        render(:update) {|page|
	          page.replace_html "tab-content-users", :partial => 'kpi_calc_periods/users'
	          indicators.each {|indicator| page.visual_effect(:highlight, "indicator-#{indicator.id}") 
	      								   page.replace_html "kpi_pattern_warnings", :partial => 'kpi_patterns/warnings'}
	        }
	      }
	    end		
	end

	def remove_inspector
		@indicator_inspector = KpiIndicatorInspector.find(params[:indicator_inspector_id])
		@indicator_inspector.destroy
		get_integrity_warnings
	    respond_to do |format|
	      format.html { redirect_to :controller => 'kpi_calc_periods', :action => 'edit', :id => @period, :tab => 'users' }
	      format.js { render(:update) {|page| page.replace_html "tab-content-users", :partial => 'kpi_calc_periods/users'
	      		 							  page.replace_html "kpi_pattern_warnings", :partial => 'kpi_patterns/warnings'
	      						}}
	    end		
	end

	def update_inspectors
		params[:percent].each{|k,v|
			ii=KpiIndicatorInspector.find(k)
			ii.percent=v
			ii.save
			ii.errors.full_messages.each do |error_msg| 
			      @saved_errors.push(error_msg)
			    end 			
			}	
		get_integrity_warnings
	    respond_to do |format|
	      format.html { redirect_to :controller => 'kpi_calc_periods', :action => 'edit', :id => @period, :tab => 'users' }
	      format.js { render(:update) {|page| page.replace_html "tab-content-users", :partial => 'kpi_calc_periods/users'
	      									  page.replace_html "kpi_pattern_warnings", :partial => 'kpi_patterns/warnings'
	      									  }}
	    end	
	end	

	def update_plans
		params[:plan_value].each{|k,v|
			pi=KpiPeriodIndicator.find(k)
			pi.plan_value=v
			pi.save
			pi.errors.full_messages.each do |error_msg| 
			      @saved_errors.push(error_msg)
			    end 			
			}	
		get_integrity_warnings
	    respond_to do |format|
	      format.html { redirect_to :controller => 'kpi_calc_periods', :action => 'edit', :id => @period, :tab => 'plan_values' }
	      format.js { render(:update) {|page| page.replace_html "tab-content-plan_values", :partial => 'kpi_calc_periods/plan_values'
	      									  page.replace_html "kpi_pattern_warnings", :partial => 'kpi_patterns/warnings'
	      									  }}
	    end	
	end	

	private


	def get_integrity_warnings
		if(@period.integrity?)
			@period.integrity=true
			@period.save
		else
			@kpi_warnings.push('inspectors_weight_sum_not_equal_100') 
			#Rails.logger.debug('ssssssssss')
			@period.integrity=false
			@period.save
		end
	end

	def find_indicators
		@indicators=@period.kpi_pattern.indicators
	end

	def find_period
		@saved_errors=[]
		@kpi_warnings=[]
		@period = KpiCalcPeriod.find(params[:id])
	end

	def find_users
		@users=User.active.all(:limit => 100)
	end

	def find_patterns
	 	@patterns=KpiPattern.where(:integrity => true).order(:name)
	end

	def find_calc_periods
	 	@periods=KpiCalcPeriod.order(:date)
	end
end