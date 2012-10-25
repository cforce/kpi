module KpiPatternsHelper
  def kpi_patterns_settings_tabs
    tabs = [{:name => 'users', :partial => 'kpi_patterns/users', :label => :label_assigned_list},
    		{:name => 'indicators', :partial => 'kpi_patterns/indicators', :label => :label_kpi_indicators},
            {:name => 'general', :partial => 'kpi_patterns/general', :label => :label_general}
           
            ]
  end


  def indicators_check_box_tags(name, indicators)
    s = ''
    indicators.sort.each do |indicator|
      s << "<label>#{ check_box_tag name, indicator.id, false } #{h indicator}</label>\n"
    end
    s.html_safe
  end
end