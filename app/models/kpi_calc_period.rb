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

	has_many :kpi_period_indicators, :dependent => :destroy
	has_many :planned_indicators, :through => :kpi_period_indicators, :source => :indicator

	has_many :kpi_period_categories, :dependent => :destroy
	has_many :kpi_categories, :through => :kpi_period_categories

	#after_create :add_inspector_marks

	def integrity?
		inspectors_integrity?
	end

	def inspectors_integrity?
		! kpi_indicator_inspectors.select('sum(percent)').group('indicator_id').having('sum(percent)!=100').to_a.any?
	end

	def copy_from_pattern
		copy_indicators_from_pattern
		copy_categories_from_pattern
	end

	def copy_indicators_from_pattern
		kpi_pattern.kpi_pattern_indicators.each do |e|
			KpiPeriodIndicator.create(:indicator_id => e.indicator_id, :kpi_calc_period_id => id, :percent => e.percent)
			end
	end

	def copy_categories_from_pattern
		kpi_pattern.kpi_pattern_categories.each do |e|
			KpiPeriodCategory.create(:kpi_category_id => e.kpi_category_id, :kpi_calc_period_id => id, :percent => e.percent)
			end
	end

end