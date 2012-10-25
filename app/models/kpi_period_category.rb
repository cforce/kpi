class KpiPeriodCategory < ActiveRecord::Base
	belongs_to :kpi_calc_period
	belongs_to :kpi_category
	has_many :kpi_period_indicators, :dependent => :destroy


	before_save :deny_save_if_period_active


	private

	def deny_save_if_period_active
		false if kpi_calc_period.active
	end
end