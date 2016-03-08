if Rails.env.production?
  ENV['ASSET_ROOT'] = "https://s3.amazonaws.com/coffeemobileassets/"
elsif Rails.env.staging?
  ENV['ASSET_ROOT'] = "https://s3.amazonaws.com/coffeemobileassets/"
elsif Rails.env.testing?
  ENV['ASSET_ROOT'] = "http://localhost:3000/assets/admin/"
elsif Rails.env.dev?
  ENV['ASSET_ROOT'] = "http://localhost:3000/assets/admin/"
else
  ENV['ASSET_ROOT'] = "http://localhost:3000/assets/admin/"
end