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

	def copy_to(pattern)
		copy_users_to(pattern)
		copy_categories_to(pattern)
		copy_indicators_to(pattern)
	end

	def copy_users_to(pattern)
		kpi_pattern_users.each do |u|
			KpiPatternUser.create(:kpi_pattern_id => pattern.id, :user_id => u.user_id)
		end		
	end

	def copy_indicators_to(pattern)
		kpi_pattern_indicators.each do |i|
			KpiPatternIndicator.create(:kpi_pattern_id => pattern.id, :indicator_id => i.indicator_id, :percent => i.percent)
		end		
	end

	def copy_categories_to(pattern)
		kpi_pattern_categories.each do |c|
			KpiPatternCategory.create(:kpi_pattern_id => pattern.id, :kpi_category_id => c.kpi_category_id, :percent => c.percent)
		end		
	end

	def categories_integrity?
		if kpi_pattern_categories.sum("percent")==100
			true
		else
			false
		end		
	end
end