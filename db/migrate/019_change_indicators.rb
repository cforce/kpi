#  coding: utf-8
class ChangeIndicators < ActiveRecord::Migration
  def self.up
    change_table :indicators do |t|
      t.integer :input_type, :null => false, :default => 0
      t.integer :behaviour_type, :null => false, :default => 0
      t.integer :pattern
      t.text :pattern_settings
    end
  end

  def self.down
    change_table :indicators do |t|
      t.remove :input_type
      t.remove :behaviour_type
      t.remove :pattern
      t.remove :pattern_settings
    end 
  end
end