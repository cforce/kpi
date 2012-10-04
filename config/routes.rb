RedmineApp::Application.routes.draw do
	resources :indicators
	resources :kpi_patterns
	match 'kpi', :controller => 'kpi', :action => 'index', :via => [:get]
	match 'indicators/:copy_from/copy', :to => 'indicators#new'
	match 'kpi_patterns/:id/users', :controller => 'kpi_patterns', :action => 'add_users', :id => /\d+/, :via => :post, :as => 'kpi_patters_users'
	match 'kpi_patterns/:id/users/:user_id', :controller => 'kpi_patterns', :action => 'remove_user', :id => /\d+/, :via => :delete, :as => 'kpi_pattern_user'
	match 'kpi_patterns/:id/indicators', :controller => 'kpi_patterns', :action => 'add_indicators', :id => /\d+/, :via => :post, :as => 'kpi_patters_indicators'
	match 'kpi_patterns/:id/indicators/:indicator_id', :controller => 'kpi_patterns', :action => 'remove_indicator', :id => /\d+/, :via => :delete, :as => 'kpi_pattern_indicator'
	match 'kpi_patterns/:copy_from/copy', :to => 'kpi_patterns#edit'
	resources :kpi_patterns do
	    member do
	      get 'autocomplete_for_user'
	      get 'autocomplete_for_indicator'
	    end
	end

end


# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
