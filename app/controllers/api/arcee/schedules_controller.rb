include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Arcee
    class SchedulesController < ApplicationController
      class Schedule < ::Schedule
        # Note: this does not take into consideration the create/update actions for changing released_on
        
        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(released_on: created_at.to_date)
        #end
      end

      before_filter :set_headers
      
      respond_to :json
      
      def make_schedule
        if web_access
          @post = Post.new(
            :org_id => params[:org_id],
            :owner_id => params[:user_id],
            :title => params[:name],
            :content => "The team manager has posted a new schedule, click below to import it to your calendar.", 
            :post_type => PostType.reference_by_description(params[:reference])
          )
          image = params[:file].presence ? params[:file] : nil
          video = params[:video].presence ? params[:video] : nil
          event = params[:event].presence ? params[:event] : nil
          poll = params[:poll].presence ? params[:poll] : nil
          schedule = params[:schedule].presence ? params[:schedule] : nil
          if @post.save
            @post.compose(image, video, event, poll, schedule)
          end
          redirect_to schedules_path
        else
          redirect_to schedules_path
        end
      end
    end
  end
end