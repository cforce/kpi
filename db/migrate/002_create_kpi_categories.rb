#  coding: utf-8
class CreateKpiCategories < ActiveRecord::Migration
  def self.up
    create_table :kpi_categories do |t|
      t.string :name
      t.string :color
      t.timestamps
    end

    KpiCategory.create(:name => "Личный план работ", :color => "red")
    KpiCategory.create(:name => "Обратная связь", :color => "green")
    KpiCategory.create(:name => "KPI-показатели", :color => "blue")
  end

  def self.down
    drop_table :kpi_categories
  end
end