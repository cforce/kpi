class KpiMarkOffer < ActiveRecord::Base
  validates_presence_of :user_id, :author_id, :kpi_mark_id, :is_praise

  belongs_to :user
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'

  belongs_to :kpi_mark
end