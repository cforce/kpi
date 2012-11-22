class KpiMark < ActiveRecord::Base
    validates :kpi_indicator_inspector_id, :uniqueness => {:scope => [:user_id, :inspector_id, :start_date, :end_date]}

	belongs_to :kpi_indicator_inspector
	belongs_to :user
	belongs_to :inspector, :class_name => 'User', :foreign_key => 'inspector_id'
	has_one :kpi_period_indicator, :through => :kpi_indicator_inspector
	

	#before_save :check_inspector

	#scope :active, :conditions => "#{KpiMark.table_name}.locked != 1 OR #{KpiMark.table_name}.locked IS NULL"	
	#scope :urgent, :conditions => "#{KpiMark.table_name}.fact_value IS NULL"

	def mark_period
		"<nobr>#{format_date(start_date)} &mdash; #{format_date(end_date)}</nobr>".html_safe
	end

	def plan(period_indicator)
		Indicator::INTERPRETATION_FACT == period_indicator.interpretation ?	plan_value :
																			((period_indicator.matrix['percent'].index('100').nil?) ? 
																			1 : 
																			period_indicator.matrix['value_of_fact'][period_indicator.matrix['percent'].index('100')])
	end

	def completion(period_indicator)
		return nil if fact_value.nil?
		if period_indicator.interpretation == Indicator::INTERPRETATION_MATRIX
			#Rails.logger.debug("ddddddddd #{period_indicator.matrix['value_of_fact'].inspect} #{period_indicator.id}")
			if not fact_value.nil?
				f=fact_value.to_f
				matrix = {}
				period_indicator.matrix['value_of_fact'].each_index{|i| 
					matrix[period_indicator.matrix['value_of_fact'][i].to_f] = period_indicator.matrix['percent'][i].to_f
					}
		

				return matrix[f] if not matrix[f].nil?

				p2=nil; p1=nil; f2=nil; f1=nil;
				sort_matrix = matrix.sort

				sort_matrix.each_index{|i| 
								if sort_matrix[i][0]>f
									if i!=0
										f2 = sort_matrix[i][0]
										f1 = sort_matrix[i-1][0]
										p2 = sort_matrix[i][1]
										p1 = sort_matrix[i-1][1]										
									else
										f2 = sort_matrix[1][0]
										f1 = sort_matrix[0][0]	
										p2 = sort_matrix[1][1]
										p1 = sort_matrix[0][1]											
									end
									break									
								end
								f2 = sort_matrix[i][0]
								f1 = sort_matrix[i-1][0]
								p2 = sort_matrix[i][1]
								p1 = sort_matrix[i-1][1]									
							}

				(((f-f1)/(f2-f1))*(p2-p1)+p1) if not p2.nil?

				#sort_matrix.inspect
			end
		else
			fact_value.to_f/plan_value.to_f*100 
		end
	end

end