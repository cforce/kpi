#  coding: utf-8
class ChangeKpiMarks2 < ActiveRecord::Migration
  def self.up
    change_table :kpi_marks do |t|
      t.boolean :disabled, :null => false, :default => 0
    end
  end

  def self.down
    change_table :kpi_marks do |t|
      t.remove :disabled
    end 
  end
end