module KpiHelper
	def get_table_head


	end	

	def get_indicator_input(mark, name, tabindex)
		kpi_period_indicator=mark.kpi_indicator_inspector.kpi_period_indicator

		case Indicator::INPUT_TYPES[kpi_period_indicator.input_type.to_s]
		when 'exact_values'
			options=[['', '']]
			kpi_period_indicator.matrix['percent'].each_index{|i| options.push([kpi_period_indicator.matrix['percent'][i], kpi_period_indicator.matrix['value_of_fact'][i]])}
		  	select_tag name, options_for_select(options, mark.fact_value.to_i), :tabindex => tabindex, :class => mark.fact_value.nil? ? '' : 'completed'
		else
		  	"<input type=\"text\" name=\"#{name}\" tabindex=\"#{tabindex}\" value=\"#{mark.fact_value}\" class=\"#{'completed' if not mark.fact_value.nil?}\"/> ".html_safe
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
