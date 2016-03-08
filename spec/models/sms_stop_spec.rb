# spec/models/sms_stop.rb
require "rails_helper"

describe SmsStop do
  it "has a valid factory" do
    FactoryGirl.create(:sms_stop).should be_valid
  end

  it "is invalid without a plivo_number" do
  	FactoryGirl.build(:sms_stop, plivo_number: nil).should_not be_valid
	end

  it "is invalid without a stop_number" do
  	FactoryGirl.build(:sms_stop, stop_number: nil).should_not be_valid
	end

  it "does not allow duplicate stop_number for the same plivo_number" do
  	sms_stop = FactoryGirl.create(:sms_stop)
	  FactoryGirl.build(:sms_stop, plivo_number: sms_stop[:plivo_number], stop_number: sms_stop[:stop_number]).should_not be_valid
  end

  it "should allow duplicate stop_number for different plivo_number" do
  	sms_stop = FactoryGirl.create(:sms_stop)
	  FactoryGirl.build(:sms_stop, plivo_number: Faker::PhoneNumber.phone_number, stop_number: sms_stop[:stop_number]).should be_valid
  end
end