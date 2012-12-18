#  coding: utf-8
class ChangeKpiPeriodIndicators < ActiveRecord::Migration
  def self.up
    change_table :kpi_period_indicators do |t|
      t.integer :pattern_plan
      t.text :pattern_plan_settings
    end
  end

  def self.down
    change_table :kpi_period_indicators do |t|
      t.remove :pattern_plan
      t.remove :pattern_plan_settings
    end 
  end
end