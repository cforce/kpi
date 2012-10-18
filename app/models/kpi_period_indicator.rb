class KpiPeriodIndicator < ActiveRecord::Base
	belongs_to :kpi_period_category
	belongs_to :indicator
	has_many :kpi_indicator_inspectors, :dependent => :destroy

end