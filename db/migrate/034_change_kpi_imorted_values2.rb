#  coding: utf-8
class ChangeKpiImortedValues2 < ActiveRecord::Migration
  def self.up
    change_table :kpi_imported_values do |t|
      t.boolean :time_clocks, :default => false, :null => false
    end
  end

  def self.down
    change_table :kpi_imported_values do |t|
      t.remove :time_clocks
    end 
  end
end
