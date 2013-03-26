jQuery(document).ready(function(){

    jQuery(document.body).on("click", 'input.enable_field', function(){
        if(jQuery('#'+jQuery(this).attr('data-rel-element')).attr('disabled')=='disabled')
            jQuery('#'+jQuery(this).attr('data-rel-element')).removeAttr('disabled')
        else
            jQuery('#'+jQuery(this).attr('data-rel-element')).attr('disabled', 'disabled')
        });

    jQuery(document.body).on("change", '#kpi_imported_value_user_department_id', function(){

        $.ajax({
            url: jQuery(this).attr('data-title-url'),
            type: 'get',
            dataType: 'script',
            data: 'id='+jQuery(this).val()
          });
        });
    

    jQuery(document.body).on("submit", 'form', function(){
        jQuery(this).find('input.numeric').each(function(){
            jQuery(this).val(jQuery(this).val().split(' ').join(''))
            })
        });


    jQuery(document.body).on("change input keyup", 'input.numeric', function(event){
        numeric_value(jQuery(this))
        });

    /*jQuery(document.body).on("keyup", 'input.numeric', function(event){
        if(event.keyCode != 8 && event.keyCode != 46)
            {
            alert(event.keyCode)
            numeric_value(event, jQuery(this))
            }
        });*/

    jQuery('.showing_element').click(function(){

        jQuery('#'+jQuery(this).attr('data-element')).toggle();
        });
    

    jQuery('a.link_to_kpi_marks').click(function(){

        jQuery('div.tab-content').hide();
        jQuery('div.tabs ul li a').removeClass('selected');
        jQuery('#tab-content-kpi-marks-'+jQuery(this).attr('data-user-id')).show();
        jQuery('#tab-kpi-marks-'+jQuery(this).attr('data-user-id')).addClass("selected");
        jQuery('#kpi_marks_user_list').find('li a').removeClass('selected');
        jQuery(this).addClass("selected");
        jQuery('#estimated_user_name').html(jQuery(this).html())
        });

    jQuery('ul.folding_tree li').each(function(){
        //alert(jQuery(this).children('ul.closed').length)
        if(jQuery(this).children('ul.opened').length==1)
            jQuery(this).toggleClass('disc').toggleClass('opened');
        if(jQuery(this).children('ul.closed').length==1)
            jQuery(this).toggleClass('disc').toggleClass('closed');
    });
    
    jQuery('ul.folding_tree li').click(function(){
            jQuery(this).toggleClass('closed').toggleClass('opened');
            jQuery(this).children('ul').toggleClass('closed').toggleClass('opened');
            return false;

        });

     jQuery('ul.folding_tree li a').click(function(event){
            event.stopPropagation()
            });

     jQuery('ul.folding_tree li a.selected').parent('ul, li').parents('ul, li').removeClass('closed').addClass('opened');

	jQuery('#indicator_interpretation').change(function(){
	    if(jQuery(this).val()==1)
            {
            jQuery('#kpi_matrix_div').show()
            jQuery('#absolute_interpretation_settings').hide()
		    }
		else
            {
            jQuery('#kpi_matrix_div').hide()
            jQuery('#absolute_interpretation_settings').show()
            }
			
		});

	jQuery('#kpi_matrix a.icon-add').click(function(){
		make_next_matrix_row(jQuery(this), '', '', '')
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
	jQuery(document.body).on("change keyup input", 'input.completed, select.completed, textarea.completed', function(){
		jQuery(this).removeClass('completed');
		});

	jQuery(document.body).on('modal_window_shown', '.modal_window', function(){  
		jQuery(this).find("form input:text:first").focus();
		});
	jQuery(document.body).on('change keyup input', 'textarea.explanation, input.fact_value, select.fact_value', function(){
		validate_explanation();
	});


	jQuery(document.body).on('focus', 'textarea.explanation', function(){  
		jQuery(this).animate({height: '150px'}, 100);
		jQuery('body').data('mouse_on_submit', false);
		});
	jQuery(document.body).on('blur', 'textarea.explanation', function(){  
		if(!jQuery('body').data('mouse_on_submit'))
			jQuery(this).animate({height: '17px'}, 100);
		});
	jQuery(document.body).on('mouseenter', 'input.kpi_mark_submit_button', function(){  
			jQuery('body').data('mouse_on_submit', true);
		});

	jQuery(document.body).on('submit', 'form.kpi_marks', function(){  
			if(jQuery(this).find('input:submit:disabled').length>0)
				return false;
		});


	jQuery('#fill_mark_values').click(function(){
		jQuery('#kpi_matrix tr:gt(1)').remove();
		jQuery('#kpi_matrix tr input').val('');
		jQuery('#kpi_mark_values span').each(function(){
			make_next_matrix_row(jQuery('#kpi_matrix tr:last a.icon-add'), jQuery(this).find('div:eq(1)').html(), jQuery(this).find('div:eq(2)').html(), jQuery(this).find('div:eq(0)').html())
			});	   
		jQuery('#kpi_matrix tr:eq(1)').remove();   
		return false;
		});


	jQuery('select.patten_sb').change(function(){
		show_hide_custom_fields(jQuery(this))
		});

	jQuery('select.patten_sb').each(function(){
		show_hide_custom_fields(jQuery(this));
		});
	});


function get_caret_position (ctrl) {
    var CaretPos = 0;   // IE Support
    if (document.selection) {
    ctrl.focus ();
        var Sel = document.selection.createRange ();
        Sel.moveStart ('character', -ctrl.value.length);
        CaretPos = Sel.text.length;
    }
    // Firefox support
    else if (ctrl.selectionStart || ctrl.selectionStart == '0')
        CaretPos = ctrl.selectionStart;
    return (CaretPos);
}

function set_caret_position(ctrl, pos){
    if(ctrl.setSelectionRange)
    {
        ctrl.focus();
        ctrl.setSelectionRange(pos,pos);
    }
    else if (ctrl.createTextRange) {
        var range = ctrl.createTextRange();
        range.collapse(true);
        range.moveEnd('character', pos);
        range.moveStart('character', pos);
        range.select();
    }
}

function numeric_value(obj)
    {
    if(obj.val()!='')
        {
        caret_position = get_caret_position(document.getElementById(obj.attr('id')))
        space_count_before = obj.val().substring(0, caret_position).split(' ').length-1

        var re = /([^\.,0-9-]{1,})|(^\.)/g
        obj.val(obj.val().replace(re, ''))

        obj.val(obj.val().split(',').join('.'))

        var re = /(\.\d{0,})([^0-9]{1,})(\d{0,})/g
        obj.val(obj.val().replace(re, '$1$3'))

        re = /(\d)(?=(\d\d\d)+([^\d]|$))/g
        obj.val(obj.val().replace(re, '$1 '))

        space_count_after = obj.val().substring(0, caret_position).split(' ').length-1

        set_caret_position(document.getElementById(obj.attr('id')), caret_position+(space_count_after-space_count_before))
        }
    }


function portable_data_apply()
	{
	jQuery('div.portable_data').each(function(){
		jQuery('#'+jQuery(this).attr('data-target-id')).html(jQuery(this).html());
		});
	}

function make_next_matrix_row(current_link, value, percent, title)
	{
	var tr=current_link.parent().parent();
    current_link.next('a.icon-del').show();
    var tr_clone = tr.clone(true)
    tr_clone.find('input:eq(1)').val(value)
    tr_clone.find('input:eq(2)').val(percent)
    tr_clone.find('input:eq(0)').val(title)
	tr.after(tr_clone);
	}

function show_hide_custom_fields(pattern_sb)
	{
	jQuery('#'+pattern_sb.attr('data-cf')+' p').hide()
	jQuery('#'+pattern_sb.attr('data-cf')+' p.kpi_pattern_custom_field_'+pattern_sb.val()).show()
	}

function validate_explanation()
	{
		if(jQuery('textarea.explanation').length>0)	
			{	
			var form_id=false;
			var submit = '';
			i=0;
			jQuery('input.fact_value, select.fact_value').each(function(){
				var form = jQuery(this).parents('form:first');
				if(form_id!=form.attr('id'))
					{
					form_id = form.attr('id');
					
					submit = form.find('input[type=submit]');

					submit.removeAttr('disabled');
					}

				//var id=jQuery(this).attr('id').split("_")
				if(jQuery('#'+jQuery(this).attr('data-plan')).attr('data-plan-value')!=jQuery(this).val() && jQuery('#'+jQuery(this).attr('data-explanation')).val()=='')
				    {
				    jQuery('#'+jQuery(this).attr('data-explanation')).addClass('expl_warning');
				    submit.attr('disabled', 'disabled');

				    }
				else
				    {
				    jQuery('#'+jQuery(this).attr('data-explanation')).removeClass('expl_warning');   
				    }
				    i++;
				});
			}

	}

function get_kpi_arrays(array_name, data_id)
	{
	var arr = []
	jQuery('#'+data_id+' div.'+array_name+' span').each(function(){
		arr.push([Number(jQuery(this).attr("data-x")), Number(jQuery(this).attr("data-y"))])
		});
	return arr
	}


function build_chart(container, data_id)
	{
	var data = jQuery('#'+data_id)
	var values_of_matrix = get_kpi_arrays('values_of_matrix', data_id)
	var values_of_calc = get_kpi_arrays('values_of_calc', data_id)
	var values_of_fact = get_kpi_arrays('values_of_fact', data_id)


    var chart;

        chart = new Highcharts.Chart({
        	credits: {
        			enabled: false
        			},
            chart: {
                renderTo: container,
                inverted: false,
                width: 400,
                style: {
                    margin: '0 auto'
                }
            },
            title: {
                text: jQuery('#chart_title').html()
            },
            subtitle: {
                text: ''
            },
            xAxis: {
                gridLineWidth: 1,
                gridLineDashStyle: 'dot',
                /*tickInterval: 3,*/
                reversed: false,
                title: {
                    text: null
                },
                labels: {
                    formatter: function() {
                        return this.value +' '+jQuery('#x_axis_unit').html()+'';
                    }
                },
                maxPadding: 0.05,
                minPadding: 0.0,
                showLastLabel: true

            },
            yAxis: {
                   plotBands: [{ // mark the weekend
                        color: '#FCFFC5',
                        from: jQuery('#'+data_id+' .min_available_value').html(),
                        to: jQuery('#'+data_id+' .max_available_value').html(),
                        label: {
                            text: jQuery('#'+data_id+' .available_values').html(),
                            textAlign: 'left'
                        }            
                    }],

                /*maxPadding: 0.1,*/
                gridLineDashStyle: 'dot',
                title: {
                    text: null 
                },
                labels: {
                    formatter: function() {
                        return this.value + ' %';
                    }
                },
                lineWidth: 2
            },
            legend: {
                enabled: true
            },
            tooltip: {
                formatter: function() {
                    return ''+
                        ''+jQuery('#chart_fact').html()+': '+this.x +' '+jQuery('#x_axis_unit').html()+' '+jQuery('#chart_percent').html()+': '+ this.y +' %';
                }
            },
            plotOptions: {
                spline: {
                    marker: {
                        enable: false
                    }
                }
            },
            series: [{
                name: jQuery('#chart_matrix').html(),
                data: values_of_matrix
            },{
                type: 'scatter',
                name: jQuery('#chart_calc_values').html(),
                data: values_of_calc, marker: { symbol: 'circle', fillColor: '#2e8518', radius: 6, lineWidth: 2, lineColor: '#fff' }
            }, {
                name: jQuery('#chart_fact').html(),
                data: values_of_fact, marker: { symbol: 'circle', fillColor: '#ff0000', radius: 6, lineWidth: 2, lineColor: '#fff' }
            }]
        });

	}