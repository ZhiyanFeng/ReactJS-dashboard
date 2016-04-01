# == Schema Information
#
# Table name: followers
#
#  id         :integer          not null, primary key
#  source     :integer          not null
#  source_id  :integer          not null
#  user_id    :integer          not null
#  is_valid   :boolean          default(TRUE)
#  created_at :timestamp
#  updated_at :timestamp
#

class Follower < ActiveRecord::Base
  has_one :user,  :foreign_key => "id"

	attr_accessible :source, :source_id, :user_id, :is_valid

	validates_presence_of :source, :on => :create
	validates_presence_of :source_id, :on => :create
	validates_presence_of :user_id, :on => :create
	validates_uniqueness_of :user_id, :scope => [:source, :source_id]

	def get_followers
	  @followers = Follower.where(
      :source => params[:comment][:source],
      :source_id => params[:comment][:source_id]
    )

    @followers
  end

  def self.notify(type, action, generated_obj, target_obj)
    sender = User.find(generated_obj[:owner_id])
    owner = User.find(target_obj[:owner_id])
    source = 3 if type == "image"
    source = 4 if type == "post"
    followers = Follower.where(:source => source, :source_id => target_obj[:id], :is_valid => true).where.not(:user_id => generated_obj[:owner_id])
    followers.each do |u|
      if Mession.exists?(:user_id => u[:user_id],:is_active => true)
        @mession = Mession.where(:user_id => u[:user_id],:is_active => true).order("created_at DESC").first
        if @mession[:build].to_i <= 16030201
          if target_obj[:title] != "Shift Trade"
            message = type
            message = "announcement" if PostType.find_post_type(target_obj[:post_type]) == "announcement"
            @notification = Notification.new(
              :source => source,
              :source_id => target_obj[:id],
              :notify_id => u[:user_id],
              :sender_id => generated_obj[:owner_id],
              :recipient_id => target_obj[:owner_id],
              :org_id => target_obj[:org_id],
              :event => action,
              :message => message
              #:message => self.create_post_comment_message(generated_obj[:owner_id],u[:user_id],target_obj[:owner_id])
            )
            @notification.save
          end
        else
          if action == "comment"
            if target_obj[:title] == "Shift Trade"
              @notification = Notification.new(
                :source => source,
                :source_id => target_obj[:id],
                :notify_id => u[:user_id],
                :sender_id => generated_obj[:owner_id],
                :recipient_id => target_obj[:owner_id],
                :org_id => target_obj[:org_id],
                :event => action,
                :message => self.create_shift_comment_message(generated_obj[:owner_id],u[:user_id],target_obj[:owner_id])
              )
              @notification.save
            else
              @notification = Notification.new(
                :source => source,
                :source_id => target_obj[:id],
                :notify_id => u[:user_id],
                :sender_id => generated_obj[:owner_id],
                :recipient_id => target_obj[:owner_id],
                :org_id => target_obj[:org_id],
                :event => action,
                :message => self.create_post_comment_message(generated_obj[:owner_id],u[:user_id],target_obj[:owner_id])
              )
              @notification.save
            end
          elsif action == "like"
            if target_obj[:title] == "Shift Trade"
              @notification = Notification.new(
                :source => source,
                :source_id => target_obj[:id],
                :notify_id => u[:user_id],
                :sender_id => generated_obj[:owner_id],
                :recipient_id => target_obj[:owner_id],
                :org_id => target_obj[:org_id],
                :event => action,
                :message => self.create_shift_like_message(generated_obj[:owner_id],u[:user_id],target_obj[:owner_id])
              )
              @notification.save
            else
              @notification = Notification.new(
                :source => source,
                :source_id => target_obj[:id],
                :notify_id => u[:user_id],
                :sender_id => generated_obj[:owner_id],
                :recipient_id => target_obj[:owner_id],
                :org_id => target_obj[:org_id],
                :event => action,
                :message => self.create_post_like_message(generated_obj[:owner_id],u[:user_id],target_obj[:owner_id])
              )
              @notification.save
            end
          else
            ErrorLog.create(
              :file => "follower.rb",
              :function => "self.notify",
              :error => "Unable to determine which kind of message to create")
          end
        end
      else
        message = type
        message = "announcement" if PostType.find_post_type(target_obj[:post_type]) == "announcement"
        @notification = Notification.new(
          :source => source,
          :source_id => target_obj[:id],
          :notify_id => u[:user_id],
          :sender_id => generated_obj[:owner_id],
          :recipient_id => target_obj[:owner_id],
          :org_id => target_obj[:org_id],
          :event => action,
          :message => message
        )
        @notification.save
      end
    end
    Follower.follow(source, target_obj[:id], generated_obj[:owner_id])
  end

  def self.notify_shift_cover(post_id,shift_obj)
    followers = Follower.where(:source => 4, :source_id => post_id, :is_valid => true).where.not(:user_id => shift_obj[:coverer_id])
    followers.each do |u|
      if request.headers['Build-Number'] <= "16022202"

      else
        @notification = Notification.new(
          :source => 4,
          :source_id => post_id,
          :notify_id => u[:user_id],
          :sender_id => shift_obj[:coverer_id],
          :recipient_id => shift_obj[:poster_id],
          :org_id => 1,
          :event => "approved",
          :message => self.create_shift_cover_message(u[:id])
        )
        @notification.save
      end
    end
    Follower.follow(4, post_id, shift_obj[:coverer_id])
  end

  def self.notify_shift_approval(post_id,poster_id,coverer_id)
    sender = User.find(poster_id)
    followers = Follower.where(:source => 4, :source_id => post_id, :is_valid => true).where.not(:user_id => coverer_id)
    followers.each do |u|
      if request.headers['Build-Number'] <= "16022202"

      else
        @notification = Notification.new(
          :source => 4,
          :source_id => post_id,
          :notify_id => u[:user_id],
          :sender_id => coverer_id,
          :recipient_id => poster_id,
          :org_id => 1,
          :event => "covered",
          :message => Follower.create_shift_approve_message(u[:id])
        )
        @notification.save
      end
    end
    Follower.follow(4, post_id, coverer_id)
  end

  def self.follow(source, source_id, user_id)
    if Follower.exists?(:source => source, :source_id => source_id, :user_id => user_id, :is_valid => true)

    else
      @follower = Follower.create(:source => source, :source_id => source_id, :user_id => user_id)
    end
  end

  def self.create_notification_message(action, source, owner, sender, obj)
    message = ""
    if action == "comment"
      if obj[:owner_id] == sender[:id]
        message = sender[:first_name] + " " + sender[:last_name] +
          " commented on " +
          self.genderize(sender[:gender]) +
          source + "."
      elsif obj[:owner_id] == follower[:id]
        message = sender[:first_name] + " " + sender[:last_name] +
          " commented on your " +
          source + "."
      else
        message = sender[:first_name] + " " + sender[:last_name] +
          " commented on " +
          owner[:first_name] + " " + owner[:last_name] + "'s"
          source + "."
      end
    elsif action == "like"
      if obj[:owner_id] == sender[:id]
        message = sender[:first_name] + " " + sender[:last_name] +
          " liked " +
          self.genderize(sender[:gender]) +
          source + "."
      elsif obj[:owner_id] == follower[:id]
        message = sender[:first_name] + " " + sender[:last_name] +
          " liked your " +
          source + "."
      else
        message = sender[:first_name] + " " + sender[:last_name] +
          " liked " +
          owner[:first_name] + " " + owner[:last_name] + "'s"
          source + "."
      end
    elsif action == "cover"
      message = "#{sender[:first_name]} #{sender[:last_name]} covered your shift."
    end
    return message
  end

  def self.genderize(gender)
    if gender == 1
      "his "
    elsif gender == 2
      "her "
    elsif gender == 3
      "their "
    end
  end

  def self.create_post_like_message(liker_id,recipient_id,poster_id)
    liker = User.find(liker_id)
    if recipient_id == poster_id
      message = "#{liker[:first_name]} #{liker[:last_name]} liked your post."
    else
      message = "#{liker[:first_name]} #{liker[:last_name]} liked a post you are following."
    end
    return message
  end

  def self.create_shift_like_message(liker_id,recipient_id,poster_id)
    liker = User.find(liker_id)
    if recipient_id == poster_id
      message = "#{liker[:first_name]} #{liker[:last_name]} liked your shift trade."
    else
      message = "#{liker[:first_name]} #{liker[:last_name]} liked a shift trade post you are following."
    end
    return message
  end

  def self.create_post_comment_message(commenter_id,recipient_id,poster_id)
    commenter = User.find(commenter_id)
    if recipient_id == poster_id
      message = "#{commenter[:first_name]} #{commenter[:last_name]} commented on your post."
    else
      message = "#{commenter[:first_name]} #{commenter[:last_name]} commented on a post you are following."
    end
    return message
  end

  def self.create_shift_comment_message(commenter_id,recipient_id,poster_id)
    commenter = User.find(commenter_id)
    if recipient_id == poster_id
      message = "#{commenter[:first_name]} #{commenter[:last_name]} commented on your shift trade."
    else
      message = "#{commenter[:first_name]} #{commenter[:last_name]} commented on a shift trade post you are following."
    end
    return message
  end

  def self.create_shift_covered_message_for_poster(shift)
    coverer = User.find(shift[:coverer_id])
    message = "#{coverer[:first_name]} #{coverer[:last_name]} agreed to cover your shift, that was easy."
    return message
  end

  def self.create_shift_covered_message_for_coverer(shift)
    poster = User.find(shift[:owner_id])
    message = "#{approver[:first_name]} #{approver[:last_name]} approved your shift trade with #{poster[:first_name]} #{poster[:last_name]}."
    return message
  end

  def self.create_shift_covered_message_for_others(shift)
    poster = User.find(shift[:owner_id])
    coverer = User.find(shift[:coverer_id])
    message = "#{coverer[:first_name]} #{coverer[:last_name]} agreed to cover the shift for #{poster[:first_name]} #{poster[:last_name]}."
    return message
  end

  def self.create_shift_pending_message_for_poster(shift)
    coverer = User.find(shift[:coverer_id])
    message = "#{coverer[:first_name]} #{coverer[:last_name]} agreed to cover your shift! Your manager had been notified to approve it."
    return message
  end

  def self.create_shift_pending_message_for_coverer(shift)
    poster = User.find(shift[:owner_id])
    message = "Your shift trade with #{poster[:first_name]} #{poster[:last_name]} is pending manager approval."
    return message
  end

  def self.create_shift_pending_message_for_others(shift)
    poster = User.find(shift[:owner_id])
    coverer = User.find(shift[:coverer_id])
    message = "#{coverer[:first_name]} #{coverer[:last_name]} agreed to cover the shift for #{poster[:first_name]} #{poster[:last_name]}. It is now pending approval from your manager."
    return message
  end

  def self.create_shift_pending_message_for_managers(shift)
    poster = User.find(shift[:owner_id])
    coverer = User.find(shift[:coverer_id])
    message = "#{coverer[:first_name]} #{coverer[:last_name]} agreed to cover the shift for #{poster[:first_name]} #{poster[:last_name]}. It is now pending your approval."
    return message
  end

  def self.create_shift_approved_message_for_poster(shift)
    coverer = User.find(shift[:coverer_id])
    approver = User.find(shift[:approver_id])
    message = "#{approver[:first_name]} #{approver[:last_name]} approved your shift trade with #{coverer[:first_name]} #{coverer[:last_name]}."
    return message
  end

  def self.create_shift_approved_message_for_coverer(shift)
    poster = User.find(shift[:owner_id])
    approver = User.find(shift[:approver_id])
    message = "#{approver[:first_name]} #{approver[:last_name]} approved your shift trade with #{poster[:first_name]} #{poster[:last_name]}."
    return message
  end

  def self.create_shift_approved_message_for_others(shift)
    poster = User.find(shift[:owner_id])
    coverer = User.find(shift[:coverer_id])
    approver = User.find(shift[:approver_id])
    message = "#{approver[:first_name]} #{approver[:last_name]} approved the shift trade between #{poster[:first_name]} #{poster[:last_name]} and #{coverer[:first_name]} #{coverer[:last_name]}. Hourray!"
    return message
  end

  def self.create_shift_rejected_message_for_poster(shift)
    coverer = User.find(shift[:coverer_id])
    approver = User.find(shift[:approver_id])
    message = "#{approver[:first_name]} #{approver[:last_name]} rejected your shift trade with #{coverer[:first_name]} #{coverer[:last_name]}."
    return message
  end

  def self.create_shift_rejected_message_for_coverer(shift)
    poster = User.find(shift[:owner_id])
    approver = User.find(shift[:approver_id])
    message = "#{approver[:first_name]} #{approver[:last_name]} rejected your shift trade with #{poster[:first_name]} #{poster[:last_name]}."
    return message
  end

  def self.create_shift_rejected_message_for_others(shift)
    poster = User.find(shift[:owner_id])
    coverer = User.find(shift[:coverer_id])
    approver = User.find(shift[:approver_id])
    message = "#{approver[:first_name]} #{approver[:last_name]} rejected the shift trade between #{poster[:first_name]} #{poster[:last_name]} and #{coverer[:first_name]} #{coverer[:last_name]}. Sorry! :("
    return message
  end

  private

  def push_to(user_id, org_id, source, source_id)
    @mession = Mession.where(
      :user_id => user_id,
      :is_active => true,
      :org_id => org_id
    ).last

    if @mession
      begin
        if @mession[:push_to] == "GCM"
          n = Rpush::Gcm::Notification.new
          n.app = Rpush::Gcm::App.find_by_name("coffee_enterprise")
          n.registration_ids = @mession[:push_id]
          #n.attributes_for_devie
          n.data = {
            :category => "like",
            :message => message,
            :org_id => org_id,
            :source => source,
            :source_id => source_id
          }
          n.save!
        else
          n = Rpush::Apns::Notification.new
          n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
          n.device_token = @mession[:push_id]
          n.alert = message
          #n.attributes_for_devie
          n.data = {
            :category => "like",
            :org_id => org_id,
            :source => source,
            :source_id => source_id
          }
          n.save!
        end
      rescue
      ensure
      end
    end
  end
end
