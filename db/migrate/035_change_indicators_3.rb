#  coding: utf-8
class ChangeIndicators3 < ActiveRecord::Migration
  def change
    add_column :indicators, :max_effectiveness, :integer, :null => true
    add_column :indicators, :min_effectiveness, :integer, :null => true
  end
end