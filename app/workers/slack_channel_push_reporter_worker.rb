class SlackChannelPushReporterWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default"
  # sidekiq_options retry: false
  def perform(report_id)
    begin
      #curl -X POST --data-urlencode 'payload={"channel": "#general", "username": "webhookbot", "text": "This is posted to #general and comes from a bot named webhookbot.", "icon_emoji": ":ghost:"}' https://hooks.slack.com/services/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
      @cpr = ChannelPushReport.find(report_id)
      notifier = Slack::Notifier.new "https://hooks.slack.com/services/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"
      notifier.ping "Hello World! #{report_id}."
    rescue Exception => error
      ErrorLog.create(
        :file => "slack_channel_push_reporter_worker.rb",
        :function => "perform",
        :error => "Unable to report to slack: #{error}")
    end
  end
end
