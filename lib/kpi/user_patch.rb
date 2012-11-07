
module Kpi
  module UserPatch
    def self.included(base)
		base.extend(ClassMethods)
		base.send(:include, InstanceMethods)		
	
      base.class_eval do 
		has_many :kpi_pattern_users
		has_many :kpi_patterns, :through => :kpi_pattern_users
		has_many :kpi_marks
		has_many :kpi_inspector_marks, :class_name => 'KpiMark', :foreign_key => 'inspector_id'
		has_many :kpi_period_users
		has_many :kpi_calc_periods, :through => :kpi_period_users

		scope :not_in_kpi_pattern, lambda {|pattern|
		    pattern_id = pattern.is_a?(KpiPattern) ? pattern.id : pattern.to_i
		    { :conditions => ["#{User.table_name}.id NOT IN (SELECT pu.user_id FROM kpi_pattern_users pu WHERE pu.kpi_pattern_id = ?)", pattern_id] }
		  	}
      end
	  
    end
	
	module ClassMethods   
	end
	
	module InstanceMethods

		def my_kpi_marks_caption
			label=l(:my_kpi_marks)
			num=get_my_marks_num
			label+=" (#{num})" if num>0
			label
		end

		def get_my_marks
			kpi_inspector_marks.where('kpi_marks.end_date <= ?', Date.today)
		end

		def get_my_marks_num
			get_my_marks.where('fact_value IS NULL').count
		end

		def superior
			User.find_by_id(self.parent_id)
		end

		def subordinates
			User.where("#{Setting.plugin_kpi['user_superior_id_field']} = ?", id);
		end

		def subordinate?
			eval('self.'+Setting.plugin_kpi['user_superior_id_field']) == User.current.id
		end
	end	
  end
end
