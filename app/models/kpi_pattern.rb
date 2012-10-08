class KpiPattern < ActiveRecord::Base
	validates_presence_of :name
	validates_uniqueness_of :name

	has_many :kpi_pattern_users
	has_many :users, :through => :kpi_pattern_users
	has_many :kpi_pattern_indicators, :dependent => :destroy
	has_many :indicators, :through => :kpi_pattern_indicators
	has_many :kpi_calc_periods

	def integrity?
		if kpi_pattern_indicators.sum("percent")==100
			true
		else
			false
		end

	end
end