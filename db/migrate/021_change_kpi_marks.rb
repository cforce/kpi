#  coding: utf-8
class ChangeKpiMarks < ActiveRecord::Migration
  def self.up
    change_table :kpi_marks do |t|
      t.text :explanation
    end
  end

  def self.down
    change_table :kpi_marks do |t|
      t.remove :explanation
    end 
  end
end