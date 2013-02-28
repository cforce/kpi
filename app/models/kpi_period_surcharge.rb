class KpiPeriodSurcharge < ActiveRecord::Base
    belongs_to :kpi_calc_period
    belongs_to :kpi_surcharge

    before_save :check_period
    before_destroy :check_period_before_destroy

    def check_period
      false if kpi_calc_period.locked
    end 

    def check_period_before_destroy
      false if kpi_calc_period.locked
    end

end