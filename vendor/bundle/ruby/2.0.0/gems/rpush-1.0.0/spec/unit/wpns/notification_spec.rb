require 'unit_spec_helper'
require 'unit/notification_shared.rb'

describe Rpush::Wpns::Notification do
  it_should_behave_like 'an Notification subclass'
  let(:app) { Rpush::Wpns::App.create!(:name => 'test', :auth_key => 'abc') }
  let(:notification_class) { Rpush::Wpns::Notification }
  let(:notification) { notification_class.new }
  let(:data_setter) { 'data=' }
  let(:data_getter) { 'data' }

  it "should have an url in the uri parameter" do
    notification = Rpush::Wpns::Notification.new(:uri => "somthing")
    notification.valid?
    notification.errors[:uri].include?("is invalid").should be_true
  end

  it "should be invalid if there's no message" do
    notification = Rpush::Wpns::Notification.new(:alert => "")
    notification.valid?
    notification.errors[:alert].include?("can't be blank").should be_true
  end
end

describe Rpush::Wpns::Notification, "when assigning the url" do
  it "should be a valid url" do
    notification = Rpush::Wpns::Notification.new(:alert => "abc", :uri => "some")
    notification.uri_is_valid?.should be_false
  end
end
