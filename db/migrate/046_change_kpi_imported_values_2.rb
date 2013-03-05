#  coding: utf-8
class ChangeKpiImportedValues2 < ActiveRecord::Migration
  def change
    add_column :kpi_imported_values, :user_department_id, :integer
    add_column :kpi_imported_values, :user_title_id, :integer
  end
end