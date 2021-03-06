
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

  menu :top_menu, :my_marks, { :controller => 'kpi_marks', :action => 'index' }, :caption => Proc.new { User.current.my_kpi_marks_caption },  :if => Proc.new { User.current.logged? }, :first => true
  project_module :kpi do
    permission :manage_kpi_indicators, :indicators => [:index, :update, :new, :edit, :create, :destroy]
    permission :manage_kpi_periods, :kpi_calc_periods => [:index, :new, :edit, :close_for_user, :reopen_for_user, :activate, :update, :create, :destroy, :autocomplete_for_user, :add_inspectors, :remove_inspector, :update_plans, :update_inspectors]
    permission :manage_kpi_patterns, :kpi_patterns => [:index, :update, :new, :edit, :create, :destroy, :add_users, :remove_user, :add_indicators, :update_indicators, :remove_indicator, :autocomplete_for_user, :autocomplete_for_indicator]
    permission :update_plan_values, :kpi_marks => [:edit_plan, :update_plan]
    permission :update_fact_values, :kpi_marks => [:edit_fact, :update_fact]
    permission :show_effectiveness, :kpi => [:effectiveness]
    permission :update_imported_values, :kpi_imported_values => [:edit_values, :update_values, :create, :update, :destroy, :new]
  end
	settings :partial => 'settings/kpi_settings',
             :default => {
              "user_superior_id_field" => "parent_id",
              "executor_id_issue_field" => "executor_id",
              "max_kpi" => 120,
              "min_kpi" => 80,
              "check_date_issue_field" => "check_date",
              "auto_activating_date" => 2,
              "user_tree_table_name" => "user_trees",
              "initial_user_id" => 80,
             }, :partial => 'kpi/settings' 
end

Rails.application.config.to_prepare do
	User.send(:include, Kpi::UserPatch)
  CustomField.send(:include, Kpi::CustomFieldPatch)
  CustomFieldsHelper.send(:include, Kpi::CustomFieldsHelperPatch)
  Project.send(:include, Kpi::ProjectPatch)
end

require 'kpi/view_hooks'
