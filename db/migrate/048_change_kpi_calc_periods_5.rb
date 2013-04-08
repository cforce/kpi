#  coding: utf-8
class ChangeKpiCalcPeriods5 < ActiveRecord::Migration
  def change
    add_column :kpi_calc_periods, :allowed_change_salary, :boolean, :null => false, :default => 0
  end
end
