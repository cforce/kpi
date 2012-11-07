#  coding: utf-8
class CreateKpiIssueMarks < ActiveRecord::Migration
  def self.up
    create_table :kpi_issue_marks do |t|
      t.integer :value
      t.string :title
      t.timestamps
    end

    KpiIssueMark.create(:value => "5", :title => "Отлично")
    KpiIssueMark.create(:value => "4", :title => "Хорошо")
    KpiIssueMark.create(:value => "3", :title => "Удовлетворительно")
  end

  def self.down
    drop_table :kpi_issue_marks
  end
end