#  coding: utf-8
class CreateKpiCategories < ActiveRecord::Migration
  def self.up
    create_table :kpi_categories do |t|
      t.string :name
      t.string :color
      t.timestamps
    end

    KpiCategory.create(:name => "Личный план работ", :color => "red", :percent => 30)
    KpiCategory.create(:name => "Обратная связь", :color => "green", :percent => 40)
    KpiCategory.create(:name => "KPI-показатели", :color => "blue", :percent => 30)
  end

  def self.down
    drop_table :kpi_categories
  end
end