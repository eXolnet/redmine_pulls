require File.expand_path('../../test_helper', __FILE__)

class PullTest < ActiveSupport::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :enabled_modules,
           :enumerations,
           :repositories,
           :changesets,
           :changes

  def teardown
    User.current = nil
  end

  def test_initialize
    pull = Pull.new

    assert_nil pull.project_id
    assert_nil pull.repository_id
    assert_nil pull.author_id
    assert_nil pull.assigned_to_id
    assert_nil pull.fixed_version_id
    assert_nil pull.category_id
    assert_nil pull.merge_user_id

    assert_equal 'opened', pull.status
    assert_equal 'unreviewed', pull.review_status
    assert_equal 'unchecked', pull.merge_status
  end

  def test_create
    assert true
  end

  def test_create_minimal
    pull = Pull.new(:project_id => 1,
                    :repository_id => 10,
                    :author_id => 1,
                    :commit_base => 'master',
                    :commit_base_revision => 'cf291599d4e280ba7c6f30481ae401c29a715f50',
                    :commit_head => 'develop',
                    :commit_head_revision => 'd24335d81240b6f1b98fb0a1b4fe8bb91bab7a83',
                    :subject => 'Example pull request')

    pull.repository.stub :branches, ['master', 'develop'] do
      assert pull.save
    end

    pull.reload

    assert_equal IssuePriority.default.id, pull.priority_id
    assert_equal 'master', pull.commit_base
    assert_equal 'develop', pull.commit_head
  end

  def test_head_branch_should_be_validated
    pull = Pull.new(:project_id => 1,
                    :repository_id => 10,
                    :author_id => 1,
                    :commit_base => 'master',
                    :commit_base_revision => 'cf291599d4e280ba7c6f30481ae401c29a715f50',
                    :commit_head => 'develop',
                    :commit_head_revision => 'd24335d81240b6f1b98fb0a1b4fe8bb91bab7a83',
                    :subject => 'Example pull request')

    pull.repository.stub :branches, ['develop'] do
      assert_not pull.save
    end
  end

  def test_commit_base_revision_should_be_validated
    pull = Pull.new(:project_id => 1,
                    :repository_id => 10,
                    :author_id => 1,
                    :commit_base => 'master',
                    :commit_base_revision => nil,
                    :commit_head => 'develop',
                    :commit_head_revision => 'd24335d81240b6f1b98fb0a1b4fe8bb91bab7a83',
                    :subject => 'Example pull request')

    pull.repository.stub :branches, ['master', 'develop'] do
      assert_not pull.save
    end
  end

  def test_commit_head_revision_should_be_validated
    pull = Pull.new(:project_id => 1,
                    :repository_id => 10,
                    :author_id => 1,
                    :commit_base => 'master',
                    :commit_base_revision => 'cf291599d4e280ba7c6f30481ae401c29a715f50',
                    :commit_head => 'develop',
                    :commit_head_revision => nil,
                    :subject => 'Example pull request')

    pull.repository.stub :branches, ['master', 'develop'] do
      assert_not pull.save
    end
  end

  def test_create_with_group_assignment
    pull = Pull.new(:project_id => 1,
                    :repository_id => 10,
                    :author_id => 1,
                    :commit_base => 'master',
                    :commit_base_revision => 'cf291599d4e280ba7c6f30481ae401c29a715f50',
                    :commit_head => 'develop',
                    :commit_head_revision => 'd24335d81240b6f1b98fb0a1b4fe8bb91bab7a83',
                    :subject => 'Example pull request',
                    :assigned_to_id => 11)

    pull.repository.stub :branches, ['master', 'develop'] do
      assert pull.save
    end

    pull.reload

    assert_kind_of Group, pull.assigned_to
    assert_equal Group.find(11), pull.assigned_to
  end
end
