module Kpi
  module ProjectPatch
    def self.included(base)
		base.extend(ClassMethods)
		base.send(:include, InstanceMethods)		
	
      base.class_eval do 
		has_many :all_members, :class_name => 'Member'
      end
	  
    end
	
	module ClassMethods   
	end
	
	module InstanceMethods
	end	
  end
end
