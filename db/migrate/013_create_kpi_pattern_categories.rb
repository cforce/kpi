#  coding: utf-8
class CreateKpiPatternCategories < ActiveRecord::Migration
  def self.up
    create_table :kpi_pattern_categories do |t|
      t.integer :kpi_pattern_id
      t.integer :kpi_category_id
      t.integer :percent
      t.timestamps
    end
  end

  def self.down
    drop_table :kpi_pattern_categories
  end
end