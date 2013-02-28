#  coding: utf-8
class ChangeKpiCalcPeriods4 < ActiveRecord::Migration
  def change
    add_column :kpi_calc_periods, :user_id, :integer
  end
end
