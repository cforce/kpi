module KpiPatternsHelper
  def kpi_patterns_settings_tabs
    tabs = [{:name => 'users', :partial => 'kpi_patterns/users', :label => :label_assigned_list},
    		{:name => 'indicators', :partial => 'kpi_patterns/indicators', :label => :label_kpi_indicators},
            {:name => 'general', :partial => 'kpi_patterns/general', :label => :label_general}
           
            ]
  end
end