Rails.configuration.to_prepare do
  require 'redmine_pulls/patches/application_helper_patch'
  require 'redmine_pulls/patches/journal_patch'
  require 'redmine_pulls/patches/queries_helper_patch'
end

module RedminePulls
end
