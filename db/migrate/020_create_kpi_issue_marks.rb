#  coding: utf-8
class CreateKpiIssueMarks < ActiveRecord::Migration
  def self.up
    create_table :kpi_issue_marks do |t|
      t.integer :value
      t.string :title
      t.timestamps
    end

    KpiIssueMark.create(:value => "150", :title => "Отлично")
    KpiIssueMark.create(:value => "100", :title => "Хорошо")
    KpiIssueMark.create(:value => "50", :title => "Удовлетворительно")
    KpiIssueMark.create(:value => "0", :title => "Плохо")
    KpiIssueMark.create(:value => "-50", :title => "Опасно")    
  end

  def self.down
    drop_table :kpi_issue_marks
  end
end