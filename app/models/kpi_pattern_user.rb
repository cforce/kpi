class KpiPatternUser < ActiveRecord::Base
	belongs_to :kpi_pattern
	belongs_to :user
end