RedmineApp::Application.routes.draw do
	resources :indicators
	resources :kpi_patterns
	#resources :kpi_calc_periods
	#match 'kpi', :controller => 'kpi', :action => 'index', :via => [:get]
	#match 'kpi/marks', :controller => 'kpi', :action => 'marks', :via => [:get]
	resources :kpi do
		collection do
			#get '/', :action => 'index'
			#get 'marks'
			#get 'marks/:date', :action => 'marks'
			get 'effectiveness'
			get 'effectiveness/:date', :action => 'effectiveness'
			get 'effectiveness/:date/:user_id', :action => 'effectiveness'
		end
	end

	match 'indicators/:copy_from/copy', :to => 'indicators#new'
	match 'kpi_patterns/:id/users', :controller => 'kpi_patterns', :action => 'add_users', :id => /\d+/, :via => :post, :as => 'kpi_patters_users'
	match 'kpi_patterns/:id/users/:user_id', :controller => 'kpi_patterns', :action => 'remove_user', :id => /\d+/, :via => :delete, :as => 'kpi_pattern_user'
	match 'kpi_patterns/:id/indicators', :controller => 'kpi_patterns', :action => 'add_indicators', :id => /\d+/, :via => :post, :as => 'kpi_patters_indicators'
	match 'kpi_patterns/:id/update_indicators', :controller => 'kpi_patterns', :action => 'update_indicators', :id => /\d+/, :via => :post, :as => 'kpi_patterns_indicators_edit'
	match 'kpi_patterns/:id/indicators/:indicator_id', :controller => 'kpi_patterns', :action => 'remove_indicator', :id => /\d+/, :via => :delete, :as => 'kpi_pattern_indicator'
	match 'kpi_patterns/:copy_from/copy', :to => 'kpi_patterns#edit'

	resources :kpi_marks do
	    member do
	      get 'edit_plan/:user_id', :action => 'edit_plan'
	      post 'update_plan/:user_id', :action => 'update_plan'
	      get 'edit_fact/:user_id', :action => 'edit_fact'
	      post 'update_fact/:user_id', :action => 'update_fact'
	    end

	    collection do
			get '/:date', :action => 'index'
	    	get 'user/:user_id', :action => 'user_marks'
	    	post 'update_user_marks/:user_id', :action => 'update_user_marks'
	    	#get 'user/:user'
	    end
	end

	resources :kpi_patterns do
	    member do
	      get 'autocomplete_for_user'
	      get 'autocomplete_for_indicator'
	    end
	end

	resources :kpi_imported_values do
	    collection do
	      post 'update_values'
	      get 'edit_values'
	    end
	end

	resources :kpi_calc_periods do
		collection do
		#get '/:date', :action => 'index'
	    end

	    member do
	   	  get 'close_for_user/:user_id', :action => 'close_for_user'
	   	  get 'reopen_for_user/:user_id', :action => 'reopen_for_user'
	      post 'add_inspectors'
	      post 'add_users', :as => 'add_users'
	      get 'autocomplete_for_user'
	      get 'autocomplete_for_applied_user'
	      get 'activate'
	      get 'close'
	      delete 'remove_inspector/:indicator_inspector_id', :action => 'remove_inspector', :as => 'remove_inspector'
	      delete 'remove_user/:period_user_id', :action => 'remove_user', :as => 'remove_user'
	      post 'update_inspectors', :action => 'update_inspectors', :as => 'update_inspectors'
	      post 'update_plans', :action => 'update_plans', :as => 'update_plans'
	    end
	end

end


# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
