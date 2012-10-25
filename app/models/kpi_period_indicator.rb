class KpiPeriodIndicator < ActiveRecord::Base
	belongs_to :kpi_period_category
	belongs_to :indicator
	has_many :kpi_indicator_inspectors, :dependent => :destroy

	before_save :deny_save_if_period_active

	serialize :matrix

	private

	def deny_save_if_period_active
		false if kpi_period_category.kpi_calc_period.active
	end
end