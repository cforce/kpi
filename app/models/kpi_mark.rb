class KpiMark < ActiveRecord::Base
    validates :kpi_indicator_inspector_id, :uniqueness => {:scope => [:user_id, :inspector_id, :start_date, :end_date]}

	belongs_to :kpi_indicator_inspector
	belongs_to :user

	#scope :active, :conditions => "#{KpiMark.table_name}.locked != 1 OR #{KpiMark.table_name}.locked IS NULL"	
	#scope :urgent, :conditions => "#{KpiMark.table_name}.fact_value IS NULL"

end