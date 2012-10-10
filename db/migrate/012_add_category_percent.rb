#  coding: utf-8
class AddCategoryPercent < ActiveRecord::Migration
  def self.up
    change_table :kpi_categories do |t|
      t.integer :percent, :default => false
    end
  end

  def self.down
    change_table :kpi_categories do |t|
      t.remove :percent
    end 
  end
end