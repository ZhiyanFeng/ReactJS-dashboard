# spec/factories/api_key.rb
require "faker"

FactoryGirl.define do
	factory :api_key do |f|
		f.access_token { SecureRandom.hex }
		f.app_platform { Faker::Lorem.word }
		f.app_version { Faker::App.version }
	end
end