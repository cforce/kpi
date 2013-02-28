module KpiCalcPeriodsHelper
  def kpi_periods_settings_tabs
    tabs = [{:name => 'general', :partial => 'kpi_calc_periods/general', :label => :label_general},
            {:name => 'users', :partial => 'kpi_calc_periods/users', :label => :label_inspector_list},
            {:name => 'plan_values', :partial => 'kpi_calc_periods/plan_values', :label => :label_plan_values},
            {:name => 'apply_to', :partial => 'kpi_calc_periods/apply_to', :label => :label_assigned_list},
            {:name => 'managers', :partial => 'kpi_calc_periods/managers', :label => :label_managers},
            {:name => 'salary', :partial => 'kpi_calc_periods/salary', :label => :label_salary_calc}
          ]
  end


  def indicators_check_box_tags(name, indicators)
    s = ''
    indicators.sort.each do |indicator|
      s << "<label>#{ check_box_tag name, indicator.id, false } #{h indicator}</label>\n"
    end
    s.html_safe
  end

  def period_css_class(period)
    return 'locked' if(period.locked)
    return 'active' if(period.active)
    return 'not_active'
  end
end