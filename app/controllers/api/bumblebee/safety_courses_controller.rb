include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Bumblebee
    class SafetyCoursesController < ApplicationController
      class SafetyCourse < ::SafetyCourse
        # Note: this does not take into consideration the create/update actions for changing released_on
        
        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(released_on: created_at.to_date)
        #end
      end

      before_filter :restrict_access, :except => [:create]
      before_filter :fetch_safety_course, :except => [:index, :create]
      before_filter :set_headers
      
      respond_to :json
      
      def fetch_safety_course
        @safety_course = SafetyCourse.find_by_id(params[:id])
      end

      def index
        @safety_courses = SafetyCourse.all
        render json: @safety_courses, each_serializer: SafetyCourseSerializer
      end

      def create
        @safety_course = SafetyCourse.new(params[:safety_course])
        if @safety_course.save
          render json: @safety_course, serializer: SafetyCourseSerializer
        else
          render json: @safety_course.errors
        end
      end

      def update
        if @safety_course.update_attributes(params[:safety_course])
          render :json => @safety_course, serializer: SafetyCourseSerializer
        else
          render json: @safety_course.errors
        end
      end

      def show
        render json: @safety_course, serializer: SafetyCourseSerializer
      end        
    end
  end
end