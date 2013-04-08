#  coding: utf-8

class ChangeKpiAplliedReports < ActiveRecord::Migration
  def change
    add_column :kpi_applied_reports, :user_department_id, :integer
  end
end