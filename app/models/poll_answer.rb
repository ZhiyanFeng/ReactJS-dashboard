# == Schema Information
#
# Table name: poll_answers
#
#  id          :integer          not null, primary key
#  question_id :integer
#  content     :text             not null
#  correct     :boolean          not null
#  is_active   :boolean          default(TRUE)
#  is_valid    :boolean          default(TRUE)
#  created_at  :timestamp
#  updated_at  :timestamp
#

class PollAnswer < ActiveRecord::Base
	belongs_to :poll_question, :foreign_key => "question_id"

	default_scope { order('id ASC') }

	attr_accessible :question_id, :content, :correct, :is_active, :is_valid

	validates_presence_of :content, :on => :create
end
