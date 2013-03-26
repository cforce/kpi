module Kpi
  module Kpi
    class Hooks  < Redmine::Hook::ViewListener
      render_on(:view_account_left_bottom, :partial => "hooks/users/user_effectiveness")
      render_on(:view_custom_fields_form_issue_custom_field, :partial => "hooks/custom_fields/custom_fields_js")
      render_on(:view_layouts_base_html_head, :partial => "hooks/kpi/html_head_js")
    end
  end
end