#  coding: utf-8
class ChangeKpiPeriodUsers < ActiveRecord::Migration
  def self.up
    change_table :kpi_period_users do |t|
      t.float :hours
      t.integer :base_salary
    end
  end

  def self.down
    change_table :kpi_period_users do |t|
      t.remove :hours
      t.remove :base_salary
    end 
  end
end