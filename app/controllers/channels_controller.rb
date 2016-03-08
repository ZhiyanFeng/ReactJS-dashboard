class ChannelsController < ApplicationController
  http_basic_authenticate_with :name => "theboat", :password => "whosyourdaddy", :except => [:fetch_url_meta, :activate_admin]
  layout "scaffold"
  before_action :set_channel, only: [:show, :edit, :update, :destroy]

  # GET /channels
  # GET /channels.json
  def index
    @channels = Channel.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @channels }
    end
  end

  def activate_admin
    if AdminClaim.exists?(:activation_code => params[:id])
      @claim = AdminClaim.find_by_activation_code(params[:id])
      if @claim.created_at < 72.hours.ago
        render "static_pages/admin_claim_expired", :layout => false
      else
        if Subscription.exists?(:channel_id => @claim[:ref_id],:user_id => @claim[:user_id],:is_active => true, :is_valid => true)
          @subscription = Subscription.where(:channel_id => @claim[:ref_id],:user_id => @claim[:user_id],:is_active => true, :is_valid => true).first
          @subscription.update_attribute(:is_admin, true)
          @user = User.find(@claim[:user_id])
          @user.update_attribute(:email,@claim[:email])
          NotificationsMailer.admin_claim_success_email(@user[:first_name],@claim[:email])
          render "static_pages/admin_claim_success", :layout => false
        else
          render "static_pages/something_is_wrong", :layout => false
        end
      end
    else
      render "static_pages/something_is_wrong", :layout => false
    end
  end

  # GET /channels/1
  # GET /channels/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @channel }
    end
  end

  # GET /channels/new
  def new
    @channel = Channel.new
  end

  # GET /channels/1/edit
  def edit
  end

  # POST /channels
  # POST /channels.json
  def create
    @channel = Channel.new(channel_params)

    respond_to do |format|
      if @channel.save
        format.html { redirect_to @channel, notice: 'Channel was successfully created.' }
        format.json { render json: @channel, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /channels/1
  # PATCH/PUT /channels/1.json
  def update
    respond_to do |format|
      if @channel.update(channel_params)
        format.html { redirect_to @channel, notice: 'Channel was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /channels/1
  # DELETE /channels/1.json
  def destroy
    @channel.destroy
    respond_to do |format|
      format.html { redirect_to channels_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_channel
    @channel = Channel.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def channel_params
    params[:channel]
  end
end
