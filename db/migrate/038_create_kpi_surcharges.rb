#  coding: utf-8
class CreateKpiSurcharges < ActiveRecord::Migration
  def self.up
    create_table :kpi_surcharges do |t|
      t.string :name
      t.boolean :changable, :null => false, :default => 1
      t.boolean :some_values, :null => false, :default => 0
      t.timestamps
    end

    KpiSurcharge.create(:name => "Связь", :changable => false)
    KpiSurcharge.create(:name => "Спорт")
    KpiSurcharge.create(:name => "Другие надбавки", :some_values => true)
  end

  def self.down
    drop_table :kpi_surcharges
  end
end