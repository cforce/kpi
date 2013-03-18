class KpiMark < ActiveRecord::Base
    validates :kpi_indicator_inspector_id, :uniqueness => {:scope => [:user_id, :inspector_id, :start_date, :end_date]}

	belongs_to :kpi_indicator_inspector
	belongs_to :user
	belongs_to :inspector, :class_name => 'User', :foreign_key => 'inspector_id'
	has_one :kpi_period_indicator, :through => :kpi_indicator_inspector
	

	before_save :check_mark
	before_destroy :check_mark

	serialize :issues

	scope :not_set, :conditions => "#{KpiMark.table_name}.fact_value IS NULL"	

	#scope :active, :conditions => "#{KpiMark.table_name}.locked != 1 OR #{KpiMark.table_name}.locked IS NULL"	
	#scope :urgent, :conditions => "#{KpiMark.table_name}.fact_value IS NULL"

	def mark_period
		"<nobr>#{format_date(start_date)} &mdash; #{format_date(end_date)}</nobr>".html_safe
	end

	def plan(period_indicator)
		Indicator::INTERPRETATION_FACT == period_indicator.interpretation ?	plan_value :
																			((period_indicator.matrix['percent'].index('100').nil?) ? 
																			1 : 
																			period_indicator.matrix['value_of_fact'][period_indicator.matrix['percent'].index('100')].to_f)
	end

	def check_user_for_plan_update(period_indicator = nil, period_user = nil)
		period_indicator = kpi_period_indicator if period_indicator.nil?
		period_user = period_indicator.kpi_calc_period.kpi_period_users.where(:user_id => user_id).first if period_user.nil?

		(User.current.id == inspector_id or User.current.global_permission_to?('kpi_marks', 'edit_plan') or User.current.admin? or period_user.kpi_calc_period.manager.try(:id) == User.current.id) and (period_indicator.interpretation == Indicator::INTERPRETATION_FACT) and not period_user.locked
	end

	def check_user_for_info_showing?
		User.current.id == inspector_id or User.current.global_permission_to?('kpi', 'effectiveness') or User.current.admin? or User.current.id == user_id or kpi_period_indicator.kpi_calc_period.manager.id == User.current.try(:id)
	end

	def check_user_for_fact_update(period_indicator = nil, period_user = nil)
		period_indicator = kpi_period_indicator if period_indicator.nil?
		period_user = period_indicator.kpi_calc_period.kpi_period_users.where(:user_id => user_id).first if period_user.nil?

		(((User.current.id == inspector_id) and period_indicator.pattern.nil?) or (User.current.global_permission_to?('kpi_marks', 'edit_fact') or User.current.admin?) ) and not period_user.locked
	end

	def get_matrix_calc_values(period_indicator)
		f=fact_value.to_f
		matrix = {}
		period_indicator.matrix['value_of_fact'].each_index{|i| 
			matrix[period_indicator.matrix['value_of_fact'][i].to_f] = period_indicator.matrix['percent'][i].to_f
			}
		
		return {:equivalence_type => 'equival', :y => matrix[f], :x => f, :calc_values => [[f, matrix[f]]]} if not matrix[f].nil?

		p2=p1=f2=f1=equivalence_type=nil; 
		sort_matrix = matrix.sort

		sort_matrix.each_index{|i| 
						if sort_matrix[i][0]>f
							if i!=0
								equivalence_type = 'in_of_range'
								f2 = sort_matrix[i][0]
								f1 = sort_matrix[i-1][0]
								p2 = sort_matrix[i][1]
								p1 = sort_matrix[i-1][1]										
							else
								equivalence_type = 'out_of_range'
								f2 = sort_matrix[1][0]
								f1 = sort_matrix[0][0]	
								p2 = sort_matrix[1][1]
								p1 = sort_matrix[0][1]											
							end
							break									
						end
						equivalence_type = 'out_of_range'
						f2 = sort_matrix[i][0]
						f1 = sort_matrix[i-1][0]
						p2 = sort_matrix[i][1]
						p1 = sort_matrix[i-1][1]									
					}

		return {:equivalence_type => equivalence_type, :y => (((f-f1)/(f2-f1))*(p2-p1)+p1), :x => f, :calc_values => [[f1, p1], [f2, p2]]}  if not p2.nil?
		
	end

	def completion(period_indicator = false)
		period_indicator = kpi_period_indicator unless period_indicator

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

	private
	def check_mark
		false if locked and locked==KpiMark.find(id).locked
	end

end