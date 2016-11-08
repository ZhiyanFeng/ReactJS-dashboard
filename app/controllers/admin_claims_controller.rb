class AdminClaimsController < ApplicationController
  http_basic_authenticate_with :name => "theboat", :password => "whosyourdaddy", :except => [:fetch_url_meta]
  layout "scaffold"
  before_action :set_admin_claim, only: [:show, :edit, :update, :destroy]

  # GET /admin_claims
  # GET /admin_claims.json
  def index
    @admin_claims = AdminClaim.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @admin_claims }
    end
  end

  # GET /admin_claims/1
  # GET /admin_claims/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @admin_claim }
    end
  end

  def display
    @admin_claim = AdminClaim.find(params[:claim_id])
    @user = User.find(@admin_claim[:user_id])
    if @admin_claim[:ref_type] == 1
      @channel = Channel.find(@admin_claim[:ref_id])
    end

    render "show.html"
  end



  def list_by_name
    name = params[:admin_claim_name].split(' ')
    @admin_claims = AdminClaim.where("lower(first_name) like ? and lower(last_name) like ?","\%#{name[0]}\%","\%#{name[1]}\%")
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @admin_claims }
      format.js {render :partial => "admin_claims/tb_admin_claims.js", content_type: "application/json" }
    end
  end

  # GET /admin_claims/new
  def new
    @admin_claim = AdminClaim.new
  end

  # GET /admin_claims/1/edit
  def edit
  end

  # POST /admin_claims
  # POST /admin_claims.json
  def create
    @admin_claim = AdminClaim.new(admin_claim_params)

    respond_to do |format|
      if @admin_claim.save
        format.html { redirect_to @admin_claim, notice: 'AdminClaim was successfully created.' }
        format.json { render json: @admin_claim, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @admin_claim.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin_claims/1
  # PATCH/PUT /admin_claims/1.json
  def update
    respond_to do |format|
      if @admin_claim.update(admin_claim_params)
        format.html { redirect_to @admin_claim, notice: 'AdminClaim was successfully updated.' }
        format.json { head :no_content }
        format.js {render json: {Updated: true}, content_type: "application/json" }
      else
        format.html { render action: 'edit' }
        format.json { render json: @admin_claim.errors, status: :unprocessable_entity }
        format.js {render json: {Error: @admin_claim.errors}, content_type: "application/json", :status => 500 }
      end
    end
  end

  # DELETE /admin_claims/1
  # DELETE /admin_claims/1.json
  def destroy
    @admin_claim.destroy
    respond_to do |format|
      format.html { redirect_to admin_claims_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_admin_claim
    @admin_claim = AdminClaim.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def admin_claim_params
    params[:admin_claim]
  end
end
