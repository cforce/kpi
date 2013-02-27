#  coding: utf-8

class CreateKpiAplliedReports < ActiveRecord::Migration
  def self.up
    create_table :kpi_applied_reports do |t|
      t.date :date
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :kpi_applied_reports
  end
end