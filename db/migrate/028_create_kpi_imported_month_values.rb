#  coding: utf-8
class CreateKpiImportedMonthValues < ActiveRecord::Migration
  def self.up
    create_table :kpi_imported_month_values do |t|
      t.integer :kpi_imported_value_id
      t.float :plan_value
      t.float :fact_value
      t.date :date
      t.timestamps
    end
  end

  def self.down
    drop_table :kpi_imported_month_values
  end
end