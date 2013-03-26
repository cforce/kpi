#  coding: utf-8
class ChangeKpiPeriodIndicators2 < ActiveRecord::Migration
  def change
    add_column :kpi_period_indicators, :max_effectiveness, :integer, :null => true
    add_column :kpi_period_indicators, :min_effectiveness, :integer, :null => true
  end
end