class CreateIndicators < ActiveRecord::Migration
  def self.up
    create_table :indicators do |t|
      t.string :name
      t.integer :kpi_unit_id
      t.text :description
      t.integer :kpi_category_id
      t.integer :interpretation
      t.text :matrix
      t.timestamps
    end
  end

  def self.down
    drop_table :indicators
  end
end