class KpiPeriodIndicator < ActiveRecord::Base
	belongs_to :kpi_period_category
	belongs_to :kpi_unit
	belongs_to :indicator
	has_one :kpi_calc_period, :through => :kpi_period_category
	has_many :kpi_indicator_inspectors, :dependent => :destroy
	has_many :kpi_marks, :through => :kpi_indicator_inspectors

	before_save :check_period
	before_destroy :check_period_before_destroy

	serialize :matrix
	serialize :pattern_settings
	serialize :pattern_plan_settings
	
	def plan
		Indicator::INTERPRETATION_FACT == interpretation ?	plan_value : ((matrix['percent'].index('100').nil?) ? 1 : matrix['value_of_fact'][matrix['percent'].index('100')])
	end

    def check_for_cutting?
    	((not min_effectiveness.nil?) or (not max_effectiveness.nil?)) and Indicator::INTERPRETATION_FACT == interpretation
    end

	private

    def check_period
        false if kpi_period_category.kpi_calc_period.locked or kpi_period_category.kpi_calc_period.active
    end	

    def check_period_before_destroy
      false if kpi_period_category.kpi_calc_period.locked
    end
end