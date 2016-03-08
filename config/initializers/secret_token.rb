# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
#Expresso::Application.config.secret_key_base = 'a90f13634c9ae2e34b92d4323b205216febaebe3efd1b48a288a9bc7484478f589cf3de1428eb0a6b27a97062a0687d758d87802521fa89291ff266b1a6c8bc0'
Expresso::Application.config.secret_token = '8357993fc2fa044864efeb346ca7cbf58aa72a3876b043c42a964f8e63a5d79e248d3276506b678c4fae022d4f5a267490e28bdd7208384688959c661c4491a3'