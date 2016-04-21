# == Schema Information
#
# Table name: comments
#
#  id            :integer          not null, primary key
#  owner_id      :integer          not null
#  source        :integer          not null
#  source_id     :integer
#  content       :text             not null
#  attachment_id :integer
#  comment_type  :integer
#  likes_count   :integer          default(0)
#  is_flagged    :boolean          default(FALSE)
#  is_valid      :boolean          default(TRUE)
#  created_at    :timestamp
#  updated_at    :timestamp
#

class Comment < ActiveRecord::Base
  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"
  has_many :likes, -> { where ['likes.source = 5'] }, :foreign_key => "source_id"
  has_many :users, :through => :likes
  has_many :flags, -> { where ['flags.source = 5'] }, :foreign_key => "source_id"
  has_many :users, :through => :flags

  #default_scope { :order => 'created_at asc' }
  default_scope { order('created_at ASC') }

  before_save :filter_language
  #attr_accessor :liked, :flagged
  attr_accessor :user_id

	attr_accessible :owner_id, :content, :source, :source_id, :likes_count, :attachment_id, :comment_type, :is_valid

	validates_presence_of :content, :on => :create
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

  def create_comment(type, target, push)
    transaction do
      if save
        @user = User.find(self[:owner_id])
        @user.update_attributes(:shyft_score => @user[:shyft_score] + 1)
        if push
          Follower.notify(type, "comment", self, target)
          if Mession.exists?(['user_id = ? AND is_active AND push_id IS NOT NULL', target.owner_id]) && target.owner_id != self.owner_id
            baseType = PostType.find_post_type(target.post_type)
            mession = Mession.where(:user_id => target.owner_id, :is_active => true).first
            commentor = User.find(self.owner_id)
            if target[:title] == "Shift Trade"
              message = commentor[:first_name] + " " + commentor[:last_name] + " just commented on your shift post 💬"
            else
              message = commentor[:first_name] + " " + commentor[:last_name] + " just commented on your post 💬"
            end
            mession.push("open_detail", message, baseType, target.id, false, false)
          end
        end
        target.update_attribute(:comments_count, target.comments_count + 1)
      end
    end
  end

  def destroy_comment
    self.update_attribute(:is_valid, false)
    if Source.name_from_id(self.source) == "post"
      return post_uncomment(self.source_id)
    elsif Source.name_from_id(self.source) == "image"
      return image_uncomment(self.source_id)
    else
      #return false
      return post_uncomment(self.source_id)
    end
  end

  def post_uncomment(id)
    if Post.exists?(:id => id)
      @post = Post.find(id)
      @post.update_attribute(:comments_count, @post.comments_count - 1)
    else
      errors[:base] << "Couldn't find Post with id=" + id
      return false
    end
  end

  def image_uncomment(id)
    if Image.exists?(:id => id)
      @image = Image.find(id)
      @image.update_attribute(:comments_count, @image.comments_count - 1)
    else
      errors[:base] << "Couldn't find Image with id=" + id
      return false
    end
  end

  def filter_language
    filter_words = ['shit','bitch','cunt','fuck','bastard','ass','a$$','anal','buttfuck','dick','pussy','penis','pu$$y','cock']
    filter_words.each do |cuss|
       self.content.gsub!(/\b#{cuss}\b/i, '****')
    end
  end

end
