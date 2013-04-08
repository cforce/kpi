#  coding: utf-8
class CreateKpiImportedValues < ActiveRecord::Migration
  def self.up
    create_table :kpi_imported_values do |t|
      t.string :name
      t.string :pseudonym
      t.float :value
      t.timestamps
    end

    KpiImportedValue.create(:name => "Количество рабочих часов в текущем месяце", :pseudonym => "work_hours")
    KpiImportedValue.create(:name => "Общая прибыль компании(факт) за текущий месяц", :pseudonym => "common_profit_fact")
    KpiImportedValue.create(:name => "Общая прибыль компании(план) за текущий месяц", :pseudonym => "common_profit_plan")
    KpiImportedValue.create(:name => "Розничная прибыль компании(факт) за текущий месяц", :pseudonym => "retail_profit_fact")
    KpiImportedValue.create(:name => "Розничная прибыль компании(план) за текущий месяц", :pseudonym => "retail_profit_plan")
    KpiImportedValue.create(:name => "Оптовая прибыль компании(факт) за текущий месяц", :pseudonym => "wholesale_profit_fact")
    KpiImportedValue.create(:name => "Оптовая прибыль компании(план) за текущий месяц", :pseudonym => "wholesale_profit_plan")
    KpiImportedValue.create(:name => "Норма средней оценки заказчика", :pseudonym => "client_avg_mark", :value => 100)
    KpiImportedValue.create(:name => "Норма средней оценки исполнителя", :pseudonym => "executor_avg_mark", :value => 100)
  end

  def self.down
    drop_table :kpi_imported_values
  end
end