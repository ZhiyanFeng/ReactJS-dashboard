class UserProfileSerializer < ActiveModel::Serializer
  has_one :profile_image, serializer: ProfileImageSerializer
  has_one :cover_image, serializer: ProfileImageSerializer
  attributes :id,
  :active_org,
  :first_name, 
  :last_name, 
  :email, 
  :phone_number, 
  :chat_handle, 
  :user_group, 
  :position,
  :location, 
  :status,
  :gender,
  :likes_count,
  :comments_count,
  :posts_count,
  :number_of_shifts_posted,
  :number_of_shifts_covered,
  :shyft_score,
  :quiz_count,
  :training_count

  def user_group
    if object.user_group.present?
      if UserGroup.where(:id => object.user_group).exists?
        UserGroup.find_by_id(object.user_group).group_name
      else
        "Team member"
      end
    end
  end

  def position
    if object.user_group.present?
      if UserGroup.where(:id => object.user_group).exists?
        UserGroup.find_by_id(object.user_group).group_name
      else
        "Team member"
      end
    end
  end
  

  def location
    if object.user_group.present?
      if Location.where(:id => object.location).exists?
        @location = Location.find_by_id(object.location)
        if @location.street_number.present?
          @location.street_number + " " + @location.address
        else
          @location.address
        end
      else
        "Not assigned"
      end
    end
  end

  def likes_count
    Like.where(:owner_id => object.id).count
  end

  def comments_count
    Comment.where(:owner_id => object.id).count
  end

  def posts_count
    Post.where(:owner_id => object.id).count
  end

  def number_of_shifts_posted
    object[:shift_count]
  end

  def number_of_shifts_covered
    object[:cover_count]
  end

  def shyft_score
    object[:shyft_score]
  end

  def quiz_count
    PollResult.where(:user_id => object.id, :passed => true).count
  end

  def training_count
    0
  end
end
