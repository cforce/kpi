#  coding: utf-8
class AddIntegrity < ActiveRecord::Migration
  def self.up
    change_table :kpi_calc_periods do |t|
      t.boolean :integrity, :default => false, :null => false
    end
  end

  def self.down
    change_table :kpi_calc_periods do |t|
      t.remove :integrity
    end 
  end
end