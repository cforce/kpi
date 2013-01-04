#  coding: utf-8
class ChangeKpiImportedValues1 < ActiveRecord::Migration
  def self.up
    change_table :kpi_imported_values do |t|
      t.remove :fact_value
      t.remove :plan_value
    end
  end

  def self.down
    change_table :kpi_imported_values do |t|
      t.float :fact_value
      t.float :plan_value
    end 
  end
end