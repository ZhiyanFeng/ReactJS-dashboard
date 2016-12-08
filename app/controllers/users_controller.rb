class UsersController < ApplicationController
  http_basic_authenticate_with :name => "theboat", :password => "whosyourdaddy", :except => [:fetch_url_meta]
  layout "scaffold"
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  
  def search
    respond_to do |format|
      format.html # search.html.erb
    end
  end

  def list_by_name
    input = params[:user_name].split(' ')
    if input.length==1 && input[0] =~ /\A\d+\z/ ? true:false
        @users = User.where("phone_number like ?", "%#{input[0]}%");
    else
        @users = User.where("lower(first_name) like ? and lower(last_name) like ?","\%#{input[0]}\%","\%#{input[1]}\%")
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
      format.js {render :partial => "users/tb_users.js", content_type: "application/json" }
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # Make user invalid
  def delete
      @user = User.find(params[:id])
      @user.is_valid='false'
      @user.save
      @privileges = UserPrivilege.where("owner_id= ?",params[:id])
      @privileges.each do |p|
        p.update_attribute(:is_valid,"false")
      end
      @subscriptions = Subscription.where("user_id= ?",params[:id])
      @subscriptions.each do |s|
          s.update_attribute(:is_valid, "false")
      end
      @chat_participants = ChatParticipant.where("user_id= ?",params[:id])
      @chat_participants.each do |c|
          c.update_attribute(:is_valid, "false")
      end
                                          
      redirect_to '/user_search', :notice => "The user #{@user.first_name} has been deleted."
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
				format.js {render json: {Updated: true}, content_type: "application/json" }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
				format.js {render json: {Error: @user.errors}, content_type: "application/json", :status => 500 }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params[:user]
  end
end
