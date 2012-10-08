class KpiCalcPeriodsController < ApplicationController
	#before_filter :find_kpi_units, :only => [:new, :edit]
	before_filter :find_patterns, :only => [:new, :edit]
	before_filter :find_calc_periods, :only => [:index]

	def index
		
	end

	def new
		@period = KpiCalcPeriod.new
	end

	def edit
		@indicator ||= KpiCalcPeriod.find(params[:id])
	end

	def update
	    @indicator = KpiCalcPeriod.find(params[:id])
	    if request.put? and @indicator.update_attributes(params[:indicator])
	      flash[:notice] = l(:notice_successful_update)
	      redirect_to :action => 'index'
	      return
	    end
		find_kpi_units
		find_categories
	    render :action => 'edit'
	end

	def create
	@period = KpiCalcPeriod.new(params[:kpi_calc_period])
	start_date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1)
	@period.date=start_date
	    if request.post? and @period.save
		   	flash[:notice] = l(:notice_successful_create)
		    redirect_to :action => 'index'
		else
			find_patterns
		    render :action => 'new'

		end
    end

	def destroy
	    @indicator = KpiCalcPeriod.find(params[:id])
	    @indicator.destroy

	    if @indicator.errors.any?
		   flash[:error] = @indicator.errors.full_messages.join("<br>").html_safe
		   redirect_to :action => 'index'
	    else
	       redirect_to :action => 'index'
	    end
	
	end    

	private

	def find_patterns
	 @patterns=KpiPattern.where(:integrity => true).order(:name)
	end

	def find_calc_periods
	 @periods=KpiCalcPeriod.order(:date)
	end
end