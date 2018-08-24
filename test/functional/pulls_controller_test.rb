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
    EnabledModule.create(:project => @project1, :name => 'pull_requests')
    EnabledModule.create(:project => @project2, :name => 'pull_requests')
    @request.session[:user_id] = 1
  end

  def test_get_index
    get :index, :project_id => "ecookbook"
    assert_response :success
    assert_template :index
  end

  def test_get_create
    get :create, :project_id => "ecookbook"
    assert_response :success
    assert_template :new
  end
end
