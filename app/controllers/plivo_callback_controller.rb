require 'sinatra'
require 'plivo'
include Plivo

AUTH_ID = "MANTUYNDE1N2ZKOWU4ZT"
AUTH_TOKEN = "ZjMwM2JlM2RjNGFmMjA1MWY2MTI0NGI2ZjE2NTc2"

class PlivoCallbackController < ApplicationController

  #{"To"=>"14152345785", "From"=>"14252456668", "TotalRate"=>"0", "Units"=>"1", "Text"=>"Stil", "TotalAmount"=>"0", "Type"=>"sms", "MessageUUID"=>"92620fd4-cc41-11e5-96a7-22000ae98567"}

  def sms_response
    # Stop words that will cause the number to not send anymore sms to
    @stop_words = ['stop','no','quit','unsubscribe']
    # See 'def process_phone_numbers'
    sanitized_to = process_phone_numbers(params[:To])
    sanitized_from = process_phone_numbers(params[:From])
    # Check to see if the incoming text is equivalent to any stop word, will
    # not match if it is within a sentence or part of a word
    if @stop_words.include?(params[:Text].downcase)
      if SmsStop.exists?(:plivo_number => sanitized_to, :stop_number => sanitized_from)
        # Update the updated_at timestamp to indicate this user was still receiving sms from
        # our number even though they unsubscribed previously.
        SmsStop.where(:plivo_number => sanitized_to, :stop_number => sanitized_from).first.touch
      else
        @new_stop = SmsStop.new(:plivo_number => sanitized_to, :stop_number => sanitized_from)
        if @new_stop.save
          render :nothing => true
        else
          ErrorLog.create(
            :file => "plivo_callback_controller.rb",
            :function => "sms_response",
            :error => "unable to save new sms stop")
          render :nothing => true
        end
      end
    else
      # The user text'd back something other than the stop words
      if params[:Text].downcase.include?('support')
        sms_to_plivo("To contact support, please email support@myshyft.com.",sanitized_from,sanitized_to)
      elsif params[:Text].downcase.include?('help')
        sms_to_plivo("To contact support, please email support@myshyft.com.",sanitized_from,sanitized_to)
      elsif params[:Text].downcase.include?('faq')
        sms_to_plivo("Please visit https://www.myshyft.com/faq to view our most frequently asked questions.",sanitized_from,sanitized_to)
      else
        ErrorLog.create(
          :file => "plivo_callback_controller.rb",
          :function => "sms_response",
          :error => "user text'd back unknown message: '#{params[:Text]}' from number: '#{params[:From]}'")
      end
      render :nothing => true
    end
  end

  private

  # Sanitize phone number to remove brackets, dashes, plus signs from the input
  def process_phone_numbers(number)
    return number.gsub(/[\+\-\(\)\s]/,'')
  end

  def sms_to_plivo(message, to, from)
    p = RestAPI.new(AUTH_ID, AUTH_TOKEN)

    body = {
      'text' => message,
      'src' => from, # Sender's phone number
      'dst' => to, # Receiver's phone Number
      'callbackUrl' => 'http://dev.coffeemobile.com/plivo-callback', # URL that is notified by Plivo when a response is available and to which the response is sent
      'callbackMethod' => 'POST' # The method used to notify the callbackUrl
    }

    response = p.send_message(body)
    print response
  end
end
