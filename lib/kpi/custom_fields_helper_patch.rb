module Kpi
  module CustomFieldsHelperPatch
    def self.included(base)
		base.extend(ClassMethods)
		base.send(:include, InstanceMethods)		
	
      base.class_eval do 
      	alias_method_chain :custom_field_tag, :kpi
      end
	  
    end
	
	module ClassMethods   

	end
	
	module InstanceMethods
		def custom_field_tag_with_kpi(name, custom_value)
		    custom_field = custom_value.custom_field
		    field_name = "#{name}[custom_field_values][#{custom_field.id}]"
		    field_name << "[]" if custom_field.multiple?
		    field_id = "#{name}_custom_field_values_#{custom_field.id}"
		    tag_options = {:id => field_id, :class => "#{custom_field.field_format}_cf"}
		    field_format = Redmine::CustomFieldFormat.find_by_name(custom_field.field_format)

            case field_format.try(:edit_as)
            when 'kpi_mark'
                blank = custom_field.is_required? ?
                      ((custom_field.default_value.blank? && custom_value.value.blank?) ? content_tag(:option, "--- #{l(:actionview_instancetag_blank_option)} ---") : ''.html_safe) :
                        content_tag(:option)
                tag = select_tag(field_name,
                                 blank + options_for_select(custom_field.possible_values_options(custom_value.customized), custom_value.value),
                                 :id => field_id, :class => 'kpi_mark')
            else
                tag = custom_field_tag_without_kpi(name, custom_value)
            end
            tag
		end
	end	
  end
end
