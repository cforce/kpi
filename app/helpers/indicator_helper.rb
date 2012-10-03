module IndicatorHelper
	def get_matrix_row
		"<tr>
		<td><input type=\"text\" name=\"indicator[matrix][value_of_fact][]\" class=\"value_of_fact\" /></td>
		<td><input type=\"text\" name=\"indicator[matrix][percent][]\" class=\"percent\" /></td>
		<td>
		<a href=\"#\" class=\"icon icon-add\"><%= l(:label_matrix_row_add) %></a>
		<a href=\"#\" class=\"icon icon-del\" style=\"display:none;\"><%= l(:label_matrix_row_del) %></a>
		</td>
		</tr>"
	end	
end