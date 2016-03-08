require 'unit_spec_helper'

describe 'GCM' do
  let(:app) { Rpush::Gcm::App.new }
  let(:notification) { Rpush::Gcm::Notification.new }
  let(:response) { double(Net::HTTPResponse, code: 200) }
  let(:http) { double(Net::HTTP::Persistent, request: response, shutdown: nil) }

  before do
    app.name = 'test'
    app.auth_key = 'abc123'
    app.save!

    notification.app = app
    notification.registration_ids = ['foo']
    notification.data = { message: 'test' }
    notification.save!

    Rails.stub(root: File.expand_path(File.join(File.dirname(__FILE__), '..', 'tmp')))
    Rpush.config.logger = ::Logger.new(STDOUT)

    Net::HTTP::Persistent.stub(new: http)
  end

  it 'delivers a notification successfully' do
    response.stub(body: JSON.dump({results: [{message_id: notification.registration_ids.first.to_s}]}))

    expect do
      Rpush.push
      notification.reload
    end.to change(notification, :delivered).to(true)
  end

  it 'fails to deliver a notification successfully' do
    response.stub(body: JSON.dump({results: [{error: 'Err'}]}))

    expect do
      Rpush.push
      notification.reload
    end.to_not change(notification, :delivered).to(true)
  end
end
