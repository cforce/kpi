#  coding: utf-8
class ChangeKpiAplliedReports1 < ActiveRecord::Migration
  def change
    add_column :kpi_applied_reports, :audit, :boolean, :null => false, :default => 0
  end
end
