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

      #phone_number = @user[:phone_number].gsub(/[\+\-\(\)\s]/,'')
      phone_number = @user[:phone_number].gsub(/\W/,'')
      begin
        message = @client.account.messages.create(
          :body => "Thanks for using Shyft! Are you about that #ShyftLife? Signup here to get early access to new features and dedicated support! bit.ly/ShyftLife",
          #:to => "+"+@user[:phone_number],
          :to => phone_number.size > 10 ? "+"+ phone_number : phone_number,
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
