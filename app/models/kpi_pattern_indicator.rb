class KpiPatternIndicator < ActiveRecord::Base

	validates :percent, :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 100 }, :allow_nil => true

	belongs_to :kpi_pattern
	belongs_to :indicator

	after_create :add_category_in_pattern
	before_destroy :remove_category_from_pattern

	private

	def add_category_in_pattern
		#Rails.logger.debug("sssssssss #{kpi_pattern_id}--#{indicator.kpi_category.id}--#{indicator.kpi_category.percent}")
	    KpiPatternCategory.create(:kpi_pattern_id => kpi_pattern_id, :kpi_category_id => indicator.kpi_category.id, :percent => indicator.kpi_category.percent)
	end 

	def remove_category_from_pattern
	    cat_id=indicator.kpi_category_id	    
	    count=Indicator.where(:kpi_category_id => cat_id).joins("INNER JOIN #{KpiPatternIndicator.table_name} 
	    														   ON indicators.id = #{KpiPatternIndicator.table_name}.indicator_id 
	    														   AND #{KpiPatternIndicator.table_name}.kpi_pattern_id=#{kpi_pattern_id}").count

	  	if count == 1
	  		KpiPatternCategory.where(:kpi_category_id => cat_id, :kpi_pattern_id => kpi_pattern_id).first.destroy
	  	end
	end 


end