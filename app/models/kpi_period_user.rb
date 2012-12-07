class KpiPeriodUser < ActiveRecord::Base
	belongs_to :kpi_calc_period
	belongs_to :user
	has_many :kpi_period_indicators, :through => :kpi_calc_period
	has_many :kpi_indicator_inspectors, :through => :kpi_period_indicators
	has_many :kpi_marks, :through => :kpi_indicator_inspectors, :conditions => lambda {|*args| "#{KpiMark.table_name}.user_id=#{user_id}"}

	after_destroy :delete_marks
	before_save :check_period
	before_destroy :check_period
	

	private
	def delete_marks
		kpi_marks.each do |mark|
			mark.destroy
			end 
	end

    def check_period
        false if kpi_calc_period.locked and locked==KpiPeriodUser.find(id).locked
    end

end