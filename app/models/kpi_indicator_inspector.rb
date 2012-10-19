class KpiIndicatorInspector < ActiveRecord::Base
	validates :kpi_period_indicator_id, :uniqueness => {:scope => :user_id}
	validates :percent, :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 100 }, :allow_nil => true

	belongs_to :kpi_period_indicator
	belongs_to :user

	has_many :kpi_marks, :dependent => :destroy

	scope :active, :conditions => "#{KpiIndicatorInspector.table_name}.locked != 1 OR #{KpiIndicatorInspector.table_name}.locked IS NULL"	

	before_save :deny_save_if_period_active
	before_destroy :deny_save_if_period_active


	private

	def deny_save_if_period_active
		false if kpi_period_indicator.kpi_period_category.kpi_calc_period.active
	end
	
end