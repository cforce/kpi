class KpiSurcharge < ActiveRecord::Base
    has_many :kpi_period_surcharge

    def list_name
        default_value.nil? ? name : "#{name}".html_safe
    end
end