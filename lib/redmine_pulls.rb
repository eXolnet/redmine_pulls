require_dependency 'redmine_pulls/helpers/pulls_helper'
require_dependency 'redmine_pulls/helpers/routes_helper'

Rails.configuration.to_prepare do
  require 'redmine_pulls/patches/journal_patch'
end

module RedminePulls
end
