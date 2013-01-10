class KpiPeriodIndicator < ActiveRecord::Base
	belongs_to :kpi_period_category
	belongs_to :kpi_unit
	belongs_to :indicator
	has_one :kpi_calc_period, :through => :kpi_period_category
	has_many :kpi_indicator_inspectors, :dependent => :destroy
	has_many :kpi_marks, :through => :kpi_indicator_inspectors

	before_save :check_period
	before_destroy :check_period

	serialize :matrix
	serialize :pattern_settings
	serialize :pattern_plan_settings
	
	def plan
		Indicator::INTERPRETATION_FACT == interpretation ?	plan_value : ((matrix['percent'].index('100').nil?) ? 1 : matrix['value_of_fact'][matrix['percent'].index('100')])
	end

	private

    def check_period
        false if kpi_period_category.kpi_calc_period.locked or kpi_period_category.kpi_calc_period.active
    end	
end