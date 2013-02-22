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

	def kpi
		kpi_marks
		.order("#{KpiPeriodIndicator.table_name}.indicator_id, #{KpiMark.table_name}.inspector_id")
		.select("#{KpiPeriodCategory.table_name}.percent AS cat_percent,
				#{KpiIndicatorInspector.table_name}.percent AS ins_percent,
				#{KpiMark.table_name}.*
				")
		.where("#{KpiMark.table_name}.user_id = ?", user_id).size
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


  def base_salary_value
  	period = kpi_calc_period

  	v=nil
   	v=period.base_salary unless period.base_salary.nil?
  	v=base_salary unless base_salary.nil?
  	v
  end

	def salary(kpi=false)
		period = kpi_calc_period

		base = 0.to_f
		base += base_salary_value.to_f if KpiCalcPeriod::BASE_SALARY_PATTERNS[period.base_salary_pattern] != 'only_jobprice'
		base = base*(hours.to_f/period.get_month_time_clock.to_f) unless period.exclude_time_ratio
		base += jobprise.to_f if KpiCalcPeriod::BASE_SALARY_PATTERNS[period.base_salary_pattern] != 'only_salary'
		base*kpi.to_f+subcharge_total.to_f
	end

	def get_surcharge_details
		period_surcharges = kpi_calc_period.kpi_period_surcharges.where("default_value IS NOT NULL").includes(:kpi_surcharge).inject({}){|h, v| h[v.kpi_surcharge.name] = v.default_value; h}
		user_surcharges = kpi_user_surcharges.joins(:kpi_surcharge)
							.group("#{KpiSurcharge.table_name}.name")
							.select("#{KpiSurcharge.table_name}.name AS surcharge_name, SUM(#{KpiUserSurcharge.table_name}.value) AS surcharge")
							.inject({}){|h, v| h[v.attributes['surcharge_name']] = v.surcharge; h }
		period_surcharges.merge(user_surcharges){|key, oldval, newval| oldval+newval}
	end

	def subcharge_total
		kpi_calc_period.kpi_period_surcharges
						.where("default_value IS NOT NULL")
						.select("SUM(default_value) AS sum")
						.try(:first).try(:sum).to_f + kpi_user_surcharges
													.select("SUM(#{KpiUserSurcharge.table_name}.value) AS sum").try(:first).try(:sum).to_f
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