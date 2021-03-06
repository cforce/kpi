#  coding: utf-8
class CreateKpiUnits < ActiveRecord::Migration
  def self.up
    create_table :kpi_units do |t|
      t.string :name
      t.string :abridgement
      t.timestamps
    end

    KpiUnit.create(:name => "Дни", :abridgement => "дн.")
    KpiUnit.create(:name => "Часы", :abridgement => "ч.")
    KpiUnit.create(:name => "Рубли", :abridgement => "р.")
    KpiUnit.create(:name => "Штуки", :abridgement => "")
    KpiUnit.create(:name => "Процент", :abridgement => "%")
  end

  def self.down
    drop_table :kpi_units
  end
end