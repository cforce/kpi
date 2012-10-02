document.observe('dom:loaded', function(){
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
	});