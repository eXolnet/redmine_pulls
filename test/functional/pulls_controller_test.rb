require File.expand_path('../../test_helper', __FILE__)

class PullsControllerTest < ActionController::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :enabled_modules,
           :enumerations,
           :repositories,
           :changesets,
           :changes,
           :pulls

  def setup
    @project1 = Project.find(1)
    @project2 = Project.find(5)
    EnabledModule.create(:project => @project1, :name => 'pulls')
    EnabledModule.create(:project => @project2, :name => 'pulls')
    @request.session[:user_id] = 1
  end

  def test_get_index_without_project
    get :index

    assert_response :success
  end

  def test_get_index_with_project
    get :index, :project_id => 'ecookbook'

    assert_response :success
  end

  #def test_show_with_repository
  #  get :show, :id => 1
  #
  #  assert_response :success
  #  assert_select '#content .warning', false, :text => /This pull request’s repository is missing/
  #end
end
