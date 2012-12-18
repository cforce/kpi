module IndicatorsHelper
	def get_matrix_row(value_of_fact='', percent='', style='style="display:none;"', title='')
		"<tr>
		<td><input type=\"text\" name=\"indicator[matrix][title][]\" class=\"value_of_fact\" value=\"#{title}\" /></td>
		<td><input type=\"text\" name=\"indicator[matrix][value_of_fact][]\" class=\"value_of_fact\" value=\"#{value_of_fact}\" /></td>
		<td><input type=\"text\" name=\"indicator[matrix][percent][]\" class=\"percent\" value=\"#{percent}\" /></td>
		<td>
		<a href=\"#\" class=\"icon icon-add\">#{l(:label_matrix_row_add)}</a>
		<a href=\"#\" class=\"icon icon-del\" #{style}>#{l(:label_matrix_row_del)}</a>
		</td>
		</tr>".html_safe
	end	

	def get_fact_pattern_options
		Indicator::FACT_PATTERNS.sort_by{|k, v| l(v)}.map{|k,v| [l(v), k]}
	end

	def get_plan_pattern_options
		Indicator::PLAN_PATTERNS.sort_by{|k, v| l(v)}.map{|k,v| [l(v), k]}
	end

	def options_for_role(indicator)
		default = nil

		if not indicator.pattern_settings.nil?
			default = indicator.pattern_settings['role']  if not indicator.pattern_settings['role'].nil?
		end		

		options_for_select(Role.where(:builtin => 0).order(:name).map{ |u| [u.name, u.id]}, default)
	end

	def options_for_imported_values(indicator, plan = false)
		default = nil

		pattern_settings = indicator.pattern_settings
		pattern_settings = indicator.pattern_plan_settings if plan

		if not pattern_settings.nil?
			default = pattern_settings['imported_value_id']  if not pattern_settings['imported_value_id'].nil?
		end		

		options_for_select(KpiImportedValue.order(:name).map{ |u| [u.name, u.id]}, default)
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