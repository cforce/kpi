
class KpiPatternsController < ApplicationController
	before_filter :authorized_globaly?

	before_filter :find_patterns, :only => [:index]
	before_filter :get_pattern, :except => [:new, :create, :index]
	before_filter :find_category_weights, :except => [:new, :create, :index, :add_indicators]
	#before_filter :get_integrity_warnings, :only => [:update_indicators, :add_indicators, :remove_indicator, :edit]

	helper :kpi
	include KpiHelper

	def index
		
	end

	def new
		if !params[:copy_from].nil?
			source_pattern=KpiPattern.find(params[:copy_from])
		    attributes = source_pattern.attributes.dup.except('id')
		    @pattern = KpiPattern.new(attributes)
		else
		    @pattern = KpiPattern.new
		end
	end

	def edit
		#@pattern ||= KpiPattern.find(params[:id])
		get_integrity_warnings
	end

	def update
	    #@pattern = KpiPattern.find(params[:id])
	    if request.put? and @pattern.update_attributes(params[:kpi_pattern])
	      flash[:notice] = l(:notice_successful_update)
	      redirect_to(edit_kpi_pattern_path(@pattern))
	      return
	    end
	    render :action => 'edit'
	end

	def create
	@pattern = KpiPattern.new(params[:kpi_pattern])
	    if request.post? and @pattern.save
		   	flash[:notice] = l(:notice_successful_create)

		   	if not params[:copy_from].nil?
		   		source_pattern = KpiPattern.find(params[:copy_from])
		   		source_pattern.copy_to @pattern
		   	end

		    redirect_to(edit_kpi_pattern_path(@pattern))
		else
		    render :action => 'new'

		end
    end

	def destroy
	    #@pattern = KpiPattern.find(params[:id])
	    #unless @tracker.issues.empty?
	    #  flash[:error] = l(:error_can_not_delete_tracker)
	    #else
	      @pattern.destroy
	    #end
	    redirect_to :action => 'index'
	end    

	def add_users
	    #@pattern = KpiPattern.find(params[:id])
	    @users = User.find_all_by_id(params[:user_ids])
	    @pattern.users << @users if request.post?
		respond_to do |format|
			 format.js { render 'users' }
		end
	end

	def remove_user
	    #@pattern = KpiPattern.find(params[:id])
	    @pattern.users.delete(User.find(params[:user_id])) if request.delete?
		respond_to do |format|
			 format.js { render 'users' }
		end
	end

	def add_indicators
	    #@pattern = KpiPattern.find(params[:id])
	    @indicators = Indicator.find_all_by_id(params[:indicator_ids])
	    @pattern.indicators << @indicators if request.post?
	    find_category_weights    
	    get_integrity_warnings
		respond_to do |format|
			 format.js { render 'indicators' }
		end

	end

	def update_indicators
		#@pattern = KpiPattern.find(params[:id])
		params[:percent].each{|k,v|
			kpi_pattern_undicator=KpiPatternIndicator.find(k)
			kpi_pattern_undicator.percent=v
			kpi_pattern_undicator.save
			kpi_pattern_undicator.errors.full_messages.each do |error_msg| 
			      @indicator_save_errors.push(error_msg)
			    end 			
			}
		params[:cat_percent].each{|k,v|
			#Rails.logger.debug("ssssssss____#{k}____#{@pattern.id}")
			pc=KpiPatternCategory.where(:kpi_category_id => k, :kpi_pattern_id => @pattern.id).first
			pc.percent=v
			pc.save
			}
		get_integrity_warnings

		respond_to do |format|
			 format.js { render 'indicators' }
		end
	end

	def remove_indicator
	    #@pattern = KpiPattern.find(params[:id])
	    #@pattern.indicators.delete(Indicator.find(params[:indicator_id])) if request.delete?
	    KpiPatternIndicator.find(params[:indicator_id]).destroy if request.delete?
	    get_integrity_warnings
		respond_to do |format|
			 format.js { render 'indicators' }
		end
	end


	def autocomplete_for_user
	    #@pattern = KpiPattern.find(params[:id])
	    @users = User.active.not_in_kpi_pattern(@pattern).like(params[:q]).all(:limit => 100)
	    render 'groups/autocomplete_for_user', :layout => false
	end

	def autocomplete_for_indicator
	    #@pattern = KpiPattern.find(params[:id])
	    @indicators = Indicator.not_in_kpi_pattern(@pattern).where("name like ?", "%#{params[:q]}%").limit(100)
	    render 'kpi_patterns/autocomplete_for_indicator', :layout => false
	end	

	private

	def get_pattern
		@indicator_save_errors=[]
		@kpi_warnings=[]
		@pattern = KpiPattern.find(params[:id])
	end 

	def get_integrity_warnings
		if(@pattern.integrity?)
			if ! @pattern.integrity
				@pattern.integrity=true
				@pattern.save
			end
		else
			@kpi_warnings.push('indicators_weight_sum_not_equal_100') 
			if @pattern.integrity
				@pattern.integrity=false
				@pattern.save
			end
		end
	end

	def find_patterns
	 	@patterns=KpiPattern.order(:name)
	end

	def find_category_weights
		@category_weights={}
		@pattern.kpi_pattern_categories.each{|e|
			@category_weights[e.kpi_category_id.to_s]=e.percent
			#Rails.logger.debug("ssssssss #{e.kpi_category_id.to_s} #{e.percent}")
			}
	end

end