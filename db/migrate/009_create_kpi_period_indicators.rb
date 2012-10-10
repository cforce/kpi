#  coding: utf-8
class CreateKpiPeriodIndicators < ActiveRecord::Migration
  def self.up
    create_table :kpi_period_indicators do |t|
      t.integer :kpi_calc_period_id
      t.integer :indicator_id
      t.integer :percent
      t.float :plan_value
      t.float :fact_value
      t.timestamps
    end
  end

  def self.down
    drop_table :kpi_period_indicators
  end
end