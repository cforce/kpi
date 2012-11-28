class Indicator < ActiveRecord::Base
  validates_presence_of :name, :kpi_category_id, :kpi_unit_id, :interpretation
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 120
  validate :matrix_has_more_two_items, :matrix_should_not_have_empty_values
  before_destroy :pattern_not_exist
 
  serialize :matrix
  serialize :pattern_settings

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

  INPUT_TYPES={'0' => 'direct_input',
               '1' => 'exact_values'}

  FACT_PATTERNS = {
                  '' => 'no_pattern',
                  '1' => 'avg_custom_field_mark_in_current_period',
                  '2' => 'issue_hours_in_current_period',
                  '3' => 'issue_lag_in_current_period',
                  '4' => 'self_and_executors_issues_lag',
                  '5' => 'self_and_executors_issues_avg_custom_field_mark'
                  }     

  MAX_NUM_IN_PERIOD=5          

  def pattern_not_exist 	
    errors.add(:base, l(:you_can_not_destroy_indicator)) if kpi_pattern_indicators.any?
    errors.blank?
  end

  def to_s
  	name
  end

  def matrix_has_more_two_items
    errors.add(:matrix, l(:have_to_have_more_then_one_item)) if interpretation == Indicator::INTERPRETATION_MATRIX and matrix['value_of_fact'].size<2
  end

  def matrix_should_not_have_empty_values
    errors.add(:matrix, l(:should_not_have_empty_values)) if interpretation == Indicator::INTERPRETATION_MATRIX and (matrix['value_of_fact'].include?("") or matrix['percent'].include?(""))
  end
end