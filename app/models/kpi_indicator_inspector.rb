class KpiIndicatorInspector < ActiveRecord::Base
	validates :kpi_period_indicator_id, :uniqueness => {:scope => :user_id}
	validates :percent, :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 100 }, :allow_nil => true

	belongs_to :kpi_period_indicator
	belongs_to :user

	has_many :kpi_marks, :dependent => :destroy

	#after_create :add_inspector_marks

	scope :active, :conditions => "#{KpiIndicatorInspector.table_name}.locked != 1 OR #{KpiIndicatorInspector.table_name}.locked IS NULL"	

	
	def add_inspector_marks
		num_on_period = kpi_period_indicator.num_on_period
		period_start_date = kpi_period_indicator.kpi_period_category.kpi_calc_period.date

		last_day_in_month = period_start_date.end_of_month.day
		interval = last_day_in_month.to_i/num_on_period
		remainder = last_day_in_month.to_i % num_on_period

		last_day=0
		(1..num_on_period).each{|e|
			last_day = last_day+interval
			if remainder > 0
				last_day += 1
				remainder -= 1
			end

			date=period_start_date+(last_day-1).days

			KpiMark.create(:date => date, :kpi_indicator_inspector_id => id)
			}
	end	
end