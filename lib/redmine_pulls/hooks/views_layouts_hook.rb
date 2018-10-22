module RedminePulls
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        return stylesheet_link_tag(:pulls, :plugin => 'redmine_pulls')
      end
    end
  end
end
