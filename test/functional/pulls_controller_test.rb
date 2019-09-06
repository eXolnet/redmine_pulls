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

    Repository.any_instance.stubs(:default_branch).returns('master')
  end

  def test_get_index_without_project
    compatible_request :get, :index

    assert_response :success
  end

  def test_get_index_with_project
    compatible_request :get, :index, :project_id => 'ecookbook'

    assert_response :success
  end

  def test_get_new_with_pull_request_template
    Repository.any_instance.stubs(:cat).returns('Pull request template example')

    compatible_request :get, :new, :project_id => 'ecookbook'

    assert_response :success
    assert_select '#pull_description', :text => /Pull request template example/
  end

  #def test_show_with_repository
  #  compatible_request get, :show, :id => 1
  #
  #  assert_response :success
  #  assert_select '#content .warning', false, :text => /This pull request’s repository is missing/
  #end

  def test_show_with_repository_deleted
    compatible_request :get, :show, :id => 2

    assert_response :success
    assert_select '#content .warning', :text => /This pull request’s repository is missing/
  end
end
