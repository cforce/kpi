#  coding: utf-8
class CreateKpiCalcPeriods < ActiveRecord::Migration
  def self.up
    create_table :kpi_calc_periods do |t|
      t.integer :kpi_pattern_id
      t.date :date
      t.timestamps
    end
  end

  def self.down
    drop_table :kpi_calc_periods
  end
end