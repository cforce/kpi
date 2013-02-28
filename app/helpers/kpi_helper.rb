module KpiHelper
	def cut_completion(completion, period_indicator)
		get_cut_value(completion, period_indicator.max_effectiveness, period_indicator.min_effectiveness)
	end


	def get_table_head


	end	

	def get_default_user
		user = @not_subordinated_estimated_users.first if @not_subordinated_estimated_users.any?
		user = @subordinated_estimated_users.first if @subordinated_estimated_users.any?
		user
	end

	def user_tabs(users)
		tabs = []
		users.each do |u|
			tabs << {:name => "kpi-marks-#{u.id}", :partial => 'kpi_marks/user_marks', :user_id => u.id, :label => "#{u.lastname} #{u.firstname[0]}.", :without_translate => true}
		end
		tabs
	end

	def get_indicator_input(mark, name, tabindex=1)
		kpi_period_indicator=mark.kpi_indicator_inspector.kpi_period_indicator

		case Indicator::INPUT_TYPES[kpi_period_indicator.input_type.to_s]
		when 'exact_values'
			options=[['', '']]
			default = nil
			if not kpi_period_indicator.matrix['title'].nil? and kpi_period_indicator.matrix['title'].uniq.size>1
				kpi_period_indicator.matrix['title'].each_index{|i|
					options.push([kpi_period_indicator.matrix['title'][i], kpi_period_indicator.matrix['value_of_fact'][i].to_f])
					default = kpi_period_indicator.matrix['value_of_fact'][i].to_f if kpi_period_indicator.matrix['percent'][i].to_i==100
					}			
			else
				kpi_period_indicator.matrix['percent'].each_index{|i| 
					options.push([kpi_period_indicator.matrix['value_of_fact'][i], kpi_period_indicator.matrix['value_of_fact'][i].to_f])
					default = kpi_period_indicator.matrix['value_of_fact'][i].to_f if kpi_period_indicator.matrix['percent'][i].to_i==100
					}				
			end
		  	select_tag name, 
		  				options_for_select(options, mark.fact_value.nil? ? default : mark.fact_value.to_f), 
		  				:tabindex => tabindex, :class => 'fact_value ' + (mark.fact_value.nil? ? '' : 'completed'), 
		  				'data-explanation' => "explanation_#{mark.id}",
		  				'data-plan' => "plan_value_#{mark.id}"
		else
		  	"<input type=\"text\" name=\"#{name}\" tabindex=\"#{tabindex}\" value=\"#{mark.fact_value}\" class=\"#{'completed' if not mark.fact_value.nil?}\"/> ".html_safe
		end		

	end

	def human_name(period)
		"<big><b>#{I18n.t("date.abbr_month_names")[period.date.month]} #{period.date.year}</b></big>, #{pattern_name(period)}".html_safe
	end

	def human_month(date)
		"#{I18n.t("date.abbr_month_names")[date.month]} #{date.year} "
	end

	def link_to_indicator(indicator)
		link_to indicator, {:controller => 'indicators', :action => 'show', :id =>indicator}
	end

	def kpi_percent(value, minus=false)
		case value.class.name
		when 'NilClass'
			"<nobr><span class=\"value\">x</span><span class=\"unit\">%</span></nobr>".html_safe
		else
			css_class="" 
			css_class="minus" if minus
			value = number_with_precision(value, :separator => '.', :strip_insignificant_zeros => true)
			"<nobr><span class=\"#{css_class} value\">#{value}</span><span class=\"unit\">%</span></nobr>".html_safe
		end
	end

	def kpi_value(value, abridgement, minus=false)
        value = number_with_precision(value, :delimiter => value.to_s.split('.').first.length > 4 ? " " : "", :strip_insignificant_zeros => true, :precision =>2, :separator => '.')  unless value.nil?

		value='x' if value.nil?
		css_class="" 
		css_class="minus" if minus

		"<nobr><span class=\"#{css_class} value\">#{value}</span><span class=\"unit\">#{abridgement}</span></nobr>".html_safe
	end

	def weighted_average_value(completion)
		completion.values.compact!=[] ?  completion.inject(0){|kpi, (k, v)| kpi+=(v*k.percent)/100 unless v.nil?; kpi} : nil
	end

	def get_avg_completion(marks)
	
		if marks!={}
			single_user_marks=[]
			weights_and_completions={}
			inspector_id=nil; percent=nil
			marks.map{|mark, completion| 
				if mark.inspector_id!=inspector_id 
					if not inspector_id.nil?
					weights_and_completions[inspector_id] = {:percent => percent, :completion => single_user_marks.sum/single_user_marks.size}
					single_user_marks = []
					end
				end

				single_user_marks.push completion
				percent = mark.kpi_indicator_inspector.percent.to_f
				inspector_id=mark.inspector_id
				}
			weights_and_completions[inspector_id] = {:percent => percent, :completion => single_user_marks.sum/single_user_marks.size} unless inspector_id.nil? or percent.nil?

			#weights_and_completions.inspect
			weights_and_completions.inject(0){|kpi, (k, v)| kpi+=(v[:percent]*v[:completion])/100; kpi}
		end

	end

	def sidebar_link_to(name, options = {}, html_options = nil, *parameters_for_method_reference)
    	link_to(name, options, html_options, *parameters_for_method_reference) if User.current.global_permission_to?(options[:controller] || params[:controller], options[:action])
	end

	def plan_view(value, mark, period_indicator, period, period_user)
		value = number_with_precision(value, :delimiter => value.to_s.split('.').first.length > 4 ? " " : "", :strip_insignificant_zeros => true)
		if mark.check_user_for_plan_update(period_indicator, period_user)
			#Rails.logger.debug "ffffffffff #{{:controller => 'kpi_marks', :action=> 'edit_plan', :id => mark.id, :i=>period.id}.inspect}"
			link_to_modal_window(value, {:controller => 'kpi_marks', :action=> 'edit_plan', :id => mark.id, :i=>period.id}, {:class => 'click_out'})
		else
			value
		end
	end

	def kpi_val_round(value)
		case value.class.name
		when 'Float'
			'%0.2f' % value
		else
			value
		end
	end

	def completion_view(mark, completion)
		link_to_modal_window kpi_val_round(completion), {:controller => 'kpi_marks', :action=> 'show_info', :id => mark.id} unless completion.nil?
	end

	def fact_view(mark, period, period_indicator, period_user)
		fact_value = mark.fact_value.nil? ? 'x' : mark.fact_value
		fact_value = number_with_precision(fact_value, :delimiter => fact_value.to_s.split('.').first.length > 4 ? " " : "", :strip_insignificant_zeros => true, :precision => 2)
		if mark.check_user_for_fact_update(period_indicator, period_user)
			link_to_modal_window(fact_value, {:controller => 'kpi_marks', :action=> 'edit_fact', :id => mark.id, :i=>period.id}, {:class => 'click_out'})
		else
			fact_value
		end		
	end

	def pattern_link(period)
		(period.kpi_pattern.nil?) ? l(:pattern_has_been_deleted) : (link_to h(period.kpi_pattern.name), edit_kpi_pattern_path(period.kpi_pattern))
	end

	def pattern_name(period)
		(period.kpi_pattern.nil?) ? l(:pattern_has_been_deleted) : h(period.kpi_pattern.name)
	end

	def user_period_status(period_user)
		if period_user.locked
			return l(:closed)
		else 
			if period_user.kpi_calc_period.active
				return l(:actived)
			else
				return l(:not_actived)
			end
		end

	end

	def lag(check_date, due_date)
		lag = (check_date.day - due_date.day)
		(lag>0) ? (lag) : 0
	end

	def link_to_mark_state(mark)
		if mark.disabled
			link_to image_tag("show_table_row.png", :plugin => :kpi, :title => l(:consider)), {:controller => 'kpi_marks', :action => 'enable', :id => mark.id}, {:class => 'no_line', :remote => true} 
		else
			link_to image_tag("hide_table_row.png", :plugin => :kpi, :title => l(:ignore)), {:controller => 'kpi_marks', :action => 'disable', :id => mark.id}, {:class => 'no_line', :remote => true} 			
		end
	end

	def show_sidebar_users()
		user_list = ""

		if User.current.global_permission_to?('kpi', 'effectiveness')
			initial_user = UserTree.find(Setting.plugin_kpi['initial_user_id'])
		else
			initial_user = UserTree.find(User.current.id)
		end

		last_parent_id, last_id, last_level = nil
		UserTree.each_with_level(UserTree.joins(:user).includes(:user)
										 .order("lft")
										 .select("#{UserTree.table_name}.*, #{User.table_name}.lastname")
										 .where("#{User.table_name}.status=? AND lft>? AND rgt<?", User::STATUS_ACTIVE, initial_user.lft, initial_user.rgt)) do |user_tree, level|
			user_list << "<ul class=\"folding_tree opened\">" if last_id.nil? # First time

			if last_id == user_tree.attributes['parent_id'] # Next is child
				user_list << "<ul class=\"folding_tree closed\">" unless last_id.nil? # Not First time
			else
				if last_id == user_tree.attributes['parent_id'] # Have single parent
					user_list << "</li>" unless last_id.nil? # Not First time
				else
					user_list << "</ul></li>"*(last_level-level.to_i) unless last_id.nil? # Not First time
				end
			end

			user_list << "<li class=\"disc\">" # Every time
			#user_list << "<div style=\"padding-left:"+((level-1)*10).to_s+"px;\">"
			user_list << link_to("<span>#{user_tree.user.name}</span>".html_safe, {:controller => 'kpi', :action => 'effectiveness', :date => params[:date] || nil , :user_id => user_tree.attributes['id']},
							:class => "no_line #{'selected' if controller.action_name=='effectiveness' and @user.id==user_tree.attributes['id']}")
			#user_list << "</div>"
			last_parent_id = user_tree.attributes['parent_id']
			last_id = user_tree.attributes['id']
			last_level = level.to_i
		end
		#Rails.logger.debug "dddddddddddddddddddddddddddddd"

		user_list << "</li></ul>"*last_level unless last_id.nil? #last time

    functional_unders = User.joins(:kpi_period_users => :kpi_calc_period).where("#{KpiCalcPeriod.table_name}.user_id = ?", User.current.id).group("#{User.table_name}.id").order(:lastname)

    i=0
    functional_unders.each do |u|
      if i==0
        user_list << "<h3>#{l(:functional_unders)}</h3>"
        user_list << "<ul>"
      end
      user_list << "<li>"
      user_list << link_to("<span>#{u.name}</span>".html_safe, {:controller => 'kpi', :action => 'effectiveness', :date => params[:date] || nil , :user_id => u.id},
              :class => "no_line #{'selected' if controller.action_name=='effectiveness' and @user.id==u.id}")
       user_list << "</li>"
      i+=1
      end
    user_list << "</ul>" unless i!=0

		user_list.html_safe
	end


  # def base_salary_value(period_user, period)
  # 	v=nil
  #  	v=period.base_salary unless period.base_salary.nil?
  # 	v=period_user.base_salary unless period_user.base_salary.nil?
  # 	v
  # end

  def hours_value(period_user)
  	v=nil
  	v=period_user.hours unless period_user.hours.nil?
  	v
  end

  def hours_view(period_user, user, value)
  	value = 'x' if value.nil?
    value = number_with_precision(value, :separator => ".", :strip_insignificant_zeros => true, :precision => 2)
  	if period_user.check_user_for_hours_update?(user)
  		link_to_modal_window(value, {:controller => 'kpi_period_users', :action=> 'edit_hours', :id => period_user.id}, {:class => 'click_out'})
  	else
  		value
  	end
  end

  def base_salary_view(period, period_user, user, value)
  	value='x' if value.nil?
  	value = number_with_delimiter(value, :delimiter => " ", :separator => '.')
  	if period_user.check_user_for_hours_update?(user)
  		value = link_to_modal_window(value, {:controller => 'kpi_period_users', :action=> 'edit_base_salary', :id => period_user.id}, {:class => 'click_out'})
  	end
  	value << "<span class=\"no_align_unit\">#{l(:money_unit_abridgement)}</span>".html_safe
  	value.html_safe
  end

  def subcharge_view(period_user, user, value)
    value='x' if value.nil?
    value = number_with_delimiter(number_with_precision(value, :separator => ".", :strip_insignificant_zeros => true, :precision => 2), :delimiter => " ", :separator => '.')
    if period_user.check_user_for_surcharge_show?
        value = link_to_modal_window(value, {:controller => 'kpi_user_surcharges', :action=> 'show_surcharges', :id => period_user.id}, {:class => 'click_out'})
    end
    value << "<span class=\"no_align_unit\">#{l(:money_unit_abridgement)}</span>".html_safe
    value.html_safe
  end


  def job_prise_view(period_user, user, value)
    value='x' if value.nil?
    value = number_with_delimiter(value, :delimiter => " ", :separator => '.')
    if period_user.check_user_for_jobprise_update?(user)
        value = link_to_modal_window(value, {:controller => 'kpi_period_users', :action=> 'edit_jobprise', :id => period_user.id}, {:class => 'click_out'})
    end
    value << "<span class=\"no_align_unit\">#{l(:money_unit_abridgement)}</span>".html_safe
    value.html_safe
  end


  def get_cut_value(value, max, min)
  	v = value
  	v = min.to_f if value.to_f<min.to_f
  	v = max.to_f if value.to_f>max.to_f
  	v = nil if value.nil? 
  	v = value if max.nil? or min.nil?
  	v
  end

  def get_weighted_average_value(value)
  	get_cut_value(value, Setting.plugin_kpi['max_kpi'].to_f, Setting.plugin_kpi['min_kpi'].to_f)
  end

  def get_weighted_average_value_view(value)
  	v = get_weighted_average_value(value)
  	v = "#{number_with_precision(value, :separator => ".", :strip_insignificant_zeros => true, :precision => 2)} &rarr; "+v.to_s if value!=v
  	v = 'x' if value.nil?
  	v
  end

  # def get_salary(month_time_clock, hours_value, base_salary_value, weighted_average_value)
  	# v='x'
  	# v= ((base_salary_value*weighted_average_value/100)*hours_value)/month_time_clock unless month_time_clock.nil? or hours_value.nil? or base_salary_value.nil? or weighted_average_value.nil?
 	# number_with_precision(v, :separator => ".", :strip_insignificant_zeros => true, :precision => 2)
  # end

end	
