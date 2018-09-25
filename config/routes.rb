# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

match '/pulls/preview/new/:project_id', :to => 'pulls#preview', :as => 'preview_new_pull', :via => [:get, :post, :put, :patch]
match '/pulls/preview/edit/:id', :to => 'pulls#preview', :as => 'preview_edit_pull', :via => [:get, :post, :put, :patch]

resources :projects do
  resources :pulls, :only => [:index, :new, :create]
end

resources :pulls do
  get 'reviewers/autocomplete_for_user', :to => 'pull_reviewers#autocomplete_for_user'
  resources :reviewers, :controller => 'pull_reviewers', :only => [:new, :create]
  delete 'reviewers', :to => 'pull_reviewers#destroy'
end
