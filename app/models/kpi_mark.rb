class KpiMark < ActiveRecord::Base

	belongs_to :kpi_indicator_inspector

	scope :active, :conditions => "#{KpiMark.table_name}.locked != 1 OR #{KpiMark.table_name}.locked IS NULL"	

end