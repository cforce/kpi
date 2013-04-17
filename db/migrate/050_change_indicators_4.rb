#  coding: utf-8
class ChangeIndicators4 < ActiveRecord::Migration
  def change
    add_column :indicators, :objective, :boolean, :null => false, :default => 0
  end
end