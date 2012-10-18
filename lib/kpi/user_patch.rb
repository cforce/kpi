require_dependency 'project'
require_dependency 'principal'
require_dependency 'user'

module Kpi
  module UserPatch
    def self.included(base)
		base.extend(ClassMethods)
		base.send(:include, InstanceMethods)		
	
      base.class_eval do 
		has_many :kpi_pattern_users
		has_many :kpi_patterns, :through => :kpi_pattern_users
		has_many :kpi_indicator_inspectors
		has_many :kpi_marks, :through => :kpi_indicator_inspectors

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

		def get_my_marks_num
			kpi_marks.active.where('kpi_marks.date <= ?', Date.today).count
		end

		def superior
			User.find_by_id(self.parent_id)
		end
	end	
  end
end
