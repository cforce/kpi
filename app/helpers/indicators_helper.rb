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


end