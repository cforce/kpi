jQuery(document).ready(function(){
	hide_custom_field_fields_for_kpi_mark()


	jQuery('#custom_field_field_format').change(function(){
			hide_custom_field_fields_for_kpi_mark();
		});
	
	});

function hide_custom_field_fields_for_kpi_mark()
	{
	if(jQuery('#custom_field_field_format').val()=='kpi_mark')
		{
		jQuery('#custom_field_min_length').parents('p').hide();
        jQuery('#custom_field_max_length').parents('p').hide();
        jQuery('#custom_field_default_value').parents('p').hide();
        jQuery('#custom_field_regexp').parents('p').hide();            
		}
	
	}