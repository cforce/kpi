RedmineApp::Application.routes.draw do
	resources :indicators
	resources :kpi_patterns
	match 'kpi', :controller => 'kpi', :action => 'index', :via => [:get]
	match 'indicators/:copy_from/copy', :to => 'indicators#new'
end


# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
