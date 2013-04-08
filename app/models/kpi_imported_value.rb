class KpiImportedValue < ActiveRecord::Base
    validates_presence_of :name
    has_many :kpi_imported_month_values
    belongs_to :user_department
    belongs_to :user_title
end