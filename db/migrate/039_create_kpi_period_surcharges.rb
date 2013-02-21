#  coding: utf-8
class CreateKpiPeriodSurcharges < ActiveRecord::Migration
  def self.up
    create_table :kpi_period_surcharges do |t|
      t.integer :kpi_calc_period_id
      t.integer :kpi_surcharge_id
      t.float :default_value      
      t.timestamps
    end

  end

  def self.down
    drop_table :kpi_period_surcharges
  end
end
