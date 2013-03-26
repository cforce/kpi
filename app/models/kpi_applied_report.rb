class KpiAppliedReport < ActiveRecord::Base

  has_and_belongs_to_many :kpi_calc_periods
  belongs_to :user

  def self.applied?(date)
    KpiAppliedReport.where(:date => date).any?
  end

  def self.user_can_apply?
    User.current.global_permission_to?('kpi_applied_reports', 'apply')
  end
end