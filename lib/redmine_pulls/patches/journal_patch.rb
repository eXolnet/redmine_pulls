require_dependency 'journal'

module RedminePulls
  module Patches
    module JournalPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development

          belongs_to :pull, :foreign_key => :journalized_id
        end
      end

      module InstanceMethods
        #
      end
    end
  end
end

unless Journal.included_modules.include?(RedminePulls::Patches::JournalPatch)
  Journal.send(:include, RedminePulls::Patches::JournalPatch)
end
