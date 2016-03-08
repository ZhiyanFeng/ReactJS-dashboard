include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Arcee
    class BasesController < ApplicationController
      
      before_filter :restrict_access, :set_headers
      
      respond_to :json

      def index
        respond_with Base.all
      end

      def show
        respond_with Base.find(params[:id])
      end

      def create
        @base = Base.new(params[:base])
        
        respond_to do |format|
          if @base.save
            format.html { render json: @base, status: 200 }
            format.json { render json: @base, status: 200 }
          else
            format.html { render json: @base.errors, status: 422 }
            format.json { render json: @base.errors, status: 422 }
          end
        end
      end

      #def update
      #  respond_with Base.update(params[:id], params[:user])
      #end

      def destroy
        respond_with Base.update(params[:id], {:is_valid => false})
      end      
    end
  end
end