include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Ditto
    class LocationsController < ApplicationController

      before_filter :restrict_access, :set_headers
      before_filter :fetch_location, :except => [:create, :fetch_location_via_swiftcode, :fix_location_swiftcodes]

      respond_to :json

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
