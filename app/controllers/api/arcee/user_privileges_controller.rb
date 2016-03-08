include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Arcee
    class UserPrivilegesController < ApplicationController
      class UserPrivilege < ::UserPrivilege
        # Note: this does not take into consideration the create/update actions for changing released_on
        
        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(thumb_url: self.thumb_url, gallery_url: self.gallery_url, full_url: self.full_url)
        #end
      end

      before_filter :restrict_access, :set_headers
      
      respond_to :json

      def create
        @userprivilege = UserPrivilege.new(
          :org_id => params[:org_id],
          :owner_id => params[:owner_id]
        )
        respond_to do |format|  
          if @userprivilege.save_and_setup(params[:org_id])
            format.html { render json: @userprivilege, serializer: UserPrivilegeSerializer }
            format.json { render json: @userprivilege, serializer: UserPrivilegeSerializer }
          else
            format.html { render json: @userprivilege.errors }
            format.json { render json: @userprivilege.errors }
          end
        end
      end

      def grant_access
        if UserPrivilege.exists?(:id => params[:id])
          @userprivilege = UserPrivilege.find(params[:id])
          if @userprivilege.update_attribute(:is_approved => true)
            render :json => @userprivilege, serializer: UserPrivilegeSerializer
          else
            render :json => @userprivilege.errors
          end
        end
      end

      def revoke_access
        if UserPrivilege.exists?(:id => params[:id])
          @userprivilege = UserPrivilege.find(params[:id])
          if @userprivilege.revoke_access
            render :json => @userprivilege, serializer: UserPrivilegeSerializer
          else
            render :json => @userprivilege.errors
          end
        end
      end

      def destroy
        @userprivilege = UserPrivilege.find(params[:id])
        if @userprivilege.update_attribute(:is_valid => false)
          render :json => @userprivilege, serializer: UserPrivilegeSerializer
        else
          render :json => @userprivilege.errors
        end
      end

      private

      def restrict_access
        #X-Method: cc5f43ea7132996963e9a62fabde3c6f
        #Authorization: Token token="cc5f43ea7132996963e9a62fabde3c6f", nonce="def"
        authenticate_or_request_with_http_token do |token, options|
          ApiKey.exists?(access_token: token)
        end
      end

    end
  end
end