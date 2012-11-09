module IndicatorsHelper
	def get_matrix_row(value_of_fact='', percent='', style='style="display:none;"')
		"<tr>
		<td><input type=\"text\" name=\"indicator[matrix][value_of_fact][]\" class=\"value_of_fact\" value=\"#{value_of_fact}\" /></td>
		<td><input type=\"text\" name=\"indicator[matrix][percent][]\" class=\"percent\" value=\"#{percent}\" /></td>
		<td>
		<a href=\"#\" class=\"icon icon-add\">#{l(:label_matrix_row_add)}</a>
		<a href=\"#\" class=\"icon icon-del\" #{style}>#{l(:label_matrix_row_del)}</a>
		</td>
		</tr>".html_safe
	end	

	def get_fact_pattern_options
		Indicator::FACT_PATTERNS.map{|k,v| [l(v), k]}
	end

	def options_for_mark_custom_field(indicator)
		default = nil

		if not indicator.pattern_settings.nil?
			default = indicator.pattern_settings['mark_custom_field']  if not indicator.pattern_settings['mark_custom_field'].nil?
		end		

		options_for_select(CustomField.where(:field_format => 'kpi_mark').order(:name).map{ |u| [u.name, u.id]}, default)
	end

	def get_num_on_period
		num=[]
		Indicator::MAX_NUM_IN_PERIOD.times{|i| num[i]=[i+1, i+1]}
		num
	end
end