class KpiPeriodCategory < ActiveRecord::Base
	belongs_to :kpi_calc_period
	has_many :kpi_period_indicators, :dependent => :destroy

end