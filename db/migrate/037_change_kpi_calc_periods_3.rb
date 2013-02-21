#  coding: utf-8
class ChangeKpiCalcPeriods3 < ActiveRecord::Migration
  def change
    add_column :kpi_calc_periods, :base_salary_pattern, :integer, :null => false, :default => 1
    add_column :kpi_calc_periods, :exclude_time_ratio, :boolean, :null => false, :default => 0
    add_column :kpi_calc_periods, :kpi_hours_norm_id, :integer
  end
end
