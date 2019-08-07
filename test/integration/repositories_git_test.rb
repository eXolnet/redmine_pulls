require File.expand_path('../../test_helper', __FILE__)

class RepositoriesGitTest < RedminePulls::IntegrationTest
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

  REPOSITORY_PATH = Rails.root.join('tmp/test/git_repository').to_s
  REPOSITORY_PATH.gsub!(/\//, "\\") if Redmine::Platform.mswin?

  def setup
    @project    = Project.find(3)
    @repository = Repository::Git.create(
                      :project       => @project,
                      :url           => REPOSITORY_PATH,
                      :path_encoding => 'ISO-8859-1'
                      )

    EnabledModule.create(:project => @project, :name => 'pulls')

    assert @repository
  end

  if File.directory?(REPOSITORY_PATH)
    def test_create_pull_request
      # Login as an admin user
      log_user("admin", "admin")

      # Navigate to the new pull page
      compatible_request :get, '/projects/subproject1/pulls/new'
      assert_response :success

      # Post the pull creation page with valid informations
      pull = new_record(Pull) do
        compatible_request :post, '/projects/subproject1/pulls', :params => {
          :pull => {
            :commit_base => "master",
            :commit_head => "test-latin-1",
            :subject => "new test pull",
            :priority_id => "4"
          }
        }
      end

      # Check redirection
      assert_redirected_to :controller => 'pulls', :action => 'show', :id => pull
      follow_redirect!

      # Check issue attributes
      assert_equal 'admin', pull.author.login
      assert_equal 'opened', pull.status
      assert_equal 3, pull.project.id
    end
  end
end
