#  coding: utf-8
class ChangeKpiCalcPeriods2 < ActiveRecord::Migration
  def self.up
    change_table :kpi_calc_periods do |t|
      t.integer :base_salary
    end
  end

  def self.down
    change_table :kpi_calc_periods do |t|
      t.remove :base_salary
    end 
  end
end
