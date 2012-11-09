#  coding: utf-8
class CreateKpiCategories < ActiveRecord::Migration
  def self.up
    create_table :kpi_categories do |t|
      t.string :name
      t.string :color
      t.integer :percent, :default => false
      t.timestamps
    end

    KpiCategory.create(:name => "Общие показатели", :color => "green", :percent => 100)
    # KpiCategory.create(:name => "Личный план работ", :color => "red")
    # KpiCategory.create(:name => "Обратная связь", :color => "green")
    # KpiCategory.create(:name => "KPI-показатели", :color => "blue")
  end

  def self.down
    drop_table :kpi_categories
  end
end