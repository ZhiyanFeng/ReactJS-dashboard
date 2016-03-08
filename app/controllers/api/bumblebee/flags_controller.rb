include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Bumblebee
    class FlagsController < ApplicationController
      
      before_filter :restrict_access, :set_headers
      
      respond_to :json

      def index
        respond_with Flag.all
      end

      def show
        respond_with Flag.find(params[:id])
      end

      def create
        @flag = Flag.new(params[:flag])
        
        respond_to do |format|
          if @flag.save
            render :json => { "code" => 1 }
          else
            render :json => { "code" => 0 }
          end
        end
      end

      #def update
      #  respond_with Flag.update(params[:id], params[:user])
      #end

      def destroy
        respond_with Flag.update(params[:id], {:is_valid => false})
      end      
    end
  end
end