#  coding: utf-8
class ChangeKpiPeriodUsers2 < ActiveRecord::Migration
  def self.up
    change_table :kpi_period_users do |t|
      t.integer :jobprise
    end
  end

  def self.down
    change_table :kpi_period_users do |t|
      t.remove :jobprise
    end 
  end
end