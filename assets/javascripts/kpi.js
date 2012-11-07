jQuery(document).ready(function(){
	jQuery('#indicator_interpretation').change(function(){
	    if(jQuery(this).val()==1)
		    jQuery('#kpi_matrix').show()
		else
			jQuery('#kpi_matrix').hide()
		});

	jQuery('#kpi_matrix a.icon-add').click(function(){
		var tr=jQuery(this).parent().parent();
        jQuery(this).next('a.icon-del').show();
		tr.after(tr.clone(true).find('input').val('').end());
		return false;
		});

	jQuery('#kpi_matrix a.icon-del').click(function(){
		var tr=jQuery(this).parent().parent();
		var size=tr.siblings('tr').length;
		if(size==2)
		    tr.siblings('tr').find('a.icon-del').hide();		
		if(size>1)
			tr.remove();
			
		return false;

		});	

	portable_data_apply();

	jQuery(document.body).on('modal_window_shown', '.modal_window', function(){  
		jQuery(this).find("form input:text:first").focus();
		});
	
	});

function portable_data_apply()
	{
	jQuery('div.portable_data').each(function(){
		jQuery('#'+jQuery(this).attr('data-target-id')).html(jQuery(this).html());
		});
	}