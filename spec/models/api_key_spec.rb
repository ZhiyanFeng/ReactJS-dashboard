# spec/models/api_key.rb
require "rails_helper"

describe ApiKey do
  it "has a valid factory" do
    FactoryGirl.create(:api_key).should be_valid
  end

  it "is invalid without an app_platform" do
  	FactoryGirl.build(:api_key, app_platform: nil).should_not be_valid
	end

	it "is invalid without an app_version" do
  	FactoryGirl.build(:api_key, app_version: nil).should_not be_valid
	end
end