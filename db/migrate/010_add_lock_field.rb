#  coding: utf-8
class AddLockField < ActiveRecord::Migration
  def self.up
    change_table :kpi_period_indicators do |t|
      t.boolean :locked
    end
    change_table :kpi_indicator_inspectors do |t|
      t.boolean :locked
    end
    change_table :kpi_calc_periods do |t|
      t.boolean :locked
    end
    change_table :indicators do |t|
      t.boolean :locked
    end
  end

  def self.down
    change_table :kpi_period_indicators do |t|
      t.remove :locked
    end 
    change_table :kpi_indicator_inspectors do |t|
      t.remove :locked
    end
    change_table :kpi_calc_periods do |t|
      t.remove :locked
    end
    change_table :indicators do |t|
      t.remove :locked
    end
  end
end