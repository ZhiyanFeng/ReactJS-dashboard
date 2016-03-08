class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  protect_from_forgery except: :index

  helper_method :current_user, :current_organization
      
  def is_equal_to(obj1, obj2)
  	return obj1.to_s == obj2.to_s
  end
      
  def restrict_access
    #X-Method: cc5f43ea7132996963e9a62fabde3c6f
    #Authorization: Token token="cc5f43ea7132996963e9a62fabde3c6f", nonce="def"
    authenticate_or_request_with_http_token do |token, options|
      ApiKey.exists?(access_token: token)
    end
  end
  
  def validate_session
    if !Mession.exists?(["id = ? AND is_active", request.headers['Session-Token']])
      Rails.logger.info "auth_token #{request.headers['Session-Token']}"
      #render json: { "eXpresso" => {"message" => "Session has expired." } }, status: 498
    else
      #Mession.find(request.headers['Session-Token']).touch
      @mession = Mession.find(request.headers['Session-Token'])
      @mession.touch
      if request.headers['Build-Number'].present?
        @mession.update_attribute(:build, request.headers['Build-Number'])
      end
      @user = User.find(@mession[:user_id])
      begin
        @user.update_attribute(:last_seen_at, Time.now)
      rescue Exception => e
        put e
      end
    end
  end
  
  def set_headers
    response.headers["X-LS-License"] = "All Rights Reserved \xC2\xA9 Coffee Enterprise"
    response.headers["X-LS-Application"] = "Coffee Mobile"
    if request.headers['X-Method']
      response.headers["X-Request-Method"] = request.headers['X-Method']
    else
      response.headers["X-Request-Method"] = "none"
    end
  end
  
  def web_access
    if ApiKey.exists?(access_token: params[:token])
      true
    else
      render json: "Bad token"
    end
  end
  
  private

  def current_user
    @current_user ||= User.find(cookies[:user_id]) if cookies[:user_id].presence
  end
  
  def current_organization
    @current_organization ||= Organization.find(cookies[:org_id]) if cookies[:org_id].presence
  end
end


