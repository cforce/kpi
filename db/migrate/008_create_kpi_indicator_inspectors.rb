#  coding: utf-8
class CreateKpiIndicatorInspectors < ActiveRecord::Migration
  def self.up
    create_table :kpi_indicator_inspectors do |t|
      t.integer :kpi_period_indicator_id
      t.integer :user_id
      t.integer :percent
      t.timestamps
    end
  end

  def self.down
    drop_table :kpi_indicator_inspectors
  end
end