
class KpiPatternsController < ApplicationController

	before_filter :find_patterns, :only => [:index]



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
		@pattern ||= KpiPattern.find(params[:id])
	end

	def update
	    @pattern = KpiPattern.find(params[:id])
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
		    redirect_to(edit_kpi_pattern_path(@pattern))
		else
		    render :action => 'new'

		end
    end

	def destroy
	    @pattern = KpiPattern.find(params[:id])
	    #unless @tracker.issues.empty?
	    #  flash[:error] = l(:error_can_not_delete_tracker)
	    #else
	      @pattern.destroy
	    #end
	    redirect_to :action => 'index'
	end    

	def add_users
	    @pattern = KpiPattern.find(params[:id])
	    users = User.find_all_by_id(params[:user_ids])
	    @pattern.users << users if request.post?
	    respond_to do |format|
	      format.html { redirect_to :controller => 'kpi_patterns', :action => 'edit', :id => @pattern, :tab => 'users' }
	      format.js {
	        render(:update) {|page|
	          page.replace_html "tab-content-users", :partial => 'kpi_patterns/users'
	          users.each {|user| page.visual_effect(:highlight, "user-#{user.id}") }
	        }
	      }
	    end
	end

	def remove_user
	    @pattern = KpiPattern.find(params[:id])
	    @pattern.users.delete(User.find(params[:user_id])) if request.delete?
	    respond_to do |format|
	      format.html { redirect_to :controller => 'groups', :action => 'edit', :id => @pattern, :tab => 'users' }
	      format.js { render(:update) {|page| page.replace_html "tab-content-users", :partial => 'kpi_patterns/users'} }
	    end
	end

	def add_indicators
	    @pattern = KpiPattern.find(params[:id])
	    indicators = Indicator.find_all_by_id(params[:indicator_ids])
	    @pattern.indicators << indicators if request.post?
	    respond_to do |format|
	      format.html { redirect_to :controller => 'kpi_patterns', :action => 'edit', :id => @pattern, :tab => 'indicators' }
	      format.js {
	        render(:update) {|page|
	          page.replace_html "tab-content-indicators", :partial => 'kpi_patterns/indicators'
	          indicators.each {|indicator| page.visual_effect(:highlight, "indicator-#{indicator.id}") }
	        }
	      }
	    end
	end

	def remove_indicator
	    @pattern = KpiPattern.find(params[:id])
	    @pattern.indicators.delete(Indicator.find(params[:indicator_id])) if request.delete?
	    respond_to do |format|
	      format.html { redirect_to :controller => 'kpi_patterns', :action => 'edit', :id => @pattern, :tab => 'indicators' }
	      format.js { render(:update) {|page| page.replace_html "tab-content-indicators", :partial => 'kpi_patterns/indicators'} }
	    end
	end


	def autocomplete_for_user
	    @pattern = KpiPattern.find(params[:id])
	    @users = User.active.not_in_kpi_pattern(@pattern).like(params[:q]).all(:limit => 100)
	    render 'groups/autocomplete_for_user', :layout => false
	end

	def autocomplete_for_indicator
	    @pattern = KpiPattern.find(params[:id])
	    @indicators = Indicator.not_in_kpi_pattern(@pattern).where("name like ?", "%#{params[:q]}%").limit(1)
	    render 'kpi_patterns/autocomplete_for_indicator', :layout => false
	end	

	private

	def find_patterns
	 	@patterns=KpiPattern.order(:name)
	end

end