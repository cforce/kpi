#  coding: utf-8
class CreateKpiPatterns < ActiveRecord::Migration
  def self.up
    create_table :kpi_patterns do |t|
      t.string :name
      t.text :description
      t.boolean :integrity, :default => false, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :kpi_patterns
  end
end