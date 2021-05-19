require_dependency 'queries_helper'

module RedminePulls
  module Patches
    module QueriesHelperPatch
      extend ActiveSupport::Concern

      included do
        include InstanceMethods

        alias_method :column_value_without_pulls, :column_value
        alias_method :column_value, :column_value_with_pulls
      end

      module InstanceMethods
        def column_value_with_pulls(column, item, value)
          if item.is_a?(Pull)
            if [:id, :subject].include? column.name
              return link_to_pull item, :text => value
            end
          end

          column_value_without_pulls(column, item, value)
        end
      end
    end
  end
end

unless QueriesHelper.included_modules.include?(RedminePulls::Patches::QueriesHelperPatch)
  QueriesHelper.send(:include, RedminePulls::Patches::QueriesHelperPatch)
end
