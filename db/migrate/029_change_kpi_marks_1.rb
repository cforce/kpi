#  coding: utf-8
class ChangeKpiMarks1 < ActiveRecord::Migration
  def self.up
    change_table :kpi_marks do |t|
      t.datetime :fact_date
      t.text :issues
    end
  end

  def self.down
    change_table :kpi_marks do |t|
      t.remove :fact_date
      t.remove :issues
    end 
  end
end