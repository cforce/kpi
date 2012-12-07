class KpiPeriodCategory < ActiveRecord::Base
	belongs_to :kpi_calc_period
	belongs_to :kpi_category
	has_many :kpi_period_indicators, :dependent => :destroy


	before_save :check_period
    before_destroy :check_period


	private

    def check_period
        false if kpi_calc_period.locked or kpi_calc_period.active
    end 
end