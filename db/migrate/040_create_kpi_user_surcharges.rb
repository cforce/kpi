#  coding: utf-8
class CreateKpiUserSurcharges < ActiveRecord::Migration
  def self.up
    create_table :kpi_user_surcharges do |t|
      t.integer :kpi_surcharge_id
      t.integer :kpi_period_user_id
      t.float :value
      t.text :explanation
      t.boolean :is_deduction, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :kpi_user_surcharges
  end
end