class KpiUserSurcharge < ActiveRecord::Base
    validates :kpi_surcharge_id, :value, :presence => true

    belongs_to :kpi_surcharge
    belongs_to :kpi_period_user
end