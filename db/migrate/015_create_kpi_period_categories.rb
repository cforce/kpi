#  coding: utf-8
class CreateKpiPeriodCategories < ActiveRecord::Migration
  def self.up
    create_table :kpi_period_categories do |t|
      t.integer :kpi_calc_period_id
      t.integer :kpi_category_id
      t.integer :percent
      t.boolean :locked, :default => false, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :kpi_period_categories
  end
end