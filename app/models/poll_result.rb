class PollResult < ActiveRecord::Base
	belongs_to :poll, :foreign_key => "poll_id"

	attr_accessible :org_id, :poll_id, :user_id, :question_count, :score, :answer_key, :passed, :is_valid, :answer_json

	validates_presence_of :poll_id, :on => :create	
	validates_presence_of :user_id, :on => :create
	validates_presence_of :question_count, :on => :create
	validates_presence_of :score, :on => :create
	#validates_presence_of :passed, :on => :create
	#validates_presence_of :answer_key, :on => :create

	before_save :check_passed, :set_org

	def check_passed
		if !self[:passed].present?
			poll = Poll.find(self[:poll_id])
			if poll[:pass_mark].to_i <= self[:score]
				self[:passed] = true
			else
				self[:passed] = false
				nil
			end
		end
	end

	def set_org
		user_org_id = User.where(:id => self[:user_id]).pluck(:active_org).first
		self[:org_id] = user_org_id
	end
	
end
