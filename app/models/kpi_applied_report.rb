class KpiAppliedReport < ActiveRecord::Base

  has_and_belongs_to_many :kpi_calc_periods
  belongs_to :user

  def self.user_who_approved(date, department)
    User.joins(:kpi_applied_reports).where("#{KpiAppliedReport.table_name}.date = ? AND #{KpiAppliedReport.table_name}.user_department_id = ? ", date, department.id).try(:first)
  end

  def self.user_can_apply?
    User.current.global_permission_to?('kpi_applied_reports', 'apply')
  end
  def self.user_can_cancel?
    User.current.global_permission_to?('kpi_applied_reports', 'cancel')
  end
end