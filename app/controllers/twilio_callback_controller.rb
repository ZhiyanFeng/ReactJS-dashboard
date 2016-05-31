class TwilioCallbackController < ApplicationController

    # create is automatically called when the user calls this controller
	def sms_response

		# create a TwiML message
		twiml = Twilio::TwiML::Response.new do |r|
			r.Message "Hey, I am a robot so I cannot quite understand what you said💁  Want to email me at support@myshyft.com? Thanks! OR Reply STOP"
		end

		#Rails.logger.debug("twiml.text value: #{twiml.text}")

		# send back an XML document in response
		render xml: twiml.text
	end

	def brett_response
		# create a TwiML message
		if params[:Body].downcase == "yes"
			twiml = Twilio::TwiML::Response.new do |r|
				r.Message "Thanks for your support, we will be in touch shortly!"
			end
		else
			twiml = Twilio::TwiML::Response.new do |r|
				r.Message "Hey there, we cannot respond from this line, please email us at support@myshyft.com, thanks!"
			end
		end

		#Rails.logger.debug("twiml.text value: #{twiml.text}")

		# send back an XML document in response
		render xml: twiml.text
	end
end
