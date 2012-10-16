#  coding: utf-8
class AddNumPerPeriod < ActiveRecord::Migration
  def self.up
    change_table :indicators do |t|
      t.integer :num_on_period, :default => 1
    end
  end

  def self.down
    change_table :indicators do |t|
      t.remove :num_on_period
    end 
  end
end