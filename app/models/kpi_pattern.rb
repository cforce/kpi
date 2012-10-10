class KpiPattern < ActiveRecord::Base
	validates_presence_of :name
	validates_uniqueness_of :name

	has_many :kpi_pattern_users
	has_many :users, :through => :kpi_pattern_users
	has_many :kpi_pattern_indicators, :dependent => :destroy
	has_many :indicators, :through => :kpi_pattern_indicators
	has_many :kpi_calc_periods
	has_many :kpi_pattern_categories, :dependent => :destroy

	def integrity?
		categories_integrity? && indicators_integrity?
	end 

	def indicators_integrity?
		! KpiPatternIndicator.where(:kpi_pattern_id => id).joins(:indicator).select("sum(#{KpiPatternIndicator.table_name}.percent) AS weight").group("kpi_category_id").having("sum(#{KpiPatternIndicator.table_name}.percent)!=100").map{|e| e }.any?
	end

	def categories_integrity?
		if kpi_pattern_categories.sum("percent")==100
			true
		else
			false
		end		
	end
end