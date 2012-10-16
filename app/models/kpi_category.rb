class KpiCategory < ActiveRecord::Base
	has_many :indicators
	has_many :kpi_pattern_categories
	has_many :kpi_period_categories
end