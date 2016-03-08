include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Bumblebee
    class CommentsController < ApplicationController
      class Comment < ::Comment
        # Note: this does not take into consideration the create/update actions for changing released_on
        
        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(thumb_url: self.thumb_url, gallery_url: self.gallery_url, full_url: self.full_url)
        #end
      end

      before_filter :restrict_access, :set_headers
      
      respond_to :json

      def like
        comment = Comment.find(params[:id])
        comment_object = nil
        comment_source = Source.name_from_id(comment[:source])
        comment_object = Post.find(comment[:source_id]) if comment_source == "post"
        comment_object = Image.find(comment[:source_id]) if comment_source == "image"
        @like = Like.new(
          :owner_id => params[:user_id],
          :source => Source.id_from_name("comment"),
          :source_id => params[:id]
        )
        @like.create_like(comment_source, comment_object)
        
        #Mession.broadcast(post[:org_id], "refresh", "notification", 4, post[:id], params[:user_id], post[:owner_id])
        render json: @like, serializer: LikeSerializer
      end
      
      def unlike
        comment = Comment.find(params[:id])
        if Like.exists?(:owner_id => params[:user_id], :source => 5, :source_id => params[:id], :is_valid => true)
          @like = Like.where(:owner_id => params[:user_id], :source => 5, :source_id => params[:id], :is_valid => true).last
          @like.destroy_like
          
          render json: @like, serializer: LikeSerializer
        else
          render :json => { "code" => 0 }
        end
      end
      
      def flag
        comment = Comment.find(params[:id])
        @flag = Flag.new(
          :owner_id => params[:user_id],
          :source => Source.id_from_name("comment"),
          :source_id => params[:id]
        )
        @flag.create_flag(params[:id])
        
        render json: @flag, serializer: FlagSerializer
      end
      
      def destroy
        if Comment.exists?(:id => params[:id])
          @comment = Comment.find(params[:id])
          if @comment.destroy_comment
            render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
          else
            render json: { "eXpresso" => { "code" => -501, "message" => @comment.errors } }
          end
        end
      end
      

      private

      def restrict_access
        #X-Method: cc5f43ea7132996963e9a62fabde3c6f
        #Authorization: Token token="cc5f43ea7132996963e9a62fabde3c6f", nonce="def"
        authenticate_or_request_with_http_token do |token, options|
          ApiKey.exists?(access_token: token)
        end
      end
    end
  end
end