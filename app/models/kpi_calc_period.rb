class KpiCalcPeriod < ActiveRecord::Base
	validates_presence_of :date
	validates_presence_of :kpi_pattern_id
	validates :kpi_pattern_id, :uniqueness => { :scope => :date, :message => l(:uniq_date_and_pattern_message) }

	belongs_to :kpi_pattern

	has_many :kpi_period_users
	has_many :users, :through => :kpi_period_users

	has_many :kpi_indicator_inspectors
	has_many :inspectors, :through => :kpi_indicator_inspectors
	has_many :indicators, :through => :kpi_indicator_inspectors
	has_many :kpi_period_indicators

end