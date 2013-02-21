class KpiPeriodSurcharge < ActiveRecord::Base
    belongs_to :kpi_calc_period
    belongs_to :kpi_surcharge
end