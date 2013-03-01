class KpiCalcPeriod < ActiveRecord::Base
	validates_presence_of :date
	validates_presence_of :kpi_pattern_id
	validates :kpi_pattern_id, :uniqueness => { :scope => :date, :message => l(:uniq_date_and_pattern_message) }

	belongs_to :kpi_pattern
	belongs_to :kpi_imported_value
	belongs_to :manager, :class_name => 'User', :foreign_key => 'user_id'

	has_many :kpi_period_surcharges, :dependent => :destroy
	has_many :kpi_surcharges, :through => :kpi_period_surcharges

	has_many :kpi_period_users, :dependent => :destroy
	has_many :users, :through => :kpi_period_users

	has_many :kpi_period_categories, :dependent => :destroy
	has_many :kpi_categories, :through => :kpi_period_categories

	has_many :kpi_period_indicators, :through => :kpi_period_categories
	has_many :indicators, :through => :kpi_period_indicators #, :source => :indicator

	has_many :kpi_indicator_inspectors, :through => :kpi_period_indicators
	has_many :inspectors, :through => :kpi_indicator_inspectors
	has_many :kpi_marks, :through => :kpi_indicator_inspectors

	scope :actual, :conditions => "#{KpiCalcPeriod.table_name}.locked != 1 OR #{KpiCalcPeriod.table_name}.active = 1"	
	scope :active, :conditions => "#{KpiCalcPeriod.table_name}.active = 1"	
	scope :active_opened, :conditions => "#{KpiCalcPeriod.table_name}.active = 1 AND #{KpiCalcPeriod.table_name}.locked != 1 "	
	scope :novel, :conditions => "#{KpiCalcPeriod.table_name}.active != 1 AND #{KpiCalcPeriod.table_name}.locked != 1 "	
	scope :locked, :conditions => "#{KpiCalcPeriod.table_name}.locked = 1 "	

	before_save :check_period
	#has_many :indicators, :through => :kpi_indicator_inspectors	

	BASE_SALARY_PATTERNS = {
	                  1 => 'only_salary',
	                  2 => 'only_jobprice',
	                  3 => 'jobprice_and_salary'
	                  }  



	#after_create :add_inspector_marks
	def get_month_time_clock
		hours = kpi_hours_norm
		if hours.nil?
			imported_value = kpi_imported_value
			hours = imported_value.kpi_imported_month_values.where("date=?", date).first.try(:plan_value) unless imported_value.nil?
		end
		hours
		#KpiImportedMonthValue.joins(:kpi_imported_value).where("time_clocks=? AND date=?", true, date).first.try(:plan_value)
	end

	def integrity?
		inspectors_integrity? and indicators_integrity?
	end

	def for_closing?
		active and not locked and not kpi_marks.where("#{KpiMark.table_name}.fact_value IS NULL AND #{KpiMark.table_name}.disabled=0").any? and User.current.global_permission_to?('kpi_calc_periods', 'close_for_user')
		false
	end

	#def for_closing_for_user?(user)
		#active and not kpi_marks.where("#{KpiMark.table_name}.fact_value IS NULL AND #{KpiMark.table_name}.user_id = ? AND #{KpiMark.table_name}.disabled=?", user.id, false).any? and ( User.current.global_permission_to?('kpi_calc_periods', 'close_for_user') or user.subordinate?)
	#end

	def inspectors_integrity?
		inspectors_sum_integrity? and inspectors_null_percent_integrity?
	end

	def inspectors_sum_integrity?
		not kpi_indicator_inspectors.select("sum(#{KpiIndicatorInspector.table_name}.percent)").group('indicator_id').having("sum(#{KpiIndicatorInspector.table_name}.percent)!=100").to_a.any?
	end

	def inspectors_null_percent_integrity?
		not kpi_indicator_inspectors.where("#{KpiIndicatorInspector.table_name}.percent IS NULL").any?
	end

	def indicators_integrity?
		not kpi_period_indicators.where("interpretation=? AND plan_value IS NULL", Indicator::INTERPRETATION_FACT).any?
	end	

	def copy_from_pattern
		copy_categories_from_pattern
		copy_indicators_from_pattern
		copy_users_from_pattern
	end

	def for_activating?
		inspectors_sum_integrity? and inspectors_null_percent_integrity? and indicators_integrity?
	end	

	def activate
		assign_immediate_superior
		create_marks
		self.active=true
		self.save
	end

	def copy_indicators_from_pattern
		kpi_pattern.kpi_pattern_indicators.includes(:indicator).each do |e|

			KpiPeriodIndicator.create(:indicator_id => e.indicator_id,
									  :kpi_period_category_id => @copied_categories[e.indicator.kpi_category_id].id,
									  :percent => e.percent,
									  :kpi_unit_id => e.indicator.kpi_unit_id,
									  :interpretation => e.indicator.interpretation,
									  :num_on_period => e.indicator.num_on_period,
									  :input_type => e.indicator.input_type,
									  :behaviour_type => e.indicator.behaviour_type,
									  :matrix => e.indicator.matrix,
									  :pattern => e.indicator.pattern,
									  :pattern_settings => e.indicator.pattern_settings,
									  :pattern_plan => e.indicator.pattern_plan,
									  :pattern_plan_settings => e.indicator.pattern_plan_settings,
									  :max_effectiveness => e.indicator.max_effectiveness,
									  :min_effectiveness => e.indicator.min_effectiveness
									  )
			end
	end

	def copy_categories_from_pattern
		@copied_categories={}
		kpi_pattern.kpi_pattern_categories.each do |e|
			@copied_categories[e.kpi_category_id] = KpiPeriodCategory.create(:kpi_category_id => e.kpi_category_id, :kpi_calc_period_id => id, :percent => e.percent)
			end
		@copied_categories
	end

	def copy_users_from_pattern
		kpi_pattern.kpi_pattern_users.joins(:user).where("#{User.table_name}.status=?", User::STATUS_ACTIVE).each do |e|
			KpiPeriodUser.create(:user_id => e.user_id, :kpi_calc_period_id => id)
			end		
	end

	def assign_immediate_superior
		if manager.nil?
			kpi_period_indicators.joins("LEFT JOIN #{KpiIndicatorInspector.table_name} kii ON kii.kpi_period_indicator_id=#{KpiPeriodIndicator.table_name}.id")
								 .where("kii.id IS NULL").each do |e|
				KpiIndicatorInspector.create(:kpi_period_indicator_id => e.id, :percent => 100)
			end			
		else
			kpi_period_indicators.joins("LEFT JOIN #{KpiIndicatorInspector.table_name} kii ON kii.kpi_period_indicator_id=#{KpiPeriodIndicator.table_name}.id")
											 .where("kii.id IS NULL").each do |e|
							KpiIndicatorInspector.create(:kpi_period_indicator_id => e.id, :user_id => manager.id, :percent => 100)
						end						
		end
	end

	def create_marks(selected_users = nil)
		last_day_in_month = date.end_of_month.day

		kpi_period_indicators.includes(:kpi_indicator_inspectors).each do |e|
			interval = last_day_in_month.to_i/e.num_on_period.to_i
			remainder = last_day_in_month.to_i % e.num_on_period.to_i

			days=0
			(1..e.num_on_period).each do |e1|
				old_days=days
				days = days+interval

				if remainder > 0
					days += 1
					remainder -= 1
				end

				kpi_mark_end_date=date+(days-1).days
				kpi_mark_start_date=date+old_days.days

				selected_users = (selected_users.nil?) ? users : selected_users

				selected_users.each do |user|
					e.kpi_indicator_inspectors.each do |inspector|	
							KpiMark.create(:end_date => kpi_mark_end_date,
										   :start_date => kpi_mark_start_date,
										   :kpi_indicator_inspector_id => inspector.id,
										   :user_id => user.id,
										   :plan_value => e.plan_value,
										   :inspector_id => inspector.user_id.nil? ? user.superior.id : inspector.user_id )
						end
					end
				end
		end
	end

	private

    def check_period
    	if not new_record?
    		period = KpiCalcPeriod.find(id)
       		false if (locked and locked==period.locked)
    	end
    end 

end