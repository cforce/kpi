class KpiPattern < ActiveRecord::Base
	validates_presence_of :name
	validates_uniqueness_of :name

	has_many :kpi_pattern_users
	has_many :users, :through => :kpi_pattern_users
end