class KpiPeriodCategory < ActiveRecord::Base
	belongs_to :kpi_calc_period
	belongs_to :kpi_category
end