class OrganizationsController < ApplicationController
  layout 'organizations'
	respond_to :html, :json, :xml

	before_filter :fetch_organization, :except => [:index, :create]

	def fetch_organization
		@organization = Organization.find_by_id(params[:id])
	end

	def new
		@organization = Organization.new
	end

	def create
		@organization = Organization.new(params[:organization])
		if @organization.save
			redirect_to login_path, :notice => "Signed up!"
		else
			render "new"
		end
	end

	def update
		respond_to do |format|
			if @organization.update_attributes(params[:organization])
				format.html { head :no_content, status: :ok }
				format.json { head :no_content, status: :ok }
				format.xml { head :no_content, status: :ok }
			else
				format.html { render json: @organization.errors, status: :unprocessable_entity }
				format.json { render json: @organization.errors, status: :unprocessable_entity }
				format.xml { render xml: @organization.errors, status: :unprocessable_entity }
			end
		end
	end

	def show
		respond_to do |format|
			format.html
			format.json { render json: @organization }
			format.xml { render xml: @organization }
		end
	end
end
