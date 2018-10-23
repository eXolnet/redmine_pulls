$VERBOSE = nil # for hide ruby warnings

require 'minitest/autorun'

if ENV["REDMINE_PULLS_COVERAGE"]
  require 'simplecov'

  SimpleCov.root(File.expand_path(File.dirname(__FILE__) + '/..'))

  SimpleCov.start 'rails' do
    add_filter do |src|
      ! src.filename.include? "/redmine_pulls/"
    end
  end
end

# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

# Enable project fixtures
ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/', [:pulls])
