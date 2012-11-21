module KpiHelper
	def get_table_head


	end	

	def user_tabs(users)
		tabs = []
		users.each do |u|
			tabs << {:name => "kpi-marks-#{u.id}", :partial => 'kpi_marks/user_marks', :user_id => u.id, :label => "#{u.lastname} #{u.firstname[0]}.", :without_translate => true}
		end
		tabs
	end

	def get_indicator_input(mark, name, tabindex)
		kpi_period_indicator=mark.kpi_indicator_inspector.kpi_period_indicator

		case Indicator::INPUT_TYPES[kpi_period_indicator.input_type.to_s]
		when 'exact_values'
			options=[['', '']]
			if not kpi_period_indicator.matrix['title'].nil? and kpi_period_indicator.matrix['title'].uniq.size>1
				kpi_period_indicator.matrix['title'].each_index{|i| options.push([kpi_period_indicator.matrix['title'][i], kpi_period_indicator.matrix['value_of_fact'][i]])}			
			else
				kpi_period_indicator.matrix['percent'].each_index{|i| options.push([kpi_period_indicator.matrix['value_of_fact'][i], kpi_period_indicator.matrix['value_of_fact'][i]])}				
			end

		  	select_tag name, options_for_select(options, mark.fact_value.to_i), :tabindex => tabindex, :class => 'fact_value ' + (mark.fact_value.nil? ? '' : 'completed')
		else
		  	"<input type=\"text\" name=\"#{name}\" tabindex=\"#{tabindex}\" value=\"#{mark.fact_value}\" class=\"#{'completed' if not mark.fact_value.nil?}\"/> ".html_safe
		end		

	end

	def human_name(period)
		"<big><b>#{I18n.t("date.abbr_month_names")[period.date.month]} #{period.date.year}</b></big>, #{period.kpi_pattern.name}".html_safe
	end

	def human_month(date)
		"#{I18n.t("date.abbr_month_names")[date.month]} #{date.year} "
	end

	def link_to_indicator(indicator)
		link_to indicator, {:controller => 'indicators', :action => 'show', :id =>indicator}
	end

	def kpi_percent(value)
		case value.class.name
		when 'Float'
			"<nobr><span class=\"value\">#{'%0.2f' % value.to_f}</span><span class=\"unit\">%</span></nobr>".html_safe
		when 'NilClass'
			"<nobr><span class=\"value\">x</span><span class=\"unit\">%</span></nobr>".html_safe
		else
			"<nobr><span class=\"value\">#{value}</span><span class=\"unit\">%</span></nobr>".html_safe
		end
	end

	def kpi_value(value, abridgement)
		value='x' if value.nil?
		"<nobr><span class=\"value\">#{value}</span><span class=\"unit\">#{abridgement}</span></nobr>".html_safe
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

	def plan_view(value, mark, period_indicator, period)
		if (User.current.id == mark.inspector_id or User.current.global_permission_to?('kpi', 'marks')) and (period_indicator.interpretation == Indicator::INTERPRETATION_FACT)
			link_to_modal_window value, {:controller => 'kpi_marks', :action=> 'edit_plan', :id => mark.id, :i=>period.id}
		else
			value
		end
	end

=begin

	def link_to_indicator(indicator)
		link_to_remote indicator,
		                   :url => {:controller => 'indicators',
		                            :action => 'show',
		                            :id => indicator},
		                   :method => 'get',
		                   :before => "showModal('ajax-modal'); return false"
	end
=end
end	
