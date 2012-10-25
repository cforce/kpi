#  coding: utf-8
class CreateKpiMarks < ActiveRecord::Migration
  def self.up
    create_table :kpi_marks do |t|
      t.integer :kpi_indicator_inspector_id
      t.integer :user_id
      t.integer :inspector_id
      t.date :start_date
      t.date :end_date
      t.float :fact_value
      t.boolean :locked, :default => false, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :kpi_marks
  end
end