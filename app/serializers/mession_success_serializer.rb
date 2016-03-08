class MessionSuccessSerializer < ActiveModel::Serializer
  #has_one :user
  attributes :user, :id, :code, :message, :privilege, :sms_invite_only

  def code
    200
  end

  def message
    "Successful login"
  end

  def sms_invite_only
    false
  end

  def privilege
    #ps = object.user.user_privileges.where(:is_valid => true)
    #UserPrivilegeSerializer.new(object.user.user_privileges.first)
    ps = object.user.user_privileges
    UserPrivilegeSerializer.new(ps.first)
  end

  def user
    UserLoginSerializer.new(object.user)
  end
end
