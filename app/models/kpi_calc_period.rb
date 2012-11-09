class KpiCalcPeriod < ActiveRecord::Base
	validates_presence_of :date
	validates_presence_of :kpi_pattern_id
	validates :kpi_pattern_id, :uniqueness => { :scope => :date, :message => l(:uniq_date_and_pattern_message) }

	belongs_to :kpi_pattern

	has_many :kpi_period_users, :dependent => :destroy
	has_many :users, :through => :kpi_period_users

	has_many :kpi_period_categories, :dependent => :destroy
	has_many :kpi_categories, :through => :kpi_period_categories

	has_many :kpi_period_indicators, :through => :kpi_period_categories
	has_many :indicators, :through => :kpi_period_indicators #, :source => :indicator

	has_many :kpi_indicator_inspectors, :through => :kpi_period_indicators
	has_many :inspectors, :through => :kpi_indicator_inspectors

	scope :actual, :conditions => "#{KpiCalcPeriod.table_name}.locked != 1 OR #{KpiCalcPeriod.table_name}.active = 1"	
	scope :active, :conditions => "#{KpiCalcPeriod.table_name}.active = 1"	
	scope :active_opened, :conditions => "#{KpiCalcPeriod.table_name}.active = 1 AND #{KpiCalcPeriod.table_name}.locked != 1 "	


	#before_save :deny_save_if_period_active
	#has_many :indicators, :through => :kpi_indicator_inspectors	

	#after_create :add_inspector_marks

	def integrity?
		inspectors_integrity? and indicators_integrity?
	end

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
		not kpi_period_indicators.joins(:indicator).where("indicators.interpretation=? AND plan_value IS NULL", Indicator::INTERPRETATION_FACT).any?
	end	

	def copy_from_pattern
		copy_categories_from_pattern
		copy_indicators_from_pattern
		copy_users_from_pattern
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
									  :pattern_settings => e.indicator.pattern_settings
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
		kpi_pattern.kpi_pattern_users.each do |e|
			KpiPeriodUser.create(:user_id => e.user_id, :kpi_calc_period_id => id)
			end		
	end

	def assign_immediate_superior
		kpi_period_indicators.joins("LEFT JOIN #{KpiIndicatorInspector.table_name} kii ON kii.kpi_period_indicator_id=#{KpiPeriodIndicator.table_name}.id")
							 .where("kii.id IS NULL").each do |e|
			KpiIndicatorInspector.create(:kpi_period_indicator_id => e.id, :percent => 100)
		end
	end

	def create_marks
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
				users.each do |user|
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

	def deny_save_if_period_active
		false if active
	end

end