RedmineApp::Application.routes.draw do
	resources :indicators
	resources :kpi_patterns
	resources :kpi_calc_periods
	match 'kpi', :controller => 'kpi', :action => 'index', :via => [:get]
	match 'kpi/marks', :controller => 'kpi', :action => 'marks', :via => [:get]

	match 'indicators/:copy_from/copy', :to => 'indicators#new'
	match 'kpi_patterns/:id/users', :controller => 'kpi_patterns', :action => 'add_users', :id => /\d+/, :via => :post, :as => 'kpi_patters_users'
	match 'kpi_patterns/:id/users/:user_id', :controller => 'kpi_patterns', :action => 'remove_user', :id => /\d+/, :via => :delete, :as => 'kpi_pattern_user'
	match 'kpi_patterns/:id/indicators', :controller => 'kpi_patterns', :action => 'add_indicators', :id => /\d+/, :via => :post, :as => 'kpi_patters_indicators'
	match 'kpi_patterns/:id/update_indicators', :controller => 'kpi_patterns', :action => 'update_indicators', :id => /\d+/, :via => :post, :as => 'kpi_patterns_indicators_edit'
	match 'kpi_patterns/:id/indicators/:indicator_id', :controller => 'kpi_patterns', :action => 'remove_indicator', :id => /\d+/, :via => :delete, :as => 'kpi_pattern_indicator'
	match 'kpi_patterns/:copy_from/copy', :to => 'kpi_patterns#edit'

	resources :kpi_patterns do
	    member do
	      get 'autocomplete_for_user'
	      get 'autocomplete_for_indicator'
	    end
	end

	resources :kpi_calc_periods do
	    member do
	      post 'add_inspectors'
	      get 'autocomplete_for_user'
	      get 'activate'
	      delete 'remove_inspector/:indicator_inspector_id', :action => 'remove_inspector', :as => 'remove_inspector'
	      post 'update_inspectors', :action => 'update_inspectors', :as => 'update_inspectors'
	      post 'update_plans', :action => 'update_plans', :as => 'update_plans'
	    end
	end

end


# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
