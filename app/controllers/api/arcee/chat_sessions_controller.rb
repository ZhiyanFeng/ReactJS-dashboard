include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Arcee
    class ChatSessionsController < ApplicationController

      before_filter :restrict_access, :set_headers

      respond_to :json

      def index
        sessions = ChatSession.all
        render json: sessions, each_serializer: ChatSessionSerializer
      end

      def show
        @session =  ChatSession.find(params[:id])
        render :json => @session, serializer: ChatSessionSerializer
      end

      def add_participants
        if params[:participant_ids].present?
          @session = ChatSession.find(params[:id])
          if @session.add_participants(params[:participant_ids])
            render json: @session, serializer: ChatSessionSerializer
          else
            render json: { "eXpresso" => { "code" => -304, "message" => @session.errors } }
          end
        else
          render json: { "eXpresso" => { "code" => -305, "message" => @session.errors } }
        end
      end

      def create
        if params[:participant_count].to_i == 2
          @session = ChatSession.session_exists(
						params[:participants][0][:id],
						params[:participants][1][:id],
						1
					)
					if @session == false
            session = ChatSession.new(params[:chat_session])

						if session.create_session(params[:participants])
						  render json: session, serializer: ChatSessionSerializer
					  end
          else
					  session = ChatSession.find(@session)
            render json: session, serializer: ChatSessionSerializer
            #reactivate user
					  session.reactivate_sender(params[:user_id])
          end
        elsif params[:participant_count].to_i > 2
          session = ChatSession.new(params[:chat_session])
          if session.create_multiuser_session(params[:user_id], params[:participants])
					  render json: session, serializer: ChatSessionSerializer
				  else
				    render json: { "eXpresso" => { "code" => -303, "message" => session.errors } }
				  end
        else
          render json: { "eXpresso" => { "code" => -304, "message" => "participant_count error." } }
        end
      end

      def message
        @session = ChatSession.find(params[:id])
        @chat_message = ChatMessage.new(
          :message => params[:message],
          :session_id => params[:id],
          :sender_id => params[:user_id]
        )

        if @chat_message.send_message
          render json: @chat_message, serializer: ChatMessageSerializer
        else
          render json: { "eXpresso" => { "code" => -303, "message" => @chat_message.errors } }
        end
        #Rpush.push
        #Rpush.apns_feedback
      end

      def messages
        @session =  ChatSession.find(params[:id])
        @chat_participant = ChatParticipant.find_by_session_id_and_user_id(params[:id], params[:user_id])
        if @session[:multiuser_chat]
          if params[:before].presence
            messages = ChatMessage.where("session_id = ? AND id < ? AND id > ? AND is_valid",
              params[:id],
              params[:before],
              @chat_participant[:view_from]
            ).order("created_at asc").last(25)
          elsif params[:since].presence
            #created_at = ChatMessage.find(params[:since]).created_at.to_s
            messages = ChatMessage.where("session_id = ? AND id > ? AND id > ? AND is_valid",
              params[:id],
              params[:since],
              @chat_participant[:view_from]
            ).order("created_at asc").last(25)
          else
            messages = ChatMessage.where("session_id = ? AND id > ? AND is_valid",
              params[:id],
              @chat_participant[:view_from]
            ).order("created_at asc").last(25)
          end
        else
          if params[:before].presence
            messages = ChatMessage.where("session_id = ? AND id < ? AND is_valid",
              params[:id],
              params[:before]
            ).order("created_at asc").last(25)
          elsif params[:since].presence
            #created_at = ChatMessage.find(params[:since]).created_at.to_s
            messages = ChatMessage.where("session_id = ? AND id > ? AND is_valid",
              params[:id],
              params[:since]
            ).order("created_at asc").last(25)
          else
            messages = ChatMessage.where("session_id = ? AND is_valid",
              params[:id]
            ).order("created_at asc").last(25)
          end
        end

        #@messages = ChatMessage.where(:session_id => params[:id])
        @chat_participant.update_attribute(:unread_count, 0)

        render json: messages, each_serializer: ChatMessageSerializer
      end

      def reset_counter
        @chat_participant = ChatParticipant.find_by_session_id_and_user_id(params[:id], params[:user_id])
        @chat_participant.reset_count
      end

      #def update
      #  respond_with ChatSession.update(params[:id], params[:user])
      #end

      def destroy
        if ChatSession.exists?(:id => params[:id])
          @chat_session = ChatSession.find(params[:id])
          if @chat_session.update_attributes(:is_valid => false)
            render json: { "code" => 1 }
          else
            render json: { "code" => -300 }
          end
        else
          render json: { "code" => 0 }
        end
      end
    end
  end
end
