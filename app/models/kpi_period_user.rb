class KpiPeriodUser < ActiveRecord::Base
	belongs_to :kpi_calc_period
	belongs_to :user
	has_many :kpi_period_indicators, :through => :kpi_calc_period
	has_many :kpi_indicator_inspectors, :through => :kpi_period_indicators
	has_many :kpi_marks, :through => :kpi_indicator_inspectors, :conditions => lambda {|*args| "#{KpiMark.table_name}.user_id=#{user_id}"}
	has_many :kpi_user_surcharges

	after_destroy :delete_marks
	before_save :check_period
	before_destroy :check_period
	
	def check_user_for_salary_update?(user)
		#(User.current.admin? or user.subordinate?) and not locked
		(User.current.admin?) and not locked
	end

	def check_user_for_jobprise_update?(user)
		(User.current.admin? or user.subordinate?) and not locked
	end

	def check_user_for_hours_update?(user)
		#(User.current.admin? or user.subordinate?) and not locked
		(User.current.admin?) and not locked
	end

	def check_user_for_surcharge_update?(user)
		(User.current.admin? or user.subordinate?) and not locked
	end

	def available_surcharges(user_surcharges = false, period_surcharges = false, period_not_null_surcharges = false)
		user_surcharges = kpi_user_surcharges unless user_surcharges
		period_surcharges = kpi_calc_period.kpi_surcharges unless kpi_calc_period.kpi_surcharges
		period_not_null_surcharges = period_surcharges.where("default_value IS NOT NULL").select("default_value, #{KpiSurcharge.table_name}.*") unless period_not_null_surcharges

 		KpiSurcharge.order(:name).where("
                                        (
                                        (#{KpiSurcharge.table_name}.id NOT IN (?) 
                                        AND #{KpiSurcharge.table_name}.id NOT IN (?) 
                                        AND #{KpiSurcharge.table_name}.some_values = ?)
                                        OR 
                                        #{KpiSurcharge.table_name}.some_values = ?
                                        )
                                        AND #{KpiSurcharge.table_name}.id IN (?)",
                                        user_surcharges.any? ? user_surcharges.map{|s| s.kpi_surcharge_id} : '',
                                        period_not_null_surcharges.any? ? period_not_null_surcharges : '',
                                        false,
                                        true,
                                        period_surcharges
                                        )
	end


	private	
	def delete_marks
		kpi_marks.each do |mark|
			mark.destroy
			end 
	end

    def check_period
        false if kpi_calc_period.locked and locked==KpiPeriodUser.find(id).locked
    end

end