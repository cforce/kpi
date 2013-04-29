class KpiPeriodUser < ActiveRecord::Base
	belongs_to :kpi_calc_period
	belongs_to :user
	has_many :kpi_period_indicators, :through => :kpi_calc_period
	has_many :kpi_indicator_inspectors, :through => :kpi_period_indicators
	has_many :kpi_marks, :through => :kpi_indicator_inspectors, :conditions => lambda {|*args| "#{KpiMark.table_name}.user_id=#{user_id}"}
	has_many :kpi_user_surcharges, :dependent => :destroy

	after_destroy :delete_marks
	before_save :check_period
	before_destroy :check_period

	include KpiHelper
	
	def check_user_for_salary_update?(user)
		substitutable_employees = User.current.substitutable_employees

		(User.current.admin? or ((user.subordinate? or substitutable_employees.map(&:id).include?(user.parent_id) or kpi_calc_period.user_id==User.current.id or substitutable_employees.map(&:id).include?(kpi_calc_period.user_id)) and kpi_calc_period.allowed_change_salary)) and not self.locked
	end

	def check_user_for_jobprise_update?(user)
		substitutable_employees = User.current.substitutable_employees
		(User.current.admin? or user.subordinate? or substitutable_employees.map(&:id).include?(user.parent_id) or kpi_calc_period.user_id==User.current.id or substitutable_employees.map(&:id).include?(kpi_calc_period.user_id)) and not self.locked
	end

	def check_user_for_hours_update?(user)
		#(User.current.admin? or user.subordinate?) and not locked
		(User.current.admin?) and not locked
	end

	def check_user_for_surcharge_update?
		substitutable_employees = User.current.substitutable_employees

		(User.current.admin? or user.subordinate? or substitutable_employees.map(&:id).include?(user.parent_id) or kpi_calc_period.user_id==User.current.id or substitutable_employees.map(&:id).include?(kpi_calc_period.user_id)) and not self.locked
	end

	def check_user_for_surcharge_show?
		(User.current.admin? or user.subordinate? or user = User.current)
	end

	def set_kpi_marks
		kpi_marks.where("#{KpiMark.table_name}.fact_value IS NOT NULL OR #{KpiMark.table_name}.disabled = ?", true)
	end

	def reopen
        if  for_opening?
        	self.locked = false
        	self.save 

        	kpi_calc_period.locked = false
        	kpi_calc_period.save

        	kpi_marks.where("#{KpiMark.table_name}.user_id = ?", user_id).update_all("#{KpiMark.table_name}.locked=0")
        end
	end

	def close
        if for_closing?
        		self.salary = get_salary(kpi)
        		self.kpi_ratio = kpi[:cut_ratio]
            self.locked = true
            self.save

            kpi_calc_period.kpi_hours_norm = kpi_calc_period.get_month_time_clock

            if KpiPeriodUser.where("#{KpiPeriodUser.table_name}.kpi_calc_period_id = ? AND #{KpiPeriodUser.table_name}.locked = ? ", kpi_calc_period_id, false).count == 0
                kpi_calc_period.locked = true
            end

            kpi_calc_period.save

            kpi_marks.where("#{KpiMark.table_name}.user_id = ?", user_id).update_all("#{KpiMark.table_name}.locked=1")
        end
	end

	def for_opening?
		locked and user_for_opening? and not KpiAppliedReport.where(:user_department_id => user.top_department.id).any?
	end

	def user_for_opening?
		substitutable_employees = User.current.substitutable_employees
		(user.subordinate? or substitutable_employees.map(&:id).include?(user.parent_id) or kpi_calc_period.user_id==User.current.id or substitutable_employees.map(&:id).include?(kpi_calc_period.user_id) or User.current.admin?)
	end

	def for_closing?
		substitutable_employees = User.current.substitutable_employees
		period = kpi_calc_period
		period.active and not period.kpi_marks.where("#{KpiMark.table_name}.fact_value IS NULL AND #{KpiMark.table_name}.user_id = ? AND #{KpiMark.table_name}.disabled=?", user.id, false).any? and ( User.current.global_permission_to?('kpi_calc_periods', 'close_for_user') or user.subordinate? or substitutable_employees.map(&:id).include?(user.parent_id) or kpi_calc_period.user_id==User.current.id or substitutable_employees.map(&:id).include?(kpi_calc_period.user_id)) and is_salary_calc_attr?
	end

	def is_salary_calc_attr?
		period = kpi_calc_period
		(((not hours.nil?) and (period.get_month_time_clock)) or (period.exclude_time_ratio or KpiCalcPeriod::BASE_SALARY_PATTERNS[period.base_salary_pattern] == 'only_jobprice' )) and (((not base_salary.nil?) or (not period.base_salary.nil?)) or KpiCalcPeriod::BASE_SALARY_PATTERNS[period.base_salary_pattern] == 'only_jobprice') and ((not jobprise.nil?) or KpiCalcPeriod::BASE_SALARY_PATTERNS[period.base_salary_pattern] == 'only_salary')
	end

	def kpi_ratio_value(kpi_values=false)
		kpi_values = kpi unless kpi_values
		v = nil
		v = kpi_ratio if locked
		v = kpi_values[:cut_ratio] if (not locked) and (not kpi_values.nil?)
		v
	end

	def kpi
		kpi_completions = []
		mark_avg = []
		indicator_avg = []
		cat_avg = []
		category_id, indicator_id, indicator_percent, inspector_id, avg_value, category_percent, inspector_percent  = nil

		kpi_marks
		.includes("kpi_period_indicator")
		.order("#{KpiPeriodCategory.table_name}.kpi_category_id,
				#{KpiPeriodIndicator.table_name}.indicator_id,
				#{KpiMark.table_name}.inspector_id, 
				#{KpiMark.table_name}.start_date")
		.select("#{KpiPeriodCategory.table_name}.percent AS cat_percent,
				#{KpiPeriodCategory.table_name}.kpi_category_id AS category_id,
				#{KpiPeriodIndicator.table_name}.indicator_id AS indicator_id,
				#{KpiPeriodIndicator.table_name}.percent AS indicator_percent,
				#{KpiPeriodIndicator.table_name}.max_effectiveness AS max_effectiveness,
				#{KpiPeriodIndicator.table_name}.min_effectiveness AS min_effectiveness,
				#{KpiIndicatorInspector.table_name}.percent AS ins_percent,
				#{KpiMark.table_name}.*
				")
		.where("#{KpiMark.table_name}.disabled = ?
				 AND #{KpiMark.table_name}.fact_value IS NOT NULL
				 AND (
				 	 (#{KpiMark.table_name}.plan_value IS NOT NULL AND #{KpiPeriodIndicator.table_name}.interpretation = ?) OR (#{KpiPeriodIndicator.table_name}.interpretation = ?)
				 	 )
				", false, Indicator::INTERPRETATION_FACT, Indicator::INTERPRETATION_MATRIX).each do |mark|
			if inspector_id != mark.inspector_id or indicator_id!= mark.attributes['indicator_id'] or category_id != mark.attributes['category_id']
				if kpi_completions!=[]
					avg_value = kpi_completions.inject(0){|sum, v| sum+=v; sum}/kpi_completions.size
					kpi_completions = []
					mark_avg << {:category_id => category_id,
					 				 :category_percent => category_percent,
					 				 :indicator_id => indicator_id,
					 				 :indicator_percent => indicator_percent,
					 				 :inspector_percent => inspector_percent,
					 				 :inspector_id => inspector_id,
					 				 :avg_value => avg_value}
				end

				category_id = mark.attributes['category_id']
				category_percent = mark.attributes['cat_percent']
				indicator_id = mark.attributes['indicator_id']
				inspector_percent = mark.attributes['ins_percent']
				indicator_percent = mark.attributes['indicator_percent']
				inspector_id = mark.inspector_id
			end
		kpi_completions << get_cut_value(mark.completion, mark.attributes['max_effectiveness'], mark.attributes['min_effectiveness'])
		end

		unless category_id.nil?

					avg_value = kpi_completions.inject(0){|sum, v| sum+=v; sum}/kpi_completions.size
					kpi_completions = []
					mark_avg << {:category_id => category_id,
					 				 :category_percent => category_percent,
					 				 :indicator_id => indicator_id,
					 				 :indicator_percent => indicator_percent,
					 				 :inspector_percent => inspector_percent,
					 				 :inspector_id => inspector_id,
					 				 :avg_value => avg_value}

			category_id, indicator_id, indicator_percent, inspector_id, avg_value, category_percent, inspector_percent  = nil	
			#----------------------------------------------------------

			mark_avg.each do |mark|

				if indicator_id!= mark[:indicator_id] or category_id != mark[:category_id]
					
					if kpi_completions!=[]
						avg_value = kpi_completions.inject(0){|avg, v| avg+=(v[:avg_value]*v[:inspector_percent])/100; avg}
						kpi_completions = []
						indicator_avg << {:category_id => category_id,
										  :category_percent => category_percent, 
										  :indicator_id => indicator_id,
										  :indicator_percent => indicator_percent,
										  :avg_value => avg_value}
					end

					category_id = mark[:category_id]
					category_percent = mark[:category_percent]
					indicator_percent = mark[:indicator_percent]
					indicator_id = mark[:indicator_id]
				end

				kpi_completions << {:avg_value => mark[:avg_value], :inspector_percent => mark[:inspector_percent]}
			end

						avg_value = kpi_completions.inject(0){|avg, v| avg+=(v[:avg_value]*v[:inspector_percent])/100; avg}
						kpi_completions = []
						indicator_avg << {:category_id => category_id,
										  :category_percent => category_percent, 
										  :indicator_id => indicator_id,
										  :indicator_percent => indicator_percent,
										  :avg_value => avg_value}
			#----------------------------------------------------------

			category_id, indicator_id, indicator_percent, inspector_id, avg_value, category_percent, inspector_percent  = nil

			#----------------------------------------------------------
			indicator_avg.each do |mark|
				if category_id != mark[:category_id]
					if kpi_completions!=[]
						avg_value = kpi_completions.inject(0){|avg, v| avg+=(v[:avg_value]*v[:indicator_percent])/100; avg}
						kpi_completions = []
						cat_avg << {:category_id => category_id,
									:category_percent => category_percent,
									:avg_value => avg_value}
					end

					category_id = mark[:category_id]
					category_percent = mark[:category_percent]
				end

				kpi_completions << {:avg_value => mark[:avg_value], :indicator_percent => mark[:indicator_percent]}
			end

			#avg_value = kpi_completions.inject(0){|avg, v| avg+=(v[:avg_value]*v[:indicator_percent])/100; avg}

			avg_value = kpi_completions.inject(0){|avg, v| avg+=(v[:avg_value]*v[:indicator_percent])/100; avg}
			kpi_completions = []
						cat_avg << {:category_id => category_id,
									:category_percent => category_percent,
									:avg_value => avg_value}

			#----------------------------------------------------------

			ratio = cat_avg.inject(0){|r, v| r += (v[:category_percent]*v[:avg_value])/100; r }

			return {:ratio => ratio,
						  :cut_ratio => get_cut_value(ratio, Setting.plugin_kpi['max_kpi'].to_f, Setting.plugin_kpi['min_kpi'].to_f),
							:data => {:indicator_avg => indicator_avg}}

		end

		nil
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


  def time_ratio
		return nil if hours.nil? or kpi_calc_period.get_month_time_clock.nil?
		time_raio = hours.to_f/kpi_calc_period.get_month_time_clock.to_f
		time_raio
  end

  def main_money
			base = 0.to_f
			if KpiCalcPeriod::BASE_SALARY_PATTERNS[kpi_calc_period.base_salary_pattern] != 'only_jobprice'
				return nil if base_salary_value.nil?
				base += base_salary_value.to_f 
			end
			if (not kpi_calc_period.exclude_time_ratio) and KpiCalcPeriod::BASE_SALARY_PATTERNS[kpi_calc_period.base_salary_pattern] != 'only_jobprice'
				return nil if time_ratio.nil?
				base = base*time_ratio
			end
			if KpiCalcPeriod::BASE_SALARY_PATTERNS[kpi_calc_period.base_salary_pattern] != 'only_salary'
				return nil if jobprise.nil?
				base += jobprise.to_f
			end 
			base
  end

	def get_salary(kpi_values=false)
		if locked
			salary
		else
			return nil if main_money.nil? or kpi_ratio_value(kpi_values).nil?
			#Rails.logger.debug "gggggggggg #{kpi_ratio_value(kpi_values).round(2)}"
			main_money*kpi_ratio_value(kpi_values).round(2)/100+subcharge_total.to_f
		end
	end

	def get_surcharge_details
		period_surcharges = kpi_calc_period.kpi_period_surcharges.where("default_value IS NOT NULL").includes(:kpi_surcharge).inject({}){|h, v| h[v.kpi_surcharge.name] = v.default_value; h}
		user_surcharges = kpi_user_surcharges.joins(:kpi_surcharge)
							.group("#{KpiSurcharge.table_name}.name")
							.select("#{KpiSurcharge.table_name}.name AS surcharge_name, SUM(#{KpiUserSurcharge.table_name}.value) AS surcharge")
							.inject({}){|h, v| h[v.attributes['surcharge_name']] = v.surcharge; h }
		period_surcharges.merge(user_surcharges){|key, oldval, newval| oldval+newval}
	end

	def get_positive_surcharge_details
		period_surcharges = kpi_calc_period.kpi_period_surcharges.where("default_value IS NOT NULL").includes(:kpi_surcharge).inject({}){|h, v| h[v.kpi_surcharge.name] = v.default_value if v.default_value>=0; h}
		user_surcharges = kpi_user_surcharges.joins(:kpi_surcharge)
							.group("#{KpiSurcharge.table_name}.name")
							.select("#{KpiSurcharge.table_name}.name AS surcharge_name, SUM(#{KpiUserSurcharge.table_name}.value) AS surcharge")
							.where("#{KpiUserSurcharge.table_name}.value >= 0")
							.inject({}){|h, v| h[v.attributes['surcharge_name']] = v.surcharge; h }
		period_surcharges.merge(user_surcharges){|key, oldval, newval| oldval+newval}
	end

	def subcharge_total
		kpi_calc_period.kpi_period_surcharges
						.where("default_value IS NOT NULL")
						.select("SUM(default_value) AS sum")
						.try(:first).try(:sum).to_f + kpi_user_surcharges
													.select("SUM(#{KpiUserSurcharge.table_name}.value) AS sum").try(:first).try(:sum).to_f.round(2)
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