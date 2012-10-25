#  coding: utf-8
class CreateKpiPatternUsers < ActiveRecord::Migration
  def self.up
    create_table :kpi_pattern_users do |t|
      t.integer :kpi_pattern_id
      t.integer :user_id
      t.integer :user_department_id
      t.integer :user_title_id
      t.timestamps
    end
  end

  def self.down
    drop_table :kpi_pattern_users
  end
end