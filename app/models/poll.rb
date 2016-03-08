# == Schema Information
#
# Table name: polls
#
#  id             :integer          not null, primary key
#  org_id         :integer          not null
#  owner_id       :integer          not null
#  complete_count :integer          default(0)
#  start_at       :timestamp
#  end_at         :timestamp
#  is_active      :boolean          default(TRUE)
#  is_valid       :boolean          default(TRUE)
#  created_at     :timestamp
#  updated_at     :timestamp
#  question_count :integer          default(0)
#

class Poll < ActiveRecord::Base
	has_many :poll_questions, -> { where ['poll_questions.is_valid'] },  :class_name => "PollQuestion", :foreign_key => "poll_id"

	attr_accessible :org_id, :owner_id, :complete_count, :question_count, :attempts_count, :pass_mark, :count_down, :start_at, :end_at, :is_active, :is_valid, :poll_name
	 
	validates_presence_of :org_id, :on => :create
	validates_presence_of :owner_id, :on => :create
	validates_presence_of :question_count, :on => :create
	validates_presence_of :count_down, :on => :create
	validates_presence_of :pass_mark, :on => :create

	attr_accessor :user_id

	def set_user(id)
    self.user_id = id
  end

	def set_org(id)
    self.org_id = id
  end

	def update_poll(poll)
		transaction do
			self.update(
			:pass_mark => poll[:poll][:pass_mark], 
			:count_down => poll[:poll][:count_down], 
			:start_at => poll[:poll][:start_at],
			:end_at => poll[:poll][:end_at]
			)
			poll[:questions].each do |q|
				@question = PollQuestion.find(q[:id])
				@question.update(:question_title => q[:question_title], :randomize => q[:randomize], :attachment_id => q[:attachment_id])
				q[:answers].each do |a|
					@answer = PollAnswer.find(a[:id])
					@answer.update(:content => a[:content])
				end
			end
		end
	end
end