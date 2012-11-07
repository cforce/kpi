module Kpi
  module CustomFieldPatch
    def self.included(base)
		base.extend(ClassMethods)
		base.send(:include, InstanceMethods)		
	
      base.class_eval do 
        alias_method_chain :possible_values_options, :kpi
      	alias_method_chain :cast_value, :kpi
      end
	  
    end
	
  	module ClassMethods   

  	end
	
  	module InstanceMethods
          def possible_values_options_with_kpi(obj = nil)
              case field_format
              when 'kpi_mark'
  				KpiIssueMark.order(:value).collect {|m| [m.title.to_s, m.value.to_s]}
              else
                  possible_values_options_without_kpi(obj)
              end
          end

          def cast_value_with_kpi(value)
            casted=cast_value_without_kpi(value)
            if casted.nil?
              unless value.blank?
                case field_format
                when 'kpi_mark'
                  casted=KpiIssueMark.where(:value => value).first.title
                end                  
              end             
            end

          casted
          end

  	end	
  end
end
