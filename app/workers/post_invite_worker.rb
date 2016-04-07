class PostInviteWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default"
  # sidekiq_options retry: false
  def perform(referral_id, hour)

    @referral_target = ReferralSend.find(referral_id)
    phone_number = @referral_target[:referral_target_id].gsub(/\W/,'')

    if hour == 1
      #message_1_hour
      content = "Do not miss out! Your coworkers are swapping shifts on the free mobile app Shyft, join your location here https://bnc.lt/SHYFT. Reply STOP to unsubscribe."
    elsif hour == 24
      #message_24_hours
      content = "Have not joined Shyft yet? Your team shift swapping network is heating up, message them here: https://bnc.lt/SHYFT. Reply STOP to unsubscribe."
    elsif hour == 72
      #message_72_hours
      content = "Last chance! Your coworkers are swapping shifts on the free mobile app Shyft, join your location here https://bnc.lt/SHYFT. Reply STOP to unsubscribe."
    else
      return
    end

    if User.exists?(["phone_number like '%#{phone_number}%'"])
      return
    else
      t_sid = 'AC69f03337f35ddba0403beab55af5caf3'
      t_token = '81eaed486465b41042fd32b61e5a1b14'

      @client = Twilio::REST::Client.new t_sid, t_token

      begin
        message = @client.account.messages.create(
          :body => content,
          #:to => phone_number.size > 10 ? "+"+ phone_number : phone_number,
          :to => '4252456668',
          :from => "+16473602178"
        )
      rescue Twilio::REST::RequestError => e
        ErrorLog.create(
          :file => "post_signup_worker.rb",
          :function => "perform",
          :error => "#{e}")
      end
    end

  end
end
