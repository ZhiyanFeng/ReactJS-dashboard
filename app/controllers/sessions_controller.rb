class SessionsController < ApplicationController
	#layout 'organizations'
  #layout 'sessions'
  def new
  	if cookies[:user_id].present? && cookies[:org_id].present? && cookies[:api_key].present?
  		redirect_to select_url
  	else
  	end
  end
  
  def create
    @user = User.where("lower(email) = ? AND is_valid", params[:email].downcase).first

    if @user.nil?
  		flash[:notice] = "The login information you entered does not match any record in our system."
			redirect_to login_url
    else
    	@status = @user.authenticate(params[:password])
    	#Rails.logger.debug(@status)
    	if @status == 401
    		flash[:notice] = "The login information you entered does not match any record in our system."
    		redirect_to login_url
			elsif @status == 200
		    current_user = @user
        key = UserPrivilege.where(:owner_id => @user[:id], :org_id => @user[:active_org], :is_valid => true).first
		    	#@keychain = "hello"
				cookies[:user_id] = @user[:id]
				cookies[:chat_handle] = @user[:chat_handle]
        cookies[:is_admin] = key[:is_admin]
        cookies[:is_root] = key[:is_root]
        cookies[:user_location_id] = @user[:location]
				#cookies[:logged_in] = true
				#cookies[:last_seen] = Time.now
				#cookies[:expires_at] = Time.now + 60.minute
				#cookies[:organization] = Time.now
				#flash[:notice] = "Welcome back " + params[:login] + "!"
				redirect_to select_url

			elsif @status == 209
			  redirect_to resend_url
			elsif @status == 210
			  flash[:notice] = "Your account does not belong to any network at this moment, login on the mobile app and apply to one first."
			  redirect_to login_url
			elsif @status == 211
			  flash[:notice] = "Your account has been deactivated by your network's administrators. If you feel this is done by mistake, please contact the administrators for assistance."
			  redirect_to login_url
		  else
			  flash[:notice] = "You do not have admin access to this account, please try logging in on the mobile app."
			  redirect_to login_url
	    end
	  end
  end
  
  def destroy
    @apikey = ApiKey.find_by_access_token(cookies[:api_key])
    @apikey.delete

    cookies.delete(:chat_handle)
    cookies.delete(:user_id)
    cookies.delete(:org_id)
    cookies.delete(:api_key)
    cookies.delete(:is_admin)
    cookies.delete(:is_root)
    cookies.delete(:user_location_id)
    
    flash[:success] = "Thank you for using Coffee Enterprise."
    redirect_to login_url
  end
end
