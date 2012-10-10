class KpiCalcPeriodsController < ApplicationController
	before_filter :find_period, :only => [:edit, :update, :destroy, :autocomplete_for_user, :add_inspectors, :remove_inspector]
	before_filter :find_patterns, :only => [:new, :edit]
	before_filter :find_calc_periods, :only => [:index]
	before_filter :find_indicators, :only => [:edit, :add_inspectors, :remove_inspector]
	before_filter :find_users, :only => [:edit, :add_inspectors, :remove_inspector]


	def index
		
	end

	def new
		@period = KpiCalcPeriod.new
	end

	def edit
		#@period ||= KpiCalcPeriod.find(params[:id])
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

	    respond_to do |format|
	      format.html { redirect_to :controller => 'kpi_calc_periods', :action => 'edit', :id => @period, :tab => 'users' }
	      format.js {
	        render(:update) {|page|
	          page.replace_html "tab-content-users", :partial => 'kpi_calc_periods/users'
	          indicators.each {|indicator| page.visual_effect(:highlight, "indicator-#{indicator.id}") }
	        }
	      }
	    end		
	end

	def remove_inspector
		@indicator_inspector = KpiIndicatorInspector.find(params[:indicator_inspector_id])
		@indicator_inspector.destroy
	    respond_to do |format|
	      format.html { redirect_to :controller => 'kpi_calc_periods', :action => 'edit', :id => @period, :tab => 'users' }
	      format.js { render(:update) {|page| page.replace_html "tab-content-users", :partial => 'kpi_calc_periods/users'} }
	    end		
	end

	private

	def find_indicators
		@indicators=@period.kpi_pattern.indicators
	end

	def find_period
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