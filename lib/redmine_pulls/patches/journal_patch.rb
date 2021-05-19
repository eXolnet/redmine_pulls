require_dependency 'journal'

module RedminePulls
  module Patches
    module JournalPatch
      extend ActiveSupport::Concern

      included do
        belongs_to :pull, :foreign_key => :journalized_id

        acts_as_activity_provider :type => 'pulls',
                                  :author_key => :user_id,
                                  :scope => preload({:issue => :project}, :user).
                                    joins("LEFT OUTER JOIN #{JournalDetail.table_name} ON #{JournalDetail.table_name}.journal_id = #{Journal.table_name}.id").
                                    where("#{Journal.table_name}.journalized_type = 'Pull' AND" +
                                            " (#{Journal.table_name}.notes <> '')").distinct
      end
    end
  end
end

unless Journal.included_modules.include?(RedminePulls::Patches::JournalPatch)
  Journal.send(:include, RedminePulls::Patches::JournalPatch)
end
