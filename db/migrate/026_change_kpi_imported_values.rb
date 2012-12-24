#  coding: utf-8
class ChangeKpiImportedValues < ActiveRecord::Migration
  def self.up
    rename_column :kpi_imported_values, :value, :plan_value
    change_table :kpi_imported_values do |t|
      t.remove :pseudonym
      t.float :fact_value
      t.boolean :fact_value_enable, :default => true, :null => false
      t.boolean :plan_value_enable, :default => true, :null => false
    end
  end

  def self.down
    rename_column :kpi_imported_values, :plan_value, :value
    change_table :kpi_imported_values do |t|
      t.string :pseudonym
      t.remove :fact_value
      t.remove :fact_value_enable
      t.remove :plan_value_enable
    end 
  end
end