include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Ditto
    class LocationsController < ApplicationController

      before_filter :restrict_access, :set_headers
      before_filter :fetch_location, :except => [:create, :fetch_location_via_swiftcode, :fix_location_swiftcodes]

      respond_to :json

      def fetch_location_via_swiftcode
        if Location.exists?(:swift_code => params[:swift_code])
          location = Location.find_by(swift_code: params[:swift_code])
          render json: location, serializer: LocationSerializer
        else
          render json: { "eXpresso" => { "code" => -1, "error" => "A location with that swift code does not exist.", "message" => "A location with that swift code does not exist." } }
        end
      end

      def fix_location_swiftcodes
        locations = Location.all
        locations.each do |location|
          if !location[:swift_code].present?
            location.compile_swift_code
          end
        end
      end

    end
  end
end
