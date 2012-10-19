class KpiMark < ActiveRecord::Base
    validates :kpi_indicator_inspector_id, :uniqueness => {:scope => [:user_id, :inspector_id, :date]}

	belongs_to :kpi_indicator_inspector

	scope :active, :conditions => "#{KpiMark.table_name}.locked != 1 OR #{KpiMark.table_name}.locked IS NULL"	

end