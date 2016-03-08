# == Schema Information
#
# Table name: user_notification_counters
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  org_id        :integer
#  last_fetched  :timestamp
#  newsfeeds     :integer          default(0)
#  announcements :integer          default(0)
#  created_at    :timestamp
#  updated_at    :timestamp
#  events        :integer          default(0)
#  trainings     :integer          default(0)
#

class UserNotificationCounter < ActiveRecord::Base
	attr_accessible :newsfeeds, :announcements, :contacts, :trainings, :quizzes, :safety_trainings, :safety_quiz, :user_id, :org_id

	validates_presence_of :user_id, :on => :create
  validates_presence_of :org_id, :on => :create
	validates_uniqueness_of :user_id, :scope => [:org_id]
	
	def self.reset(user_id, org_id, counter)
	  #@user = User.find(user_id)
	  @counter = UserNotificationCounter.find_by_user_id_and_org_id(user_id, org_id)
	  #@user.update_attribute(:push_count, @user[:push_count] - @counter[:announcements]) if counter == "announcements"
	  @counter.update_attribute(:newsfeeds, 0) if counter == "newsfeeds"
	  @counter.update_attribute(:announcements, 0) if counter == "announcements"
    @counter.update_attribute(:contacts, 0) if counter == "contacts"
    @counter.update_attribute(:trainings, 0) if counter == "trainings"
    @counter.update_attribute(:quizzes, 0) if counter == "quizzes"
    @counter.update_attribute(:safety_trainings, 0) if counter == "safety_trainings"
    @counter.update_attribute(:safety_quiz, 0) if counter == "safety_quiz"
	  @counter.update_attribute(:events, 0) if counter == "events"
  end
  
  def self.fetch(user_id, org_id)
    @counter = UserNotificationCounter.find_by_user_id_and_org_id(user_id, org_id)
    @counter.update_attribute(:last_fetched, Time.now)
    return @counter
  end
  
  def self.destroy(user_id, org_id)
    @counter = UserNotificationCounter.find_by_user_id_and_org_id(user_id, org_id)
    @counter.delete
  end
  
  def self.increment(org_id, column, owner_id)
    @counters = UserNotificationCounter.where(:org_id => org_id).where.not(:user_id => owner_id)
    @counters.each do |c|
      if column == "post"
        c.update_attribute(:newsfeeds, c[:newsfeeds] + 1)
      elsif column == "announcement"
        c.update_attribute(:announcements, c[:announcements] + 1)
      elsif column == "contact"
        c.update_attribute(:contacts, c[:contacts] + 1)
      elsif column == "event"
        c.update_attribute(:events, c[:events] + 1)
      elsif column == "training"
        c.update_attribute(:trainings, c[:trainings] + 1)
      elsif column == "quizzes"
        c.update_attribute(:quizzes, c[:quizzes] + 1)
      else
        
      end
    end
  end
end
