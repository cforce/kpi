RedmineApp::Application.routes.draw do
	resources :indicators
	resources :kpi_patterns
	match 'kpi', :controller => 'kpi', :action => 'index', :via => [:get]
	match 'indicators/:copy_from/copy', :to => 'indicators#new'
	match 'kpi_patterns/:id/users', :controller => 'kpi_patterns', :action => 'add_users', :id => /\d+/, :via => :post, :as => 'kpi_patters_users'
	match 'kpi_patterns/:id/users/:user_id', :controller => 'kpi_patterns', :action => 'remove_user', :id => /\d+/, :via => :delete, :as => 'kpi_pattern_user'
	resources :kpi_patterns do
	    member do
	      get 'autocomplete_for_user'
	    end
	end
end


# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
