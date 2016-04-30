# == Schema Information
#
# Table name: posts
#
#  id             :integer          not null, primary key
#  org_id         :integer          not null
#  owner_id       :integer          not null
#  title          :string(255)      not null
#  content        :text             not null
#  attachment_id  :integer
#  post_type      :integer
#  comments_count :integer          default(0)
#  likes_count    :integer          default(0)
#  is_flagged     :boolean          default(FALSE)
#  is_valid       :boolean          default(TRUE)
#  created_at     :timestamp
#  updated_at     :timestamp
#

class Post < ActiveRecord::Base
  belongs_to :settings, :class_name => "PostType", :foreign_key => "post_type"
  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"
  belongs_to :organization, :class_name => "Organization", :foreign_key => "org_id"
  has_many :comments, -> { where ['comments.source = 4 AND comments.is_valid'] }, :class_name => "Comment", :foreign_key => "source_id"
  has_many :likes, -> { where ['likes.source = 4 AND likes.is_valid'] }, :class_name => "Like", :foreign_key => "source_id"
  #has_many :likes, -> { where ['likes.source = 4'] }, :foreign_key => "source_id"
  has_many :users, :through => :likes
  has_many :flags, -> { where ['flags.source = 4'] }, :foreign_key => "source_id"
  has_many :users, :through => :flags

  before_save :filter_language
  before_create :set_sort_date
  after_create :update_channel
  #attr_accessor :liked, :flagged
  attr_accessor :user_id, :archtype

  attr_accessible :org_id,
  :owner_id,
  :title,
  :url,
  :content,
  :location,
  :user_group,
  :attachment_id,
  :post_type,
  :comments_count,
  :channel_id,
  :likes_count,
  :views_count,
  :allow_comment,
  :allow_like,
  :z_index,
  :is_valid

  validates_presence_of :org_id, :on => :create
  validates_presence_of :owner_id, :on => :create
  validates_presence_of :title, :on => :create
  #validates_presence_of :content, :on => :create
  validates_presence_of :post_type, :on => :create

  def check_user(id)
    self.user_id = id
  end

  def set_archtype(type)
    self.archtype = type
  end

  def get_archtype
    self.archtype
  end

  def add_view
    self.update_attribute(:views_count, self[:views_count] + 1)
  end

  #def indicate(user_id, type)
  #  user = User.find(user_id)
  #  if type == "post" || type == "announcement" || type == "training"
  #    self.liked = Like.exists?(:owner_id => user_id, :source => 4, :source_id => self.id) ? true : false
  #    self.flagged = Flag.exists?(:owner_id => user_id, :source => 4, :source_id => self.id) ? true : false
  #  elsif type == "event"
  #    self.liked = Like.exists?(:owner_id => user_id, :source => 7, :source_id => self.id) ? true : false
  #    self.flagged = Flag.exists?(:owner_id => user_id, :source => 7, :source_id => self.id) ? true : false
  #  else
  #
  #  end
  #end

  def process_gratitude(amount)

  end

  def process_attachments(attachments = nil, user_id = nil, tip_amount = nil)
    @user = User.find(user_id)
    json = {}
    json['objects'] = []
    attachments.each do |attachment|
      object = attachment.first

      if object[0] == "image"
        image = {}
        image['source'] = 3
        image['source_id'] = object.last["id"]
        json['objects'].push(image)
      elsif object[0] == "shift"
        shift = {}
        shift['source'] = 11
        @shift = ScheduleElement.create(
          :owner_id => self.owner_id,
          :schedule_id => 0,
          :name => "shift",
          :start_at => object.last['start_at'],
          :end_at => object.last['end_at']
        )
        shift['source_id'] = @shift.id
        json['objects'].push(shift)
        self.update_attribute(:location, @user[:location])

        if tip_amount.present? && tip_amount.to_f > 0
          @gratitude = Gratitude.new(
            :amount => tip_amount,
            :shift_id => @shift[:id],
            :owner_id => self[:owner_id],
            :source => 4,
            :source_id => self[:id]
          )
          @gratitude.create_gratitude(self, false)
        end
      end
    end
    @attachment = Attachment.new(
      :json => json.to_json.to_s
    )
    @attachment.save
    self.update_attribute(:attachment_id, @attachment.id)
  end

  def compose(image = nil,
    video = nil,
    event = nil,
    poll = nil,
    schedule = nil,
    safety_course = nil,
    created_at = nil, push_notification = nil)
    #transaction do
      @postType = PostType.find(self.post_type)

      self.attach_image(image) if @postType[:image_count] > 0
      #self.attach_video(video) if @postType[:includes_video] == true
      self.attach_video(video) if @postType[:includes_video] == true
      self.attach_event(event) if @postType[:includes_event] == true
      self.attach_poll(poll) if @postType[:includes_survey] == true
      self.attach_schedule(schedule) if @postType[:includes_schedule] == true
      self.attach_safety_course(safety_course) if @postType[:includes_safety_course] == true

      self.update_attribute(:is_valid, true)
      if self.save
        #basetype=PostType.find_post_type(self[:post_type])
        basetype = @postType[:base_type]
        if basetype != "safety_course"
          Follower.follow(4, self[:id], self[:owner_id])
          User.notification_broadcast(self[:owner_id], self[:org_id], basetype, "new", "", 4, self[:id], created_at, self[:location], self[:user_group])
        end
        if basetype == "post"
          begin
            @user = User.find(self[:owner_id])
            message = @user[:first_name] + " " + @user[:last_name] + ": " + self[:content]
            User.location_broadcast(@user[:id], @user[:location], "post", "newsfeed_post", message, 4, self[:id], created_at = nil, user_group=nil) if @user[:location] != 0
          ensure
          end
        end
        if push_notification
          #Mession.broadcast(self[:org_id], "refresh", "newsfeed", 4, self[:id], self[:owner_id], self[:owner_id], nil, nil) if basetype == "post"
          #Mession.broadcast(self[:org_id], "refresh", "announcement", 4, self[:id], self[:owner_id], self[:owner_id], nil, nil) if basetype == "announcement"
          Mession.broadcast(self[:org_id], "open_detail", "announcement", 4, self[:id], self[:org_id], self[:org_id], self[:title], created_at, self[:location], self[:user_group]) if basetype == "announcement"
          Mession.broadcast(self[:org_id], "open_app", "training", 6, self[:id], self[:org_id], self[:org_id], self[:title], created_at, self[:location], self[:user_group]) if basetype == "training"
          Mession.broadcast(self[:org_id], "open_app", "quiz", 8, self[:id], self[:org_id], self[:org_id], self[:title], created_at, self[:location], self[:user_group]) if basetype == "quiz"
          Mession.broadcast(self[:org_id], "open_app", "safety_training", 9, self[:id], self[:org_id], self[:org_id], self[:title], created_at, self[:location], self[:user_group]) if basetype == "safet_training"
          Mession.broadcast(self[:org_id], "open_app", "safety_quiz", 8, self[:id], self[:org_id], self[:org_id], self[:title], created_at, self[:location], self[:user_group]) if basetype == "safety_quiz"
        end

      end
    #end
  end

  def compose_v_four(image = nil,
    video = nil,
    event = nil,
    poll = nil,
    schedule = nil,
    safety_course = nil,
    created_at = nil, push_notification = nil)
    #transaction do
      @postType = PostType.find(self.post_type)

      self.attach_image(image) if @postType[:image_count] > 0
      #self.attach_video(video) if @postType[:includes_video] == true
      self.attach_video(video) if @postType[:includes_video] == true
      self.attach_event(event) if @postType[:includes_event] == true
      self.attach_poll(poll) if @postType[:includes_survey] == true
      self.attach_schedule(schedule) if @postType[:includes_schedule] == true
      self.attach_safety_course(safety_course) if @postType[:includes_safety_course] == true

      self.update_attribute(:is_valid, true)
      if self.save
        #basetype=PostType.find_post_type(self[:post_type])
        basetype = @postType[:base_type]
        Follower.follow(4, self[:id], self[:owner_id])
        #User.notification_broadcast(self[:owner_id], self[:org_id], basetype, "new", "", 4, self[:id], created_at, self[:location], self[:user_group])
      end
    #end
  end

  def compose_with_attachment_id(attachment_id, created_at = nil, push_notification = nil)
    @postType = PostType.find(self.post_type)
    #transaction do
      self.update_attribute(:attachment_id, attachment_id)
      self.update_attribute(:is_valid, true)
      @attachment = Attachment.find(attachment_id)

      begin
        Rails.logger.debug("Attempting set the post to invalid because of zencoder post")
        objArray = JSON.parse(@attachment.json)
        objArray["objects"].each do |p|
          if p["source"] == 6
            if Video.exists?(:id => p["source_id"])
              obj = Video.find(p["source_id"])
              if obj.video_host == 1
                self.update_attribute(:is_valid, false)
              end
            end
          end
        end
      rescue
        Rails.logger.debug("Failed to load attachment")
      end

      if self.save
        #basetype=PostType.find_post_type(self[:post_type])
        basetype = @postType[:base_type]
        Follower.follow(4, self[:id], self[:owner_id])
        User.notification_broadcast(self[:owner_id], self[:org_id], basetype, "new", "", 4, self[:id], created_at, self[:location], self[:user_group])
        if push_notification
          #Mession.broadcast(self[:org_id], "refresh", "newsfeed", 4, self[:id], self[:owner_id], self[:owner_id], nil, nil) if basetype == "post"
          #Mession.broadcast(self[:org_id], "refresh", "announcement", 4, self[:id], self[:owner_id], self[:owner_id], nil, nil) if basetype == "announcement"
          #if basetype == "announcement" || basetype == "training"
          #  Mession.broadcast(self[:org_id], "open_detail", "announcement", 4, self[:id], self[:org_id], self[:org_id], self[:title], created_at)
          #end
          Mession.broadcast(self[:org_id], "open_detail", "announcement", 4, self[:id], self[:org_id], self[:org_id], self[:title], created_at, self[:location], self[:user_group]) if basetype == "announcement"
          Mession.broadcast(self[:org_id], "open_app", "training", 6, self[:id], self[:org_id], self[:org_id], self[:title], created_at, self[:location], self[:user_group]) if basetype == "training"
          Mession.broadcast(self[:org_id], "open_app", "quiz", 8, self[:id], self[:org_id], self[:org_id], self[:title], created_at, self[:location], self[:user_group]) if basetype == "quiz"
          Mession.broadcast(self[:org_id], "open_app", "safety_training", 9, self[:id], self[:org_id], self[:org_id], self[:title], created_at, self[:location], self[:user_group]) if basetype == "safet_training"
          Mession.broadcast(self[:org_id], "open_app", "safety_quiz", 8, self[:id], self[:org_id], self[:org_id], self[:title], created_at, self[:location], self[:user_group]) if basetype == "safety_quiz"
        #User.notification_broadcast(self[:owner_id], self[:org_id], basetype, "new", "", 4, self[:id])
        end
      end
    #end

  end


  def attached
    if self.attachment_id.presence
      return Attachment.find(attachment_id)
    else
      return false
    end
  end

  def attach_image(image)
    @image = Image.new(
      :org_id => self.org_id,
      :owner_id => self.owner_id,
      :image_type => 4
    )
    @image.save
    @image.update_attribute(:avatar, image)
    @image.update_attribute(:is_valid, true)
    Follower.follow(3, @image[:id], self.owner_id)
    if !@attachment = self.attached
      temp = '{"objects":[{"source":3, "source_id":' + @image.id.to_s + '}]}'
      @attachment = Attachment.new(
        :json => temp
      )
    else
      temp = ',{"source":3, "source_id":' + @image.id.to_s + '}'
      @attachment.json.insert(@attachment.json.length-2, temp)
    end
    @attachment.save
    self.update_attribute(:attachment_id, @attachment.id)
  end

  def attach_video(video)
    host = video[:video_host] == "Youtube" ? 2 : 1
    @video = Video.new(
      :org_id => self.org_id,
      :owner_id => self.owner_id,
      :video_id => video[:video_id],
      :video_url => video[:video_url],
      :video_host => host,
      :thumb_url => video[:thumb_url],
      :video_duration => video[:video_duration]
    )

    if @video.save
      #Follower.follow(3, @image[:id], self.owner_id)
      if !@attachment = self.attached
      temp = '{"objects":[{"source":6, "source_id":' + @video.id.to_s + '}]}'
        @attachment = Attachment.new(
          :json => temp
        )
      else
        temp = ',{"source":6, "source_id":' + @video.id.to_s + '}'
        @attachment.json.insert(@attachment.json.length-2, temp)
      end
      @attachment.save
      self.update_attribute(:attachment_id, @attachment.id)
    else
      Rails.logger.debug(@video.errors.inspect)
    end
  end

  def replace_video(video)
    @video = Video.new(
      :org_id => self.org_id,
      :owner_id => self.owner_id,
      :video_id => video[:video_id],
      :video_url => video[:video_url],
      :video_host => video[:video_host],
      :thumb_url => video[:thumb_url],
      :video_duration => video[:video_duration]
    )

    if @video.save
      #Follower.follow(3, @image[:id], self.owner_id)
      temp = '{"objects":[{"source":6, "source_id":' + @video.id.to_s + '}]}'
      @attachment = Attachment.new(
        :json => temp
      )
      @attachment.save
      self.update_attribute(:attachment_id, @attachment.id)
    else
      Rails.logger.debug(@video.errors.inspect)
    end
  end

  def attach_event(event)
    @event = Event.new(
      :org_id => self.org_id,
      :owner_id => self.owner_id,
      :event_start => event[:event_start],
      :event_end => event[:event_end],
      :event_poi => event[:event_poi],
      :event_address => event[:event_address],
      :event_lat => event[:event_lat],
      :event_lng => event[:event_lng],
      :event_open => true
    )
    @event.save
    #Follower.follow(3, @image[:id], self.owner_id)
    if !@attachment = self.attached
      temp = '{"objects":[{"source":7, "source_id":' + @event.id.to_s + '}]}'
      @attachment = Attachment.new(
        :json => temp
      )
    else
      temp = ',{"source":7, "source_id":' + @event.id.to_s + '}'
      @attachment.json.insert(@attachment.json.length-2, temp)
    end
    @attachment.save
    self.update_attribute(:attachment_id, @attachment.id)
  end

  def attach_poll(poll)
    @poll = Poll.new(
      :org_id => self.org_id,
      :poll_name => self.title,
      :owner_id => self.owner_id,
      :count_down => poll[:count_down],
      :pass_mark => poll[:pass_mark],
      :question_count => poll[:question_count],
      :start_at => poll[:start_at],
      :end_at => poll[:end_at]
    )
    @poll.save
    q_id = @poll[:id]
    q_count = 0
    poll[:questions].each do |q|
      Rails.logger.debug(q.inspect)
      ques = PollQuestion.new(:poll_id => q_id,:content => q[1][:question_title], :randomize => q[1][:randomize], :question_type => 0)
      if ques.save
        q_count = q_count + 1
        if q[1][:attachment_id].present?
          ques.update_attribute(:attachment_id, q[1][:attachment_id])
        end
        q[1][:answers].each do |w|
          Rails.logger.debug("HAHAHA")
          Rails.logger.debug(w[1].inspect)
          a = PollAnswer.new(:question_id => ques[:id], :content => w[1][:content], :correct => w[1][:correct])
          if a.save
            #q_count = q_count + 1
          end
        end
      else
        Rails.logger.debug(ques.errors.inspect)
      end
    end
    @poll.update_attribute(:question_count, q_count)
    @poll.save

    if !@attachment = self.attached
      temp = '{"objects":[{"source":8, "source_id":' + @poll.id.to_s + '}]}'
      @attachment = Attachment.new(
        :json => temp
      )
    else
      temp = ',{"source":8, "source_id":' + @poll.id.to_s + '}'
      @attachment.json.insert(@attachment.json.length-2, temp)
    end
    @attachment.save
    self.update_attribute(:attachment_id, @attachment.id)
  end

  def attach_schedule(schedule)
    if lines = schedule.split(/\r?\n/)
      @schedule = Schedule.new(
        :name => self[:title],
        :org_id => self[:org_id],
        :start_date => DateTime.now.to_date,
        :end_date => DateTime.now.to_date,
        :admin_id => self[:owner_id]
      )
      @schedule.save
      lines.each do |line|
        temp = line.split('|')
        id = temp[0].to_i
        times = temp[1].split(',')
        @user = User.find(id)
        name = @user[:first_name] + " " + @user[:last_name]

        times.each do |time|
          at = time.split('~')
          @element = ScheduleElement.new(
            :name => name + "'s shift",
            :schedule_id => @schedule[:id],
            :owner_id => id,
            :start_at => at[0],
            :end_at => at[1],
          )
          @element.save
        end
      end
    end
    #Follower.follow(3, @image[:id], self.owner_id)
    if !@attachment = self.attached
      temp = '{"objects":[{"source":9, "source_id":' + @schedule.id.to_s + '}]}'
      @attachment = Attachment.new(
        :json => temp
      )
    else
      temp = ',{"source":9, "source_id":' + @schedule.id.to_s + '}'
      @attachment.json.insert(@attachment.json.length-2, temp)
    end
    @attachment.save
    self.update_attribute(:attachment_id, @attachment.id)
  end

  def attach_schedule_snapshot(schedule)
    #Follower.follow(3, @image[:id], self.owner_id)
    if !@attachment = self.attached
      temp = '{"objects":[{"source":12, "source_id":' + schedule.id.to_s + '}]}'
      @attachment = Attachment.new(
        :json => temp
      )
    else
      temp = ',{"source":12, "source_id":' + schedule.id.to_s + '}'
      @attachment.json.insert(@attachment.json.length-2, temp)
    end
    @attachment.save
    self.update_attribute(:attachment_id, @attachment.id)
  end

  def post_with_image(file)
    transaction do
      if save
        @image = Image.new(
          :org_id => self.org_id,
          :owner_id => self.owner_id,
          :image_type => 4
        )
        @image.save
        @image.update_attribute(:avatar, file)
        @image.update_attribute(:is_valid, true)
        Follower.follow(3, @image[:id], self.owner_id)
        @attachment = Attachment.new(
          :source => Source.id_from_name("image"),
          :source_id => @image.id
        )
        @attachment.save
        self.update_attribute(:attachment_id, @attachment.id)
      end
    end
  end

  def basic_hello
    transaction do
      if save
        #temp = '{"objects":[{"source":3, "source_id":22}]}'
        #@attachment = Attachment.new(
        #  :json => temp
        #)
        #@attachment.save
        #self.update_attribute(:attachment_id, @attachment.id)
        Follower.follow(4, self[:id], self[:owner_id])
      end
    end
  end

  def hello_with_image(image_id)
    transaction do
      if save
        temp = '{"objects":[{"source":3, "source_id":' + image_id.to_s + '}]}'
        @attachment = Attachment.new(
          :json => temp
        )
        @attachment.save
        self.update_attribute(:attachment_id, @attachment.id)
        Follower.follow(4, self[:id], self[:owner_id])
      end
    end
  end

  def basic_comment(post_id)
    if Post.exists?(:id => post_id)
      @post = Post.find(post_id)
      transaction do
        if save
          @post.update_attribute(:comments_count, @post.comments_count + 1)
        end
      end
    else
      errors[:base] << "Couldn't find Post with id=" + post_id
      return false
    end
  end

  def announcement_with_image(file)
    transaction do
      if save
        @image = Image.new(
          :org_id => self.org_id,
          :owner_id => self.owner_id,
          :image_type => 3
        )
        @image.save
        @image.update_attribute(:avatar, file)
        @image.update_attribute(:is_valid, true)
        @attachment = Attachment.new(
          :source => Source.id_from_name("image"),
          :source_id => @image.id
        )
        @attachment.save
        self.update_attribute(:attachment_id, @attachment.id)
      end
    end
  end

  def post_with_video(video)
    transaction do
      if save
        @video = Video.new(
          :org_id => self.org_id,
          :owner_id => self.owner_id,
          :video_id => video[:video_id],
          :video_url => video[:video_url],
          :video_host => video[:video_host],
          :thumb_url => video[:thumb_url]
        )
        @video.save
        @attachment = Attachment.new(
          :source => Source.id_from_name("video"),
          :source_id => @video.id
        )
        @attachment.save
        self.update_attribute(:attachment_id, @attachment.id)
      end
    end
  end

  def post_with_event(event)
    transaction do
      if save
        @event = Event.new(
          :org_id => self.org_id,
          :owner_id => self.owner_id,
          :event_start => event[:event_start],
          :event_end => event[:event_end],
          :event_poi => event[:event_poi],
          :event_address => event[:event_address],
          :event_lat => event[:event_lat],
          :event_lng => event[:event_lng],
          :event_open => true
        )
        @event.save
        @attachment = Attachment.new(
          :source => Source.id_from_name("event"),
          :source_id => @event.id
        )
        @attachment.save
        self.update_attribute(:attachment_id, @attachment.id)
      end
    end
  end

  def destroy_comment
    self.update_attribute(:is_valid, false)
    if Post.exists?(:id => self.post_reference)
      @post = Post.find(self.post_reference)
      @post.update_attribute(:comments_count, @post.comments_count - 1)
    else
      errors[:base] << "Couldn't find Post with id=" + post_id
      return false
    end
  end

  def self.dashboard_update(data)
    transaction do
      data.each do |d|
        Rails.logger.debug("dashboard_update")
        Rails.logger.debug(d[1])
        if d[1][:id].to_i == 0
          Post.dashboard_update_new(d[1])
        elsif d[1][:id].to_i > 0
          Post.dashboard_update_edit(d[1])
        else
          Post.dashboard_update_delete(d[1])
        end
      end
    end
  end

  def self.dashboard_update_edit(object)
    Rails.logger.debug("dashboard_update_edit")
    #Rails.logger.debug(object)
    if object[:table_name] == "post"
      @obj = Post.find(object[:id])
      @obj.update(object[:post])
    elsif object[:table_name] == "poll"
      @obj = Poll.find(object[:id])
      @obj.update(object[:poll])
    elsif object[:table_name] == "poll_question"
      #Rails.logger.debug("question_edit")
      #Rails.logger.debug(object)
      @obj = PollQuestion.find(object[:id])
      @obj.update(object[:poll_question])
      object[:answers].each do |a|
        #Rails.logger.debug("answers_each_edit")
        #Rails.logger.debug(a[1])
        @ans = PollAnswer.find(a[1][:id])
        @ans.update_attributes(a[1][:poll_answer])
        @ans.save
      end
    #elsif object[:table_name] == "poll_answer"
    #  @obj = PollAnswer.find(object[:id])
    #  @obj.update(object[:poll_answer])
    else

    end
    @obj.save
    true
  end

  def self.dashboard_update_new(object)
    Rails.logger.debug("dashboard_update_new")
    Rails.logger.debug(object)
    if object[:table_name] == "post"
      @obj = Post.new(object[:post])
      @obj.save
    elsif object[:table_name] == "poll"
      @obj = Poll.new(object[:poll])
      @obj.save
    elsif object[:table_name] == "poll_question"
      Rails.logger.debug("question_new")
      Rails.logger.debug(object)
      @obj = PollQuestion.new(object[:poll_question])
      @obj.save
      object[:answers].each do |a|
        Rails.logger.debug("answers_each_new")
        Rails.logger.debug(a[1])
        correct = a[1][:poll_answer][:correct] == "true" ? 'true' : 'false'
        ans = PollAnswer.new(
          :question_id => @obj[:id],
          :content => a[1][:poll_answer][:content],
          :correct => correct
        )
        ans.save!
      end
    #elsif object[:table_name] == "poll_answer"
    #  @obj = PollAnswer.new(object[:poll_answer])
    #  @obj.save
    else

    end
    true
  end

  def self.dashboard_update_delete(object)
    #Rails.logger.debug("dashboard_update_delete")
    #Rails.logger.debug(object)
    if object[:table_name] == "post"
      @obj = Post.find(object[:id].to_i.abs)
      @obj.update_attribute(:is_valid, false)
    elsif object[:table_name] == "poll"
      @obj = Poll.find(object[:id].to_i.abs)
      @obj.update_attribute(:is_valid, false)
    elsif object[:table_name] == "poll_question"
      @obj = PollQuestion.find(object[:id].to_i.abs)
      @obj.update_attribute(:is_valid, false)
    elsif object[:table_name] == "poll_answer"
      @obj = PollAnswer.find(object[:id].to_i.abs)
      @obj.update_attribute(:is_valid, false)
    else

    end
    @obj.save
    true
  end

  def set_sort_date
    self.sorted_at = self.created_at
  end

  def filter_language
    if Organization.find(self.org_id).profanity_filter
      begin
        filter_words = ['shit','bitch','cunt','fuck','bastard','ass','a$$','anal','buttfuck','dick','pussy','penis','pu$$y','cock']
        filter_words.each do |cuss|
           self.content.gsub!(/\b#{cuss}\b/i, '****')
           self.title.gsub!(/\b#{cuss}\b/i, '****')
        end
      rescue
      end
    end
  end

  def update_channel
    if self.channel_id.present? && self.channel_id != 1
      if Channel.exists?(self.channel_id)
        @channel = Channel.find(self.channel_id)
        begin
          #EngagementWorker.perform_async(@channel[:channel_frequency].to_i) if @channel[:channel_type] == "location_feed"
        rescue
        ensure
        end
        @user = User.find(self.owner_id)
        if self.get_archtype == "shift_trade"
          channel_latest_message = @user[:first_name] + " " + @user[:last_name] + " posted a shift trade."
          @user.update_attributes(:shift_count => @user[:shift_count] + 1, :shyft_score => @user[:shyft_score] + 2)
        else
          channel_latest_message = @user[:first_name] + " " + @user[:last_name] + ": " + self[:content]
          @user.update_attributes(:shyft_score => @user[:shyft_score] + 2)
        end

        if self.get_archtype != "schedule_snapshot"
          #channel_latest_message = @user[:first_name] + " " + @user[:last_name] + " posted a shift trade."
          @channel.update_attributes(:channel_latest_content => channel_latest_message, :channel_content_count => @channel[:channel_content_count] + 1)
        else
          @user.update_attributes(:shyft_score => @user[:shyft_score] + 3)
        end

        # TODO: Need to figure out the following code to reactivate channels
        #Subscription.where(:channel_id => self.channel_id, :is_valid => true).first.update_attribute(:is_active, true)
      end
    elsif self.owner_id == 134
      @channel = Channel.find(1)
      @user = User.find(134)
      channel_latest_message = self[:content]
      @channel.update_attributes(:channel_latest_content => channel_latest_message, :channel_content_count => @channel[:channel_content_count] + 1)
    else

    end


  end
end
