include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Charmander
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

      def change_title
        if ChatSession.exists?(:id => params[:id])
          @session = ChatSession.find(params[:id])
          @session.update_attribute(:title, params[:title])
          render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "Sorry, your action could not be completed at this time.", "error" => "Cannot find chat session with id #{params[:id]}" } }
        end
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
            session = ChatSession.new(:participant_count => params[:chat_session][:participant_count], :org_id => 1)

						if session.create_session(params[:participants])
              @user = User.find(params[:participants][0][:id])
              @user.update_attributes(:shyft_score => @user[:shyft_score] + 2)
						  render json: session, serializer: ChatSessionSerializer
            else
              render json: { "eXpresso" => { "code" => -1, "message" => session.errors } }
					  end
          else
					  session = ChatSession.find(@session)
            session.update_attributes(:is_valid => true, :is_active => true)
            render json: session, serializer: ChatSessionSerializer
            #reactivate user
					  session.reactivate_sender(params[:user_id])
          end
        elsif params[:participant_count].to_i > 2
          session = ChatSession.new(:participant_count => params[:chat_session][:participant_count], :org_id => 1)
          if session.create_multiuser_session(params[:user_id], params[:participants])
            @user = User.find(params[:participants][0][:id])
            @user.update_attributes(:shyft_score => @user[:shyft_score] + 2)
					  render json: session, serializer: ChatSessionSerializer
				  else
				    render json: { "eXpresso" => { "code" => -303, "message" => session.errors } }
				  end
        else

        end
      end

      def message
        @session = ChatSession.find(params[:id])
        @chat_message = ChatMessage.new(
          :message => params[:message],
          :session_id => params[:id],
          :sender_id => params[:user_id],
          :message_type => params[:message_type].present? ? params[:message_type] : 0
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
        if ChatSession.exists?(params[:id])
          @session =  ChatSession.find(params[:id])
          if ChatParticipant.exists?(:session_id => params[:id], :user_id => params[:user_id])
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
            end

            is_outdated = false
            if Mession.exists?(:user_id => params[:user_id], :is_active => true)
              @mession = Mession.where(:user_id => params[:user_id], :is_active => true).first
              if @mession[:build].present?
                if @mession[:push_to] == "APNS"
                  if @mession[:build].to_i < 15091402
                    is_outdated = true
                  end
                elsif @mession[:push_to] == "GCM"
                  if @mession[:build].to_i < 15092100
                    is_outdated = true
                  end
                else
                end
              end
            else
              ErrorLog.create(
                :file => "chat_sessions_controller.rb",
                :function => "messages",
                :error => "Should not be able to get here without a session.")
            end

            #@messages = ChatMessage.where(:session_id => params[:id])
            @chat_participant.update_attribute(:unread_count, 0)

            render json: messages, each_serializer: ChatMessageSerializer, outdated: is_outdated
          else
            render json: { "eXpresso" => { "code" => -1, "message" => "You do not have access to this chat session.", "error" => "Could not find chat participant for session with ID #{params[:id]} for user #{params[:user_id]}." } }
          end
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "The chat session you are looking for does not exists.", "error" => "Could not find chat session with ID #{params[:id]}." } }
        end
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

      def archive
        if ChatSession.exists?(:id => params[:id], :is_active => true, :is_valid => true)
          if ChatParticipant.exists?(:session_id => params[:id], :user_id => params[:user_id])
            @participant = ChatParticipant.where(:session_id => params[:id], :user_id => params[:user_id]).first
            if @participant[:is_valid]
              if @participant[:is_active]
                if @participant.update_attributes(:is_active => false)
                  render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
                else
                  render json: { "eXpresso" => { "code" => -1, "message" => "The chat participant failed to update.", "error" => "ChatParticipant with ID #{@participant[:id]} failed to update." } }
                end
              else
                render json: { "eXpresso" => { "code" => -1, "message" => "The chat participant is not active.", "error" => "ChatParticipant with ID #{@participant[:id]} is already inactive." } }
              end
            else
              render json: { "eXpresso" => { "code" => -1, "message" => "The chat participant is deleted.", "error" => "ChatParticipant with ID #{@participant[:id]} is already deleted." } }
            end
          else
            render json: { "eXpresso" => { "code" => -1, "message" => "The chat participant does not exist.", "error" => "ChatSession with ID #{params[:id]}." } }
          end
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "The chat session either got delete or does not exist.", "error" => "ChatSession with ID #{params[:id]}." } }
        end
      end

      def delete
        if ChatSession.exists?(:id => params[:id], :is_active => true, :is_valid => true)
          if ChatParticipant.exists?(:session_id => params[:id], :user_id => params[:user_id])
            @participant = ChatParticipant.where(:session_id => params[:id], :user_id => params[:user_id]).first
            if @participant[:is_valid]
              if @participant[:is_active]
                last_message_id = ChatMessage.where(:session_id => params[:id]).order(created_at: :desc).pluck(:id).first
                if @participant.update_attributes(:is_active => false, :is_valid => false, :view_from => last_message_id)
                  render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
                else
                  render json: { "eXpresso" => { "code" => -1, "message" => "The chat participant failed to update.", "error" => "ChatParticipant with ID #{@participant[:id]} failed to update." } }
                end
              else
                render json: { "eXpresso" => { "code" => -1, "message" => "The chat participant is not active.", "error" => "ChatParticipant with ID #{@participant[:id]} is already inactive." } }
              end
            else
              render json: { "eXpresso" => { "code" => -1, "message" => "The chat participant is deleted.", "error" => "ChatParticipant with ID #{@participant[:id]} is already deleted." } }
            end
          else
            render json: { "eXpresso" => { "code" => -1, "message" => "The chat participant does not exist.", "error" => "ChatSession with ID #{params[:id]}." } }
          end
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "The chat session either got delete or does not exist.", "error" => "ChatSession with ID #{params[:id]}." } }
        end
      end


    end
  end
end
