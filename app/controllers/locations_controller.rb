class LocationsController < ApplicationController
  http_basic_authenticate_with :name => "theboat", :password => "whosyourdaddy", :except => [:fetch_url_meta, :fetch_location_via_swiftcode]
  layout "scaffold"
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @locations = Locations.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @locations }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @location }
    end
  end

  def search
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def fetch_location_via_swiftcode
    if Location.exists?(:swift_code => params[:swift_code])
      location = Location.find_by(swift_code: params[:swift_code])
      render json: location, serializer: LocationSerializer
    else
      render json: { "eXpresso" => { "code" => -1, "error" => "A location with that swift code does not exist.", "message" => "A location with that swift code does not exist." } }
    end
  end

  def list_search_result
		if request.format == :js
			paramLocation = params[:location_query]
			paramLocation = paramLocation ? paramLocation.strip.downcase : ''
			paramName = params[:name_query]
			paramName = paramName ? paramName.strip.downcase : ''
			if paramLocation.empty?
				@locations = Location.where("lower(location_name) like ?","\%#{paramName}\%")
			elsif paramName.empty?
				@locations = Location.where("lower(address) like ? or lower(city) like ?","\%#{paramLocation}\%","\%#{paramLocation}\%")
			else
				@locations = Location.where("(lower(address) like ? or lower(city) like ?) and lower(location_name) like ?","\%#{paramLocation}\%","\%#{paramLocation}\%","\%#{paramName}\%")
			end
			respond_to do |format|
				format.js {render :partial => "locations/tb_locations.js", content_type: "application/json" }
			end
		else
			@locations = Location.where("lower(address) like ? or lower(city) like ? or lower(location_name) like ?","\%#{params[:location_query]}\%","\%#{params[:location_query]}\%","\%#{params[:location_query]}\%")
			respond_to do |format|
				format.html # index.html.erb
				format.json { render json: @locations }
			end
		end
  end

  def list_members
    @location = Location.find(params[:id])
    @members = UserPrivilege.where("is_valid AND location_id = #{params[:id]}")
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @members }
      format.js {render :partial => "locations/tb_members.js", content_type: "application/json" }
    end
  end

  def make_admin
    @privilege = UserPrivilege.find(params[:member_id])
    @channel = Channel.where(:channel_type => 'location_feed', :channel_frequency => params[:location_id].to_s, :is_valid => true).first
    @subscription = Subscription.where(:user_id => params[:user_id], :channel_id => @channel[:id], :is_valid => true, :is_active => true).first

		if request.format == :js
			if @privilege && @channel && @subscription
				@subscription.update_attribute(:is_admin, true)
				@privilege.update_attribute(:is_admin, true)
				respond_to do |format|
					format.js {render json: {Admin: true}, content_type: "application/json" }
				end
			else
				respond_to do |format|
					format.js {render json: {Error: @user.errors}, content_type: "application/json", :status => 500 }
				end
			end
		else
			if @privilege && @channel && @subscription
				@subscription.update_attribute(:is_admin, true)
				@privilege.update_attribute(:is_admin, true)
				redirect_to "/locations/list_members/#{params[:location_id]}"
			else
				redirect_to "/locations/list_members/#{params[:location_id]}"
			end
		end
  end

  # GET /users/new
  def new
    @location = Location.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @location = Location.new(user_params)

    respond_to do |format|
      if @location.save
        format.html { redirect_to @location, notice: 'Location was successfully created.' }
        format.json { render json: @location, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @location.update(user_params)
        format.html { redirect_to @location, notice: 'Location was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @location.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @location = Location.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params[:user]
  end
end
