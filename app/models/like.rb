# == Schema Information
#
# Table name: likes
#
#  id         :integer          not null, primary key
#  owner_id   :integer          not null
#  source     :integer          not null
#  source_id  :integer          not null
#  is_valid   :boolean          default(TRUE)
#  created_at :timestamp
#  updated_at :timestamp
#

class Like < ActiveRecord::Base
  belongs_to :comments
  belongs_to :posts
  belongs_to :users
  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"

  attr_accessible :owner_id, :source, :source_id

  validates_presence_of :owner_id, :on => :create
  validates_presence_of :source, :on => :create
  validates_presence_of :source_id, :on => :create
	validates_uniqueness_of :owner_id, :scope => [:source, :source_id]

  def create_like(type, target, push)
    transaction do
      if save
        @user = User.find(self[:owner_id])
        @user.update_attributes(:shyft_score => @user[:shyft_score] + 1)
        if push
          Follower.notify(type, "like", self, target)
          if Mession.exists?(['user_id = ? AND is_active AND push_id IS NOT NULL', target.owner_id]) && target.owner_id != self.owner_id
            baseType = PostType.find_post_type(target.post_type)
            mession = Mession.where(:user_id => target.owner_id, :is_active => true).first
            liker = User.find(self.owner_id)
            if target[:title] == "Shift Trade"
              message = liker[:first_name] + " " + liker[:last_name] + " has liked your Shift 👍"
            else
              message = liker[:first_name] + " " + liker[:last_name] + " has liked your Post 👍"
            end
            mession.push("open_detail", message, baseType, target.id, false, false)
          end
          #if Source.name_from_id(self.source) == "post"
            #Follower.notify(type, "like", self, target)
          #elsif Source.name_from_id(self.source) == "image"
          #  Follower.notify(type, "like", self, target)
          #elsif Source.name_from_id(self.source) == "comment"
          #  Follower.notify(type, "like", self, target)
          #else
          #  Follower.notify(type, "like", self, target)
          #end
        #target.update_attribute(:likes_count, target.likes_count + 1)
        end
        if Source.name_from_id(self.source) == "post"
          return post_like(self.source_id)
        elsif Source.name_from_id(self.source) == "image"
          return image_like(self.source_id)
        elsif Source.name_from_id(self.source) == "comment"
          return comment_like(self.source_id)
        else
          return post_like(self.source_id)
        end
      end
    end
  end

  def destroy_like
    if Source.name_from_id(self.source) == "post"
      return post_unlike(self.source_id)
    elsif Source.name_from_id(self.source) == "image"
      return image_unlike(self.source_id)
    elsif Source.name_from_id(self.source) == "comment"
      return comment_unlike(self.source_id)
    else
      #return false
      return post_unlike(self.source_id)
    end
  end

  def post_like(id)
    if Post.exists?(:id => id)
      @post = Post.find(id)
      transaction do
        if save
          @post.update_attribute(:likes_count, @post.likes_count + 1)
        end
      end
    else
      errors[:base] << "Couldn't find Post with id=" + id
      return false
    end
  end

  def image_like(id)
    if Image.exists?(:id => id)
      @image = Image.find(id)
      transaction do
        if save
          @image.update_attribute(:likes_count, @image.likes_count + 1)
        end
      end
    else
      errors[:base] << "Couldn't find Image with id=" + id
      return false
    end
  end

  def comment_like(id)
    if Comment.exists?(:id => id)
      @comment = Comment.find(id)
      transaction do
        if save
          @comment.update_attribute(:likes_count, @comment.likes_count + 1)
        end
      end
    else
      errors[:base] << "Couldn't find Comment with id=" + id
      return false
    end
  end

  def post_unlike(id)
    if Post.exists?(:id => id)
      @post = Post.find(id)
      transaction do
        if delete
          @post.update_attribute(:likes_count, @post.likes_count - 1)
        end
      end
    else
      errors[:base] << "Couldn't find Post with id=" + id
      return false
    end
  end

  def image_unlike(id)
    if Image.exists?(:id => id)
      @image = Image.find(id)
      transaction do
        if delete
          @image.update_attribute(:likes_count, @image.likes_count - 1)
        end
      end
    else
      errors[:base] << "Couldn't find Image with id=" + id
      return false
    end
  end

  def comment_unlike(id)
    if Comment.exists?(:id => id)
      @comment = Comment.find(id)
      transaction do
        if delete
          @comment.update_attribute(:likes_count, @comment.likes_count - 1)
        end
      end
    else
      errors[:base] << "Couldn't find Comment with id=" + id
      return false
    end
  end

end
