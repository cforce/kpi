class KpiPatternIndicator < ActiveRecord::Base
	validates :percent, :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 100 }, :allow_nil => true

	belongs_to :kpi_pattern
	belongs_to :indicator
end