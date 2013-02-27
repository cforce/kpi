#  coding: utf-8
class CreateKpiAplliedReportsKpiCalcPeriods < ActiveRecord::Migration
  def self.up
    create_table :kpi_applied_reports_kpi_calc_periods do |t|
      t.integer :kpi_applied_report_id
      t.integer :kpi_calc_period_id
      t.timestamps
    end
  end

  def self.down
    drop_table :kpi_applied_reports_kpi_calc_periods
  end
end
