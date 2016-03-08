# == Schema Information
#
# Table name: poll_questions
#
#  id             :integer          not null, primary key
#  poll_id        :integer
#  attachment     :integer
#  content        :text             not null
#  question_type  :string(255)      default("0")
#  complete_count :integer          default(0)
#  is_active      :boolean          default(TRUE)
#  is_valid       :boolean          default(TRUE)
#  created_at     :timestamp
#  updated_at     :timestamp
#

class PollQuestion < ActiveRecord::Base
	belongs_to :poll, :foreign_key => "poll_id"
	has_many :poll_answers, :class_name => "PollAnswer", :foreign_key => "question_id"

	default_scope { order('created_at ASC') }

	#default_scope :order => 'created_at asc'

	attr_accessible :randomize, :poll_id, :content, :attachment_id, :complete_count, :question_type, :is_active, :is_valid

	validates_presence_of :poll_id, :on => :create	
	validates_presence_of :content, :on => :create
	validates_presence_of :question_type, :on => :create
	
end
