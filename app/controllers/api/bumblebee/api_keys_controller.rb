module Api
  module Bumblebee
    class ApiKeysController < ApplicationController
      
      before_filter :set_headers
      
      respond_to :json

      def create
        @apikey = ApiKey.new(params[:api_key])
        
        respond_to do |format|
          if @apikey.save
            format.html { render json: @apikey, status: 200 }
            format.json { render json: @apikey, status: 200 }
          else
            format.html { render json: @apikey.errors, status: 422 }
            format.json { render json: @apikey.errors, status: 422 }
          end
        end
      end
      
      def create_gcm_service
        app = Rpush::Gcm::App.new
        app.name = "coffee_enterprise"
        app.auth_key = "AIzaSyCl3uqmJB02WAo-2SixxZ9aS8q-hrHQ2Vs"
        app.connections = 1
        app.save

        respond_with "SAVED!"
      end

      def create_apns_service
        app = Rpush::Apns::App.new
        app.name = "coffee_enterprise"
        app.certificate = File.read("ck.pem")
        app.environment = "sandbox"
        app.password = "tt99Z!ZLiP123?"
        app.connections = 1
        app.save
          
        respond_with "SAVED!"
      end
      
    end
  end
end