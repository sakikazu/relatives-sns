# Be sure to restart your server when you modify this file.

#ADanRails3::Application.config.session_store :cookie_store, :key => '_a-dan_rails3_session'
ADanRails3::Application.config.session_store :active_record_store, :key => '_a-dan_rails3_session', :cookie_only => false

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# ADanRails3::Application.config.session_store :active_record_store
