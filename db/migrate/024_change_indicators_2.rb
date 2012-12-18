#  coding: utf-8
class ChangeIndicators2 < ActiveRecord::Migration
  def self.up
    change_table :indicators do |t|
      t.integer :pattern_plan
      t.text :pattern_plan_settings
    end
  end

  def self.down
    change_table :indicators do |t|
      t.remove :pattern_plan
      t.remove :pattern_plan_settings
    end 
  end
end