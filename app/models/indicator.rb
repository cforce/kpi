class Indicator < ActiveRecord::Base
  validates_presence_of :name, :kpi_category_id, :kpi_unit_id, :interpretation
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 120

  serialize :matrix

  belongs_to :kpi_category
  belongs_to :kpi_unit
  belongs_to :kpi_pattern

  INTERPRETATION_FACT = 0
  INTERPRETATION_MATRIX = 1
end