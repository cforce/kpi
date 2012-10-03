Redmine::Plugin.register :kpi do
  name 'Kpi plugin'
  author 'Pitin Vladimir Vladimirovich'
  description ''
  version '0.0.1'
  url 'http://pitin.su'
  author_url 'http://pitin.su'

  #menu :top_menu, :my_page, { :controller => 'my', :action => 'page' }, :caption => Proc.new { User.current.my_page_caption },  :if => Proc.new { User.current.logged? }, :first => true
end

Rails.application.config.to_prepare do
	User.send(:include, Kpi::UserPatch)
end