include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Arcee
    class AudiosController < ApplicationController
      class Audio < ::Audio
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
        @audio = Audio.find(params[:id])
        render :json => @audio.url
      end

      def new
      end
  
      # if you're not using swfupload, code like this would be in your create and update methods
      # all you really need to ensure is that after @audio.save, you run @audio.encode!
      def swfupload
        @audio = Audio.new(params[:audio])
        @audio.audio = params[:file]
        # if we're in production, test should be nil but otherwise we're going to want to encode
        # audios using Zencoder's test setting so we're not spending cash to do so
        #RAILS_ENV == "production" ? test = {} : test = {:test => 1}
        if @audio.save
          render :json => {:message => "Audio was successfully uploaded.  Encoding has commenced automatically."}
        else
          render :json => {:errors => @audio.errors.full_messages.to_sentence.capitalize}
        end
      end

      def encode_notify
        # get the job id so we can find the audio
        audio = Audio.find_by_job_id(params[:job][:id].to_i)
        audio.capture_notification(params[:output]) if audio
        render :text => "Thanks, Zencoder!", :status => 200
      end
    end
  end
end
