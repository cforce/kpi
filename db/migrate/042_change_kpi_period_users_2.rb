#  coding: utf-8
class ChangeKpiPeriodUsers2 < ActiveRecord::Migration
  def self.up
    change_table :kpi_period_users do |t|
      t.integer :jobprise
      t.float :time_clock
      t.float :kpi_ratio
      t.float :salary
    end
  end

  def self.down
    change_table :kpi_period_users do |t|
      t.remove :jobprise
      t.remove :time_clock
      t.remove :kpi_ratio
      t.remove :salary
    end 
  end
end