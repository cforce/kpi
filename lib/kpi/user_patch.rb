
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
		has_many :kpi_applied_reports
		has_many :kpi_managed_periods, :table_name => KpiCalcPeriod.table_name

		scope :not_in_kpi_pattern, lambda {|pattern|
		    pattern_id = pattern.is_a?(KpiPattern) ? pattern.id : pattern.to_i
		    { :conditions => ["#{User.table_name}.id NOT IN (SELECT pu.user_id FROM kpi_pattern_users pu WHERE pu.kpi_pattern_id = ?)", pattern_id] }
		  	}		

		scope :not_in_kpi_period, lambda {|period|
		    period_id = period.is_a?(KpiCalcPeriod) ? period.id : period.to_i
		    { :conditions => ["#{User.table_name}.id NOT IN (SELECT pu.user_id FROM kpi_period_users pu WHERE pu.kpi_calc_period_id = ?)", period_id] }
		  	}
      end
	  
    end
	
	module ClassMethods   
	end
	
	module InstanceMethods

		def has_managed_periods?
			KpiPeriodUser.joins(:kpi_calc_period, :user => [:user_tree])                                          
			             .where("(#{UserTree.table_name}.lft>? AND #{UserTree.table_name}.rgt<? AND #{KpiCalcPeriod.table_name}.user_id IS NULL)
			              			OR (#{KpiCalcPeriod.table_name}.user_id = ?)",
			                    user_tree.lft, user_tree.right, id)
			             .any?
		end

		def imported_values
			KpiImportedValue.order(:name).where(:user_department_id => self.user_department_id, :user_title_id => self.user_title_id)
		end

		def user_kpi_marks_can_be_disabled?(period_user)
			(User.current.admin? or subordinate?) and not period_user.locked
		end

		def kpi_mark_can_be_disabled?(mark)
			(User.current.admin? or subordinate?) and not mark.locked
		end

		def my_kpi_marks_caption
			label=l(:my_kpi_marks)
			num=get_my_marks_num
			label+=" (#{num})" if num>0
			label
		end

		def get_my_marks
			kpi_inspector_marks.joins(:kpi_period_indicator)
							   .where("#{KpiMark.table_name}.start_date <= ? 
										AND #{KpiPeriodIndicator.table_name}.pattern is NULL 
										AND #{KpiMark.table_name}.locked = ?
										",
										Date.today, false)
			#AND #{KpiMark.table_name}.disabled = ?
		end

		def get_my_marks_num
			get_my_marks.where("#{KpiMark.table_name}.fact_value IS NULL").count
		end

		def superior
			User.find_by_id(self.parent_id)
		end

		def subordinates
			User.active.where("#{Setting.plugin_kpi['user_superior_id_field']} = ?", id);
		end

		def unders
			User.joins(:user_tree).where("#{UserTree.table_name}.lft>? AND #{UserTree.table_name}.rgt<?", user_tree.lft, user_tree.rgt)
		end

		def subordinate?
			eval('self.'+Setting.plugin_kpi['user_superior_id_field']) == User.current.id
		end

		def under?
			#current_user_in_tree = UserTree.find(User.current.id)
			#selected_user_in_tree = UserTree.find(id)
			UserTree.joins("INNER JOIN #{UserTree.table_name} AS ut ON #{UserTree.table_name}.lft<ut.lft AND #{UserTree.table_name}.rgt>ut.rgt AND ut.id = #{id}")
					.where("#{UserTree.table_name}.id = ?", User.current.id).count > 0
		end

		def find_default_kpi_mark_date
			date = kpi_calc_periods.active_opened.select("MAX(date) AS 'max_date'").first.max_date
			date = Date.current.beginning_of_month if date.nil?
			date
		end

		def find_default_effectiveness_date
			date = kpi_calc_periods.active.select("MAX(date) AS 'max_date'").first.max_date
			date = Date.current.beginning_of_month if date.nil?
			date
		end
	end	
  end
end
