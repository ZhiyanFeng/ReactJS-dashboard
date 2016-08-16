class ScheduleElement < ActiveRecord::Base
  #default_scope :order => 'start_at DESC'
  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"
  belongs_to :coverer, :class_name => "User", :foreign_key => "coverer_id"
  belongs_to :location, :class_name => "Location", :foreign_key => "location_id"

  default_scope { order('start_at DESC') }

  has_event_calendar

  # To specify the columns to use call it like this:
  #
  # has_event_calendar :start_at_field  => 'custom_start_at', :end_at_field => 'custom_end_at'
  #

  # trade_status
  # 0 - posted
  # 1 - covered
  # 2 - pending
  # 3 - approved
  # 4 - rejected

  attr_accessible :name, :schedule_id, :owner_id, :coverer_id, :approver_id, :trade_status, :start_at, :end_at, :location_id, :channel_id, :is_valid

  def approve(approver_id, require_approval=nil)
    if !require_approval
      return "inapplicable"
    elsif self.is_valid == false
      return "deleted"
    elsif self.trade_status == 0
      return "uncovered"
    elsif self.trade_status == 2
      self.trade_status = 3
      self.approver_id = approver_id
      self.save
      @user = User.find(approver_id)
      @user.update_attributes(:shyft_score => @user[:shyft_score] + 1)
      notify_approved(self)
      return "success"
    else
      return "covered"
    end
  end

  def reject(approver_id, require_approval=nil)
    if !require_approval
      return "inapplicable"
    elsif self.is_valid == false
      return "deleted"
    elsif self.trade_status == 0
      return "uncovered"
    elsif self.trade_status == 2
      self.trade_status = 4
      self.approver_id = approver_id
      self.save
      @user = User.find(approver_id)
      @user.update_attributes(:shyft_score => @user[:shyft_score] + 1)
      notify_rejected(self)
      return "success"
    else
      return "covered"
    end
  end

  def cover(coverer_id, require_approval=nil)
    if self.is_valid == false
      return "deleted"
    elsif self.trade_status == 0
      if require_approval
        self.trade_status = 2
        self.coverer_id = coverer_id
        self.save
        @user = User.find(coverer_id)
        @user.update_attributes(:cover_count => @user[:cover_count] + 1, :shyft_score => @user[:shyft_score] + 5)
        notify_pending(self)
        return "pending"
      else
      	self.trade_status = 1
      	self.coverer_id = coverer_id
      	self.save
        @user = User.find(coverer_id)
        @user.update_attributes(:cover_count => @user[:cover_count] + 1, :shyft_score => @user[:shyft_score] + 5)
        notify_covered(self)
        return "success"
      end
    elsif self.trade_status == 2
      return "approved"
    else
      return "covered"
    end
  end

  def notify_covered(shift)
    @post = shift.parent.parent
    @followers = Follower.where(:source => 4, :source_id => @post[:id], :is_valid => true).where.not(:user_id => shift[:coverer_id])
    @followers.each do |u|
      if u[:id] == shift[:poster_id]
        content = Follower.create_shift_covered_message_for_poster(shift)
      elsif u[:id] == shift[:coverer_id]
        content = Follower.create_shift_covered_message_for_coverer(shift)
      else
        content = Follower.create_shift_covered_message_for_others(shift)
      end
      @notification = Notification.new(
        :source => 4,
        :source_id => @post[:id],
        :notify_id => u[:user_id],
        :sender_id => shift[:coverer_id],
        :recipient_id => shift[:owner_id],
        :org_id => 1,
        :event => "shift_covered",
        :message => content
        #:message => "post",
        #:content => content
      )
      @notification.save
    end
    Follower.follow(4, @post[:id], shift[:coverer_id])
  end

  def notify_pending(shift)
    @post = shift.parent.parent
    @followers = Follower.where(:source => 4, :source_id => @post[:id], :is_valid => true).where.not(:user_id => shift[:coverer_id])
    @followers.each do |u|
      if u[:id] == shift[:poster_id]
        content = Follower.create_shift_pending_message_for_poster(shift)
      elsif u[:id] == shift[:coverer_id]
        content = Follower.create_shift_pending_message_for_coverer(shift)
      else
        content = Follower.create_shift_pending_message_for_others(shift)
      end
      @notification = Notification.new(
        :source => 4,
        :source_id => @post[:id],
        :notify_id => u[:user_id],
        :sender_id => shift[:coverer_id],
        :recipient_id => shift[:owner_id],
        :org_id => 1,
        :event => "shift_pending",
        :message => content
        #:message => "post",
        #:content => content
      )
      @notification.save
    end
    Follower.follow(4, @post[:id], shift[:coverer_id])
  end

  def notify_approved(shift)
    @post = shift.parent.parent
    @followers = Follower.where(:source => 4, :source_id => @post[:id], :is_valid => true).where.not(:user_id => shift[:coverer_id])
    @followers.each do |u|
      if u[:id] == shift[:poster_id]
        content = Follower.create_shift_approved_message_for_poster(shift)
      elsif u[:id] == shift[:coverer_id]
        content = Follower.create_shift_approved_message_for_coverer(shift)
      else
        content = Follower.create_shift_approved_message_for_others(shift)
      end
      @notification = Notification.new(
        :source => 4,
        :source_id => @post[:id],
        :notify_id => u[:user_id],
        :sender_id => shift[:coverer_id],
        :recipient_id => shift[:owner_id],
        :org_id => 1,
        :event => "shift_approved",
        :message => content
        #:message => "post",
        #:content => content
      )
      @notification.save
    end
    Follower.follow(4, @post[:id], shift[:coverer_id])
  end

  def notify_rejected(shift)
    @post = shift.parent.parent
    @followers = Follower.where(:source => 4, :source_id => @post[:id], :is_valid => true).where.not(:user_id => shift[:coverer_id])
    @followers.each do |u|
      if u[:id] == shift[:poster_id]
        content = Follower.create_shift_rejected_message_for_poster(shift)
      elsif u[:id] == shift[:coverer_id]
        content = Follower.create_shift_rejected_message_for_coverer(shift)
      else
        content = Follower.create_shift_rejected_message_for_others(shift)
      end
      @notification = Notification.new(
        :source => 4,
        :source_id => @post[:id],
        :notify_id => u[:user_id],
        :sender_id => shift[:coverer_id],
        :recipient_id => shift[:owner_id],
        :org_id => 1,
        :event => "shift_rejected",
        :message => content
        #:message => "post",
        #:content => content
      )
      @notification.save
    end
    Follower.follow(4, @post[:id], shift[:coverer_id])
  end

  def uncover
    if self.is_valid
    	self.trade_status = 0
    	self.coverer_id = nil
    	self.save
    else
      false
    end
  end

  def parent
    if Attachment.exists?(["json like ?", "%\"source\":11,\"source_id\":#{self[:id]}%"])
      Attachment.where("json like '%\"source\":11,\"source_id\":#{self[:id]}%\'").first
    else
      nil
    end
  end
end
