#  coding: utf-8
class CreateKpiPatternIndicators < ActiveRecord::Migration
  def self.up
    create_table :kpi_pattern_indicators do |t|
      t.integer :indicator_id
      t.integer :kpi_pattern_id
      t.integer :percent
      t.timestamps
    end
  end

  def self.down
    drop_table :kpi_pattern_indicators
  end
end