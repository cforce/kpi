class KpiSurcharge < ActiveRecord::Base

    has_many :kpi_period_surcharges

    def list_name
        default_value.nil? ? name : "#{name}".html_safe
    end
end