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

	# def user_marks
		
	# end

	def show_for_offer
		@marks_for_offer = KpiMark.get_mark_for_offer(params[:user_id])

    respond_to do |format|
      format.js {
       render "show_for_offer"
       }
    end
	end


	def disable
		@user = @mark.user
		@period=@mark.kpi_indicator_inspector.kpi_period_indicator.kpi_period_category.kpi_calc_period
		period_user = @period.kpi_period_users.where(:user_id => @user.id).first
		@mark.disabled=true
		@mark.save if @mark.can_be_disabled?(@user, @period)
	
        respond_to do |format|
          #format.html { redirect_to :controller => 'groups', :action => 'edit', :id => @group, :tab => 'relations' }
          format.js {
          	render "kpi/effectiveness"
          	}
        end

	    # respond_to do |format|
	    #   format.js {
	    #     render(:update) {|page|
	    #       page.replace_html "calc_period_#{period.id}", :partial => 'kpi/period_effectiveness', :locals => { :period => period, :i => period.id } 
	    #       page.call :portable_data_apply
	    #       # users.each {|user| page.visual_effect(:highlight, "user-#{user.id}") }
	    #     }
	    #   }
	    # end
	end


	def enable
		@user = @mark.user
		@period=@mark.kpi_indicator_inspector.kpi_period_indicator.kpi_period_category.kpi_calc_period
		period_user = @period.kpi_period_users.where(:user_id => @user.id).first
		@mark.disabled=false
		@mark.save if @mark.can_be_disabled?(@user, @period)
	
        respond_to do |format|
          #format.html { redirect_to :controller => 'groups', :action => 'edit', :id => @group, :tab => 'relations' }
          format.js {
          	render "kpi/effectiveness"
          	}
        end
	end

	def show_info
		@period_indicator = @mark.kpi_period_indicator
		render_403 unless @mark.check_user_for_info_showing?
		render "show_info", :layout => false
	end

	def update_user_marks
		marks = KpiMark.find(params[:explanation].map{|k, v| k})

		marks.each{|mark|
			mark.fact_value=params[:mark][mark.id.to_s]
			mark.explanation=params[:explanation][mark.id.to_s]
			mark.disabled=params[:disabled][mark.id.to_s] if mark.can_be_disabled?(mark.user)
			mark.save if mark.check_user_for_fact_update		
			}	
		find_marks
		#should be optimized

	    respond_to do |format|
          format.js
	    end
	end

	def update_plan
		@user = @mark.user
		#user_id = params[:kpi_mark][:user_id] || params[:user_id]
		@period=@mark.kpi_indicator_inspector.kpi_period_indicator.kpi_period_category.kpi_calc_period
		@mark.plan_value=params[:kpi_mark][:plan_value]
		@mark.save if @mark.check_user_for_plan_update

	    respond_to do |format|
          format.js {
          	render "kpi/effectiveness"
          	}
	    end
	end

	def edit_fact
		@user = @mark.user
		render "edit_fact", :layout => false
	end

	def update_fact
		@user = @mark.user
		@period=@mark.kpi_indicator_inspector.kpi_period_indicator.kpi_period_category.kpi_calc_period
		@mark.fact_value=params[:kpi_mark][:fact_value]
		@mark.explanation=params[:kpi_mark][:explanation]
		@mark.save if @mark.check_user_for_fact_update
	
	    respond_to do |format|
          format.js {
          	render "kpi/effectiveness"
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
		@marks = User.current.get_my_marks.joins(:user).where("start_date >= ? AND end_date <= ?", @date, @date.at_end_of_month).includes(:user => :user_tree, :kpi_indicator_inspector => [{:kpi_period_indicator => [:indicator => :kpi_unit]}]).order("#{User.table_name}.lastname", :end_date)
		@estimated_users = @marks.map{|m| m.user}.uniq
		@user_mark_counts = {}

		@marks.each do |m|
			@user_mark_counts[m.user] = 0 if @user_mark_counts[m.user].nil?
			@user_mark_counts[m.user]+=1 if m.fact_value.nil? and not m.disabled
			end

		curent_user_lft = User.current.user_tree.lft
		curent_user_rgt = User.current.user_tree.rgt

		@subordinated_estimated_users = @marks.inject([]){|u,v| u<<v.user if curent_user_lft<v.user.user_tree.lft and curent_user_rgt>v.user.user_tree.rgt; u }.uniq
		@not_subordinated_estimated_users = @estimated_users - @subordinated_estimated_users
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