# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :projects do
  resources :pulls
end

get '/projects/:project_id/pulls', :to => 'pulls#index'