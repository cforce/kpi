class CreateKpiMarkOffers < ActiveRecord::Migration
  def self.up
    create_table :kpi_mark_offers do |t|
      t.integer :user_id
      t.integer :author_id
      t.integer :kpi_mark_id
      t.integer :is_praise
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :kpi_mark_offers
  end
end