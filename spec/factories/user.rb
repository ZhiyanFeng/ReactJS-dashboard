# spec/factories/user.rb
require 'faker'

FactoryGirl.define do
	factory :user do |f|
		f.email { Faker::Internet.email }
    f.first_name { Faker::Name.first_name }
    f.last_name { Faker::Name.last_name }
    f.active_org { 1 }
    f.validation_hash { SecureRandom.hex(24) }
    f.phone_number { (Faker::PhoneNumber.cell_phone).gsub(/\W/,'') }
	end
end
