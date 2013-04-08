#  coding: utf-8
class ChangeKpiCalcPeriods < ActiveRecord::Migration
  def self.up
    change_table :kpi_calc_periods do |t|
      t.integer :parent_id
    end
  end

  def self.down
    change_table :kpi_calc_periods do |t|
      t.remove :parent_id
    end 
  end
end
