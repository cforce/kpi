#  coding: utf-8
class CreateKpiHoursNorms < ActiveRecord::Migration
  def self.up
    create_table :kpi_hours_norms do |t|
      t.integer :norm
      t.string :name
      t.timestamps
    end

    KpiHoursNorm.create(:norm => 143, :name => "Сборщик")
  end

  def self.down
    drop_table :kpi_hours_norms
  end
end