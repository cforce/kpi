module Kpi
  module Kpi
    class Hooks  < Redmine::Hook::ViewListener
      render_on(:view_account_left_bottom, :partial => "hooks/users/user_effectiveness")
    end
  end
end