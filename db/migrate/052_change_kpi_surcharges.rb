#  coding: utf-8
class ChangeKpiSurcharges < ActiveRecord::Migration
  def change
      rename_column :kpi_surcharges, :changable, :changable_by_user
  end
end