class ChrisSignupWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default"
  # sidekiq_options retry: false
  def perform(user_id, mession_id)
    if User.exists?(:id => user_id)
      @user = User.find(user_id)
      t_sid = 'AC69f03337f35ddba0403beab55af5caf3'
      t_token = '81eaed486465b41042fd32b61e5a1b14'

      @client = Twilio::REST::Client.new t_sid, t_token

      begin
        message = @client.account.messages.create(
          :body => "Sweet, you're now a valued Shyft-er! Be a part of our community, get access to new features and help us improve Shyft by clicking here: https://www.myshyft.com",
          :to => "+"+@user[:phone_number],
          :from => "+16473602178"
        )
      rescue Twilio::REST::RequestError => e
        ErrorLog.create(
          :file => "post_signup_worker.rb",
          :function => "perform",
          :error => "#{e}")
      end
    else
      ErrorLog.create(
        :file => "post_signup_worker.rb",
        :function => "perform",
        :error => "PostSignupWorker cannot find user with id #{user_id}")
    end

  end
end
