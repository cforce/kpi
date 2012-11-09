#  coding: utf-8
class CreateKpiPeriodIndicators < ActiveRecord::Migration
  def self.up
    create_table :kpi_period_indicators do |t|
      t.integer :kpi_period_category_id
      t.integer :indicator_id
      t.integer :percent
      t.float :plan_value
      t.float :fact_value
      t.integer :kpi_unit_id
      t.integer :interpretation
      t.integer :num_on_period, :default => 1
      t.integer :input_type, :null => false, :default => 0
      t.integer :behaviour_type, :null => false, :default => 0
      t.text :matrix
      t.integer :pattern
      t.text :pattern_settings      
      t.timestamps
    end
  end

  def self.down
    drop_table :kpi_period_indicators
  end
end