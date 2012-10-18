
class KpiController < ApplicationController
	def index

	end

	def marks
		@marks = User.current.kpi_marks.active.where('kpi_marks.date <= ?', Date.today)
	end
end