Redmine::Plugin.register :kpi do
  name 'Kpi plugin'
  author 'Pitin Vladimir Vladimirovich'
  description ''
  version '0.0.1'
  url 'http://pitin.su'
  author_url 'http://pitin.su'

  menu :top_menu, :my_marks, { :controller => 'kpi', :action => 'marks' }, :caption => Proc.new { User.current.my_kpi_marks_caption },  :if => Proc.new { User.current.logged? }, :first => true

	settings :partial => 'settings/kpi_settings',
             :default => {
              "user_superior_id_field" => "parent_id"
             }    
end

Rails.application.config.to_prepare do
	User.send(:include, Kpi::UserPatch)
end