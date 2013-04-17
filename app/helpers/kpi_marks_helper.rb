module KpiMarksHelper
  def show_mark_offer_totals(mark)
    s = ''
    i = 0
    mark.get_mark_offer_totals.each do |k, v|
      s << '<div class="H" style="padding-bottom: 2px;"><div class="H">' if i == 0 
      s << "<div class=\"L #{k>0 ? 'praise' : 'complain'}\">&mdash; #{v.abs.to_i}&nbsp;</div>".html_safe
      i+=1
    end
    s << '</div><div><nobr>'+link_to_modal_window(l(:watch_all_mark_offers), {:controller => 'kpi_mark_offers', :action=> 'mark_offers', :mark_id => mark.id}, {:class => 'click_out'})+'</nobr></div>' if i>0
    s << '</div>' if i>0
    s.html_safe
  end
end