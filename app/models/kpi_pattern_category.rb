class KpiPatternCategory < ActiveRecord::Base
	validates :percent, :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 100 }, :allow_nil => true

	belongs_to :kpi_pattern
	belongs_to :kpi_category

	validates :kpi_pattern_id, :uniqueness => { :scope => :kpi_category_id }	
end