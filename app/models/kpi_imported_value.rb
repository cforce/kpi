class KpiImportedValue < ActiveRecord::Base
    validates_presence_of :name
    has_many :kpi_imported_month_values
end