#  coding: utf-8
class CreateKpiImportedUserHours < ActiveRecord::Migration
  def self.up
    create_table :kpi_imported_user_hours do |t|
      t.string :login
      t.string :guid
      t.date :date
      t.float :hours
      t.timestamps
    end
  end

  def self.down
    drop_table :kpi_imported_user_hours
  end
end