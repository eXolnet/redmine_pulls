require File.expand_path('../../test_helper', __FILE__)

class PullsControllerTest < ActionController::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :enabled_modules,
           :repositories,
           :changesets,
           :changes

  def setup
    @project1 = Project.find(1)
    @project2 = Project.find(5)
    EnabledModule.create(:project => @project1, :name => 'pulls')
    EnabledModule.create(:project => @project2, :name => 'pulls')
    @request.session[:user_id] = 1
  end

  def test_example
    assert true
  end
end
