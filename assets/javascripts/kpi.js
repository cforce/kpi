jQuery(document).ready(function(){
	jQuery('#indicator_interpretation').change(function(){
	    if(jQuery(this).val()==1)
		    jQuery('#kpi_matrix_div').show()
		else
			jQuery('#kpi_matrix_div').hide()
		});

	jQuery('#kpi_matrix a.icon-add').click(function(){
		make_next_matrix_row(jQuery(this), '', '')
		return false;
		});

	jQuery('#kpi_matrix a.icon-del').click(function(){
		var tr=jQuery(this).parent().parent();
		var size=tr.siblings('tr').length;
		if(size==3)
		    tr.siblings('tr').find('a.icon-del').hide();		
		if(size>2)
			tr.remove();
			
		return false;

		});	

	portable_data_apply();

	jQuery(document.body).on('modal_window_shown', '.modal_window', function(){  
		jQuery(this).find("form input:text:first").focus();
		});

	jQuery('#fill_mark_values').click(function(){
		jQuery('#kpi_matrix tr:gt(1)').remove();
		jQuery('#kpi_matrix tr input').val('');
		jQuery('#kpi_mark_values span').each(function(){
			make_next_matrix_row(jQuery('#kpi_matrix tr:last a.icon-add'), jQuery(this).find('div:eq(0)').html(), jQuery(this).find('div:eq(1)').html())
			});	   
		jQuery('#kpi_matrix tr:eq(1)').remove();   
		return false;
		});
	
	});

function portable_data_apply()
	{
	jQuery('div.portable_data').each(function(){
		jQuery('#'+jQuery(this).attr('data-target-id')).html(jQuery(this).html());
		});
	}

function make_next_matrix_row(current_link, value, percent)
	{
	var tr=current_link.parent().parent();
    current_link.next('a.icon-del').show();
	tr.after(tr.clone(true).find('input:eq(0)').val(value).end());
	}