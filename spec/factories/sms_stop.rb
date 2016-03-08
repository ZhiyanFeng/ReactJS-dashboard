# spec/factories/sms_stop.rb
require 'faker'

FactoryGirl.define do
  factory :sms_stop do |f|
    f.plivo_number { Faker::PhoneNumber.phone_number }
    f.stop_number { Faker::PhoneNumber.cell_phone }
  end
end