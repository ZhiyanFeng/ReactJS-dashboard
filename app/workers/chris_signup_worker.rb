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
          :body => "Thanks for signing up with Shyft! Be a part of our team with ShyftLyfe and get early access to new features! Sign up here: http://bit.ly/ShyftLyfe",
          :to => "+"+@user[:phone_number],
          :from => "+16473602178"
        )
      rescue Twilio::REST::RequestError => e
        ErrorLog.create(
          :file => "chris_signup_worker.rb",
          :function => "perform",
          :error => "#{e}")
      end
    else
      ErrorLog.create(
        :file => "chris_signup_worker.rb",
        :function => "perform",
        :error => "ChrisSignupWorker cannot find user with id #{user_id}")
    end

  end
end