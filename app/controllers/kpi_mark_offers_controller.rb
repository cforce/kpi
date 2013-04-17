class KpiMarkOffersController < ApplicationController
  #before_filter get_marks_for_offer, :only => [:create]

  helper :kpi
  include KpiHelper

  def mark_offers
    @mark = KpiMark.find(params[:mark_id])
    render "mark_offers", :layout => false
  end

  def index
    @mark_offers = KpiMarkOffer.includes([:user, {:kpi_mark => {:kpi_period_indicator => :indicator}}]).where(:author_id => User.current.id).order("created_at DESC").limit(20)
  end

  def new
    @mark_offer = KpiMarkOffer.new
  end

  def edit
    @mark_offer = KpiMarkOffer.find(params[:id])
    get_marks_for_offer
  end

  def destroy
    @mark_offer = KpiMarkOffer.find(params[:id])
    @mark_offer.destroy
    if @mark_offer.errors.any?
      flash[:error] = @mark_offer.errors.full_messages.join("<br>").html_safe
      redirect_to :action => 'index'
    else
       redirect_to :action => 'index'
    end
  end

  def update
    @mark_offer = KpiMarkOffer.find(params[:id])
      if request.put? and @mark_offer.update_attributes(params[:kpi_mark_offer])
        flash[:notice] = l(:notice_successful_update)
        redirect_to :action => 'index'
        return
      end
    get_marks_for_offer
    render :action => 'edit'
  end

  def create
    @mark_offer = KpiMarkOffer.new(params[:kpi_mark_offer])
    @mark_offer.author_id = User.current.id

    get_marks_for_offer
    if request.post? and @mark_offer.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'new'
    else
      render :action => 'new'
    end
  end

  private
  def get_marks_for_offer
    @marks_for_offer = KpiMark.get_mark_for_offer(@mark_offer.user_id) unless @mark_offer.user_id.nil? 
  end
end