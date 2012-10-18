#  coding: utf-8
class AddActiveField < ActiveRecord::Migration
  def self.up
    change_table :kpi_calc_periods do |t|
      t.boolean :active, :null => false, :default => 0
    end
  end

  def self.down
    change_table :kpi_calc_periods do |t|
      t.remove :active
    end 
  end
end