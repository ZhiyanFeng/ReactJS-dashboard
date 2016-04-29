class Gratitude < ActiveRecord::Base
  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"
  has_many :users, :through => :likes
  has_many :users, :through => :flags

  default_scope { order('created_at ASC') }

  attr_accessor :user_id

  attr_accessible :owner_id, :amount, :source, :source_id, :is_valid

  validates_presence_of :amount, :on => :create
  validates_presence_of :owner_id, :on => :create
  validates_presence_of :source, :on => :create
  validates_presence_of :source_id, :on => :create

  def check_user(id)
    self.user_id = id
  end

  def indicate(user_id)
    user = User.find(user_id)
    self.liked = Like.exists?(:owner_id => user_id, :source => 5, :source_id => self.id) ? true : false
    self.flagged = Flag.exists?(:owner_id => user_id, :source => 5, :source_id => self.id) ? true : false
  end

  def create_gratitude(target, push)
    transaction do
      if save
        @user = User.find(self[:owner_id])
        @user.update_attributes(:shyft_score => @user[:shyft_score] + 5)
        if push
          @channel = Channel.find(target[:channel_id])
          @channel.tracked_subscriber_tip_push("gratitude", target, self.amount)
        end
      end
    end
  end

  def destroy_comment
    self.update_attribute(:is_valid, false)
  end

end
