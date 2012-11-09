class KpiPeriodIndicator < ActiveRecord::Base
	belongs_to :kpi_period_category
	belongs_to :indicator
	has_many :kpi_indicator_inspectors, :dependent => :destroy
	has_many :kpi_marks, :through => :kpi_indicator_inspectors

	before_save :deny_save_if_period_active

	serialize :matrix
	serialize :pattern_settings
	
	def plan
		Indicator::INTERPRETATION_FACT == interpretation ?	plan_value : ((matrix['percent'].index('100').nil?) ? 1 : matrix['value_of_fact'][matrix['percent'].index('100')])
	end

	private

	def deny_save_if_period_active
		false if kpi_period_category.kpi_calc_period.active
	end
end