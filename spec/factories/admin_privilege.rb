# spec/factories/admin_privilege.rb
require 'faker'

FactoryGirl.define do
  factory :admin_privilege do |f|
    f.owner_id { Faker::Number.between(1, 1337) }
    f.org_id { Faker::Number.between(1, 1337) }
    f.location_id { Faker::Number.between(1, 1337) }
  end
end