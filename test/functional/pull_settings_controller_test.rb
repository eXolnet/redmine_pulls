require File.expand_path('../../test_helper', __FILE__)

class PullSettingsControllerTest < ActionController::TestCase
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
    @project = Project.find(1)
    EnabledModule.create(:project => @project, :name => 'pulls')
    @request.session[:user_id] = 1

    #Repository.any_instance.stubs(:default_branch).returns('master')
  end

  def test_update_without_any_parameters
    post :update, :project_id => 'ecookbook'

    assert_redirected_to :controller => 'projects', :action => 'settings', :id => 'ecookbook', :tab => 'pulls'
    assert_match(/Successful update/, flash[:notice])
  end

  def test_update_default_branch
    post :update, :project_id => 'ecookbook', :params => {
        :Repository => {
          :pull_defaukt_repository => 'develop'
        }
      }

    assert_redirected_to :controller => 'projects', :action => 'settings', :id => 'ecookbook', :tab => 'pulls'
    assert_match(/Successful update/, flash[:notice])
  end
end
