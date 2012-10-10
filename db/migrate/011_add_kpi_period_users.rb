#  coding: utf-8
class AddKpiPeriodUsers < ActiveRecord::Migration
  def self.up
    create_table :kpi_period_users do |t|
      t.integer :kpi_calc_period_id
      t.integer :user_id
      t.boolean :locked
      t.timestamps
    end
  end

  def self.down
    drop_table :kpi_period_users
  end
end