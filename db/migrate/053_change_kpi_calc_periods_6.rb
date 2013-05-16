#  coding: utf-8
class ChangeKpiCalcPeriods6 < ActiveRecord::Migration
  def change
    add_column :kpi_calc_periods, :who_can_disable_mark, :integer, :null => false, :default => 0
  end
end
