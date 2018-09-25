module PullReviewersHelper
  # Returns a comma separated list of users watching the given object
  def reviewers_list(pull)
    remove_allowed = User.current.allowed_to?(:edit_pulls, pull.project)
    content = ''.html_safe
    lis = pull.reviews.preload(reviewer: [ :email_address ]).collect do |review|
      user = review.reviewer

      s = ''.html_safe
      s << content_tag('div', s, :class => "review-status review-status--" + review.status)
      s << avatar(user, :size => "16").to_s
      s << link_to_user(user, :class => 'user')
      if remove_allowed
        url = {:controller => 'pull_reviewers',
               :action => 'destroy',
               :pull_id => pull,
               :user_id => user}
        s << ' '
        s << link_to(l(:button_delete), url,
                     :remote => true, :method => 'delete',
                     :class => "delete icon-only icon-del",
                     :title => l(:button_delete)) if pull.reviewable? && review.status == PullReview::STATUS_REQUESTED
      end
      content << content_tag('li', s, :class => "user-#{user.id}")
    end
    content.present? ? content_tag('ul', content, :class => 'pull_reviewers') : content
  end
end
