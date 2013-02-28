class KpiPeriodCategory < ActiveRecord::Base
	belongs_to :kpi_calc_period
	belongs_to :kpi_category
	has_many :kpi_period_indicators, :dependent => :destroy


	before_save :check_period
  before_destroy :check_period_before_destroy


	private

    def check_period
        false if kpi_calc_period.locked or kpi_calc_period.active
    end 

  def check_period_before_destroy
    false if kpi_calc_period.locked
  end
end