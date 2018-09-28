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

  def test_create_minimal
    pull = Pull.new(:project_id => 1,
                    :repository_id => 1,
                    :author_id => 1,
                    :commit_base => 'master',
                    :commit_head => 'develop',
                    :subject => 'Example pull request')

    assert pull.save
    pull.reload

    assert_equal IssuePriority.default.id, pull.priority_id
    assert_equal 'master', pull.commit_base
    assert_equal 'develop', pull.commit_head
  end
end
