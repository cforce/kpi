class KpiPatternIndicator < ActiveRecord::Base
	belongs_to :kpi_pattern
	belongs_to :indicator
end