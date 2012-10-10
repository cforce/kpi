#  coding: utf-8
class CreateKpiIndicatorInspectors < ActiveRecord::Migration
  def self.up
    create_table :kpi_indicator_inspectors do |t|
      t.integer :kpi_calc_period_id
      t.integer :indicator_id
      t.integer :user_id
      t.integer :percent
      t.float :fact_value
      t.timestamps
    end
  end

  def self.down
    drop_table :kpi_indicator_inspectors
  end
end