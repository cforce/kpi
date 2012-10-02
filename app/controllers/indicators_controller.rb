class IndicatorsController < ApplicationController
	before_filter :find_kpi_units, :only => [:new, :edit]
	before_filter :find_categories, :only => [:new, :edit]
	before_filter :find_indicators, :only => [:index]



	def index
		
	end

	def new
		if !params[:copy_from].nil?
			source_indicator=Indicator.find(params[:copy_from])
		    attributes = source_indicator.attributes.dup.except('id')
		    @indicator = Indicator.new(attributes)
		else
		    @indicator = Indicator.new
		end
	end

	def edit
		@indicator ||= Indicator.find(params[:id])
	end

	def update
	    @indicator = Indicator.find(params[:id])
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
	@indicator = Indicator.new(params[:indicator])
	    if request.post? and @indicator.save
		   	flash[:notice] = l(:notice_successful_create)
		    redirect_to :action => 'index'
		else
			find_kpi_units
			find_categories
		    render :action => 'new'

		end
    end

	def destroy
	    @tracker = Indicator.find(params[:id])
	    #unless @tracker.issues.empty?
	    #  flash[:error] = l(:error_can_not_delete_tracker)
	    #else
	      @tracker.destroy
	    #end
	    redirect_to :action => 'index'
	end    

	private
	def find_kpi_units
	 @kpi_units=KpiUnit.order(:name)
	end

	def find_categories
	 @kpi_categories=KpiCategory.order(:name)
	end

	def find_indicators
	 @indicators=Indicator.order(:name)
	end
end