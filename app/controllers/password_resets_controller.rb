class PasswordResetsController < ApplicationController
  layout 'sessions'
  def new
  end
  
  def create
    if user = User.find_by_email(params[:email])
      user.send_password_reset if user
      redirect_to password_resets_sent_path
    else
      render "password_resets/sent"
    end
  end

  def edit
    if User.exists?(:password_reset_token => params[:id])
      @user = User.find_by_password_reset_token!(params[:id])
      if @user.password_reset_sent_at < 2.hours.ago
        redirect_to password_resets_expired_path
      else
        redirect_to password_resets_complete_path        
      end
    else
      redirect_to root_url
    end
  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.password_reset_sent_at < 2.hours.ago
      redirect_to password_resets_expired_path
    elsif @user.change_password(params[:password])
      @user.update_attribute(:password_reset_sent_at, Time.now - 2.hours)
      #redirect_to password_resets_complete_path
      render json: { "eXpresso" => { "code" => 1, "message" => "success" } }
    else
      render :edit
    end
  end
  
  def reset_password
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.password_reset_sent_at < 2.hours.ago
      redirect_to password_resets_expired_path
    else
      render :edit
    end
  end
  
  def complete
  end
  
  def expired
  end
end
