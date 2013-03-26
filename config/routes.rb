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
			#get 'effectiveness/:date', :action => 'effectiveness'
			get 'effectiveness/:user_id', :action => 'effectiveness'
			get 'effectiveness/:date/:user_id', :action => 'effectiveness'

		end
	end

	match 'indicators/:copy_from/copy', :to => 'indicators#new'
	#match 'kpi_patterns/:id/users', :controller => 'kpi_patterns', :action => 'add_users', :id => /\d+/, :via => :post, :as => 'kpi_patters_users'
	#match 'kpi_patterns/:id/users/:user_id', :controller => 'kpi_patterns', :action => 'remove_user', :id => /\d+/, :via => :delete, :as => 'kpi_pattern_user'
	#match 'kpi_patterns/:id/indicators', :controller => 'kpi_patterns', :action => 'add_indicators', :id => /\d+/, :via => :post, :as => 'kpi_patters_indicators'
	#match 'kpi_patterns/:id/update_indicators', :controller => 'kpi_patterns', :action => 'update_indicators', :id => /\d+/, :via => :post, :as => 'kpi_patterns_indicators_edit'
	#match 'kpi_patterns/:id/indicators/:indicator_id', :controller => 'kpi_patterns', :action => 'remove_indicator', :id => /\d+/, :via => :delete, :as => 'kpi_pattern_indicator'
	match 'kpi_patterns/:copy_from/copy', :to => 'kpi_patterns#edit'


	resources :kpi_user_surcharges do
	    member do
	    	get 'show_surcharges', :action => 'show_surcharges'
	    	post 'add_surcharge', :action => 'add_surcharge'
	    end
	end

	resources :kpi_applied_reports do
		collection do
			get 'show', :action => 'show'
			get 'apply/:date/:department_id', :action => 'apply'
			get 'cancel/:date/:department_id', :action => 'cancel'
		end

	end

	resources :kpi_period_users do
	    member do
	    	get 'edit_hours', :action => 'edit_hours'
	    	get 'edit_base_salary', :action => 'edit_base_salary'
	    	get 'close_message', :action => 'close_message'
	    	get 'edit_jobprise', :action => 'edit_jobprise'
	    	post 'update_base_salary', :action => 'update_base_salary'
	    	post 'update_jobprise', :action => 'update_jobprise'
	    	post 'update_hours', :action => 'update_hours'
	    	get 'close'
	    	get 'reopen'
	    end
	end

	resources :kpi_marks do
	    member do
	      get 'edit_plan', :action => 'edit_plan'
	      post 'update_plan', :action => 'update_plan'
	      get 'edit_fact', :action => 'edit_fact'
	      post 'update_fact', :action => 'update_fact'
	      get 'show_info', :action => 'show_info'
	      get 'disable', :action => 'disable'
	      get 'enable', :action => 'enable'
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
	      post 'add_users', :action =>'add_users'
	      delete 'remove_user/:user_id', :action => 'remove_user'
	      post 'add_indicators', :action => 'add_indicators'
	      post 'update_indicators', :action => 'update_indicators'
	      delete 'remove_indicator/:indicator_id', :action => 'remove_indicator'
	      get 'autocomplete_for_user'
	      get 'autocomplete_for_indicator'
	    end
	end

	resources :kpi_imported_values do
	    collection do
	      post 'update_values'
	      get 'edit_values'
	      get 'permission_titles', :action => 'permission_titles'
	    end
	end

	resources :kpi_calc_periods do
		collection do
		#get '/:date', :action => 'index'
	    end

	    member do
	   	  # get 'close_for_user/:user_id', :action => 'close_for_user'
	   	  # get 'reopen_for_user/:user_id', :action => 'reopen_for_user'
	      post 'add_inspectors'
	      post 'add_users', :as => 'add_users'
	      get 'autocomplete_for_user'
	      get 'autocomplete_for_applied_user'
	      get 'show_warning_message'
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
