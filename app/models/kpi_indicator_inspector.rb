class KpiIndicatorInspector < ActiveRecord::Base
	validates :kpi_calc_period_id, :uniqueness => { :scope => [:indicator_id, :user_id] }

	belongs_to :kpi_calc_period
	belongs_to :indicator
	belongs_to :user
end