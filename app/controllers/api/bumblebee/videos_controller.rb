include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Bumblebee
    class VideosController < ApplicationController
      class Video < ::Video
        # Note: this does not take into consideration the create/update actions for changing released_on
    
        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(released_on: created_at.to_date)
        #end
      end
  
      protect_from_forgery :except => [:swfupload, :encode_notify]
  
      def index
      end

      def show
        @video = Video.find(params[:id])
        render json: @video, serializer: VideoSerializer
      end

      def update
        @video = Video.find(params[:id])
        if @video.update!(params[:video])
          render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
        else
          render json: { "eXpresso" => { "code" => -183, "message" => @video.errors } }
        end
      end
  
      # if you're not using swfupload, code like this would be in your create and update methods
      # all you really need to ensure is that after @video.save, you run @video.encode!
      def swfupload
        @video = Video.new(
          :org_id => params[:video][:org_id],
          :owner_id => params[:video][:owner_id]
        )
        @video.video = params[:file]
        # if we're in production, test should be nil but otherwise we're going to want to encode
        # videos using Zencoder's test setting so we're not spending cash to do so
        #RAILS_ENV == "production" ? test = {} : test = {:test => 1}
        test = {}
        if @video.save && @video.encode!(test)
          temp = '{"objects":[{"source":6, "source_id":' + @video.id.to_s + '}]}'
          @attachment = Attachment.new(
            :json => temp
          )
          @attachment.save
          render json: @attachment.id, status: :created 
          #render :json => {:message => "Video was successfully uploaded.  Encoding has commenced automatically."}
        else
          render :json => {:errors => @video.errors.full_messages.to_sentence.capitalize}
        end
      end

      def encode_notify
        # get the job id so we can find the video
        video = Video.find_by_job_id(params[:job][:id].to_s)
        video.capture_notification(params[:output]) if video
        render :text => "Thanks, Zencoder!", :status => 200
      end
    end
  end
end
