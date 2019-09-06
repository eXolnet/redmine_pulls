module RedminePulls
  module Hooks
    class DisplayPullStatisticsInUserProfile < Redmine::Hook::ViewListener
      render_on :view_account_left_bottom, :partial => 'users/pull_statistics'
    end
  end
end
