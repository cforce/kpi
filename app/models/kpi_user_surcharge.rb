class KpiUserSurcharge < ActiveRecord::Base
    belongs_to :kpi_surcharge
    belongs_to :kpi_period_user
end