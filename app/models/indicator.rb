class Indicator < ActiveRecord::Base
  validates_presence_of :name, :kpi_category_id, :kpi_unit_id, :interpretation
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 120
  before_destroy :pattern_not_exist
 
  serialize :matrix

  belongs_to :kpi_category
  belongs_to :kpi_unit
  belongs_to :kpi_pattern

  has_many :kpi_pattern_indicators
  has_many :kpi_patterns, :through => :kpi_pattern_indicators

  has_many :kpi_period_indicators
  has_many :kpi_calc_periods, :through => :kpi_period_indicators

	scope :not_in_kpi_pattern, lambda {|pattern|
		pattern_id = pattern.is_a?(KpiPattern) ? pattern.id : pattern.to_i
		{ :conditions => ["#{Indicator.table_name}.id NOT IN (SELECT pi.indicator_id FROM kpi_pattern_indicators pi WHERE pi.kpi_pattern_id = ?)", pattern_id] }
		}  

  INTERPRETATION_FACT = 0
  INTERPRETATION_MATRIX = 1

  def pattern_not_exist 	
    errors.add(:base, l(:you_can_not_destroy_indicator)) if kpi_pattern_indicators.any?
    errors.blank?
  end

  def to_s
  	name
  end
end