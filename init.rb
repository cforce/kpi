
  Redmine::CustomFieldFormat.map do |fields|
    fields.register KpiMarkCustomFieldFormat.new('kpi_mark', :label => :label_kpi_mark, :only => %w(Issue))
  end 


Redmine::Plugin.register :kpi do
  name 'Kpi plugin'
  author 'Pitin Vladimir Vladimirovich'
  description ''
  version '0.0.1'
  url 'http://pitin.su'
  author_url 'http://pitin.su'

  menu :top_menu, :my_marks, { :controller => 'kpi', :action => 'marks' }, :caption => Proc.new { User.current.my_kpi_marks_caption },  :if => Proc.new { User.current.logged? }, :first => true
  project_module :kpi do
    permission :manage_kpi_indicators, :indicators => [:index, :update, :new, :edit, :create, :destroy]
    permission :manage_kpi_periods, :kpi_calc_periods => [:index, :new, :edit, :activate, :update, :create, :destroy, :autocomplete_for_user, :add_inspectors, :remove_inspector, :update_plans, :update_inspectors]
    permission :manage_kpi_patterns, :kpi_patterns => [:index, :update, :new, :edit, :create, :destroy, :add_users, :remove_user, :add_indicators, :update_indicators, :remove_indicator, :autocomplete_for_user, :autocomplete_for_indicator]
    permission :update_plan_values, :kpi_marks => [:edit_plan, :update_plan]
    permission :update_fact_values, :kpi_marks => [:edit_fact, :update_fact]
  end
	settings :partial => 'settings/kpi_settings',
             :default => {
              "user_superior_id_field" => "parent_id",
              "executor_id_issue_field" => "executor_id"
             }    
end

Rails.application.config.to_prepare do
	User.send(:include, Kpi::UserPatch)
  CustomField.send(:include, Kpi::CustomFieldPatch)
  CustomFieldsHelper.send(:include, Kpi::CustomFieldsHelperPatch)
end

require 'kpi/view_hooks'
