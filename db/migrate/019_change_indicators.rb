#  coding: utf-8
class ChangeIndicators < ActiveRecord::Migration
  def self.up
    change_table :indicators do |t|
      t.integer :input_type, :null => false, :default => 0
      t.integer :behaviour_type, :null => false, :default => 0
    end
  end

  def self.down
    change_table :indicators do |t|
      t.remove :input_type
      t.remove :behaviour_type
    end 
  end
end