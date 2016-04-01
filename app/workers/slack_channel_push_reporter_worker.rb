class SlackChannelPushReporterWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default"
  # sidekiq_options retry: false
  def perform(report_id)
    begin
      #curl -X POST --data-urlencode 'payload={"channel": "#general", "username": "webhookbot", "text": "This is posted to #general and comes from a bot named webhookbot.", "icon_emoji": ":ghost:"}' https://hooks.slack.com/services/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
      @cpr = ChannelPushReport.find(report_id)
      c = Curl::Easy.new
      c.url = "https://hooks.slack.com/services/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"
      c.verbose = true
      payload = "{\"text\":\"Hello World! #{@cpr[:id]}\",\"icon_emoji\":\":ghost:\"}"
      c.http_post(payload)
    rescue Exception => error
      ErrorLog.create(
        :file => "slack_channel_push_reporter_worker.rb",
        :function => "perform",
        :error => "Unable to report to slack: #{error}")
    end
  end
end
