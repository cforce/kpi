class KpiIssueMark < ActiveRecord::Base
	validates :value, :uniqueness => true
end