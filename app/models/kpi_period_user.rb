class KpiPeriodUser < ActiveRecord::Base
	belongs_to :kpi_calc_period
	belongs_to :user
end