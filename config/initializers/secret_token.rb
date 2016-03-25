# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
#Expresso::Application.config.secret_token = ENV['SECRET_TOKEN']
#Expresso::Application.config.secret_key_base = ENV['SECRET_KEY_BASE']

Expresso::Application.config.secret_token = "55e05e386c87d1a0d961a8b6e166b8f02df7224670ae83e18b41c8506577662a091b532f936dd2d6dedae31e51c3554eb5f75b06583b96db48e30ffac379aaee"
Expresso::Application.config.secret_key_base = "9be32248693cf35d3a5fb6faf76ad76d602491efb1b82ec491fca750ba069fadeaf4de429ca3fedea116d71031e4484050e5488ff613c435b75deb25f6650190"
