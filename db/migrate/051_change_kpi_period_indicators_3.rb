#  coding: utf-8
class ChangeKpiPeriodIndicators3 < ActiveRecord::Migration
  def change
      add_column :kpi_period_indicators, :objective, :boolean, :null => false, :default => 0
  end
end