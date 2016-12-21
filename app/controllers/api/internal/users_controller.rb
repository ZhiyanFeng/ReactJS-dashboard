require 'pry'
module Api
    module Internal
        class UsersController < ApplicationController
            class User < ::User
                # Note: this does not take into consideration the create/update actions for changing released_on

                # Sub class to override column name in response
                #def as_json(options = {})
                #  super.merge(released_on: created_at.to_date)
                #end
            end
            respond_to :json 
            def search
                input = params[:user_name].split(' ')
                binding.pry
                if input.length==1 && input[0] =~ /\A\d+\z/ ? true:false
                    @users = User.where("phone_number like ?", "%#{input[0]}%");
                else
                    @users = User.where("lower(first_name) like ? and lower(last_name) like ?","\%#{input[0]}\%","\%#{input[1]}\%")
                end
                render json: @users, each_serializer: UserProfileSerializer
            end
        end
    end
end
