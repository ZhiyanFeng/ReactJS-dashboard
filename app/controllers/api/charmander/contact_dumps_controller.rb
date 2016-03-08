include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Charmander
    class ContactDumpsController < ApplicationController
      class ContactDump < ::ContactDump
        # Note: this does not take into consideration the create/update actions for changing released_on
        
        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(thumb_url: self.thumb_url, gallery_url: self.gallery_url, full_url: self.full_url)
        #end
      end

      before_filter :restrict_access, :set_headers
      
      respond_to :json

      def process_contact_dump
        #ContactDump.where(:processed => false).find_in_batches(start: 1, batch_size: 500) do |current_batch|
        #@ids = ContactDump.where(:processed => false).pluck(:id)
        #@ids.each do |current|
        #ContactDump.where(:processed => false).find_in_batches(start: 128000, batch_size: 500) do |current_batch|
        ContactDump.where(:processed => false).find_in_batches(batch_size: 500) do |current_batch|
          #current_batch.each {|contact| contact.process}
          #ProcessContactWorker.perform_async(current)
          #return current_batch.count

          current_batch.each {|contact| ProcessContactWorker.perform_async(contact.phone_numbers, contact.user_id, contact.first_name, contact.last_name, contact.emails, contact.social_links)}
          #current_batch.each {|contact| contact.process(contact.phone_numbers, contact.user_id, contact.first_name, contact.last_name, contact.emails, contact.social_links)}
          #current_batch.each {|contact| puts contact.id}
          #puts current_batch.pluck(:id)
        end
        render json: { "eXpresso" => { "code" => 1, "message" => "finished" } }
      end

    end
  end
end