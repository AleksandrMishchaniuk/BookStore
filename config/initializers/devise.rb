# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.
Devise.setup do |config|
  config.secret_key = '41e745fdc62802bb88325d54c46781d26c96cc8957ae74f9795c33f3be30a21482abb6807394f80e2f00e58af6e42fdd031a17c757ad6a9d23542681b299075f'

  config.mailer_sender = 'service@map.bookstore.com'

  require 'devise/orm/active_record'

  config.case_insensitive_keys = [:email]

  config.strip_whitespace_keys = [:email]

  config.skip_session_storage = [:http_auth]

  config.stretches = Rails.env.test? ? 1 : 11

  config.reconfirmable = true

  config.expire_all_remember_me_on_sign_out = true

  config.password_length = 6..128

  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  config.lock_strategy = :failed_attempts

  config.unlock_strategy = :both

  config.maximum_attempts = 5

  config.unlock_in = 6.hour

  config.last_attempt_warning = true

  config.reset_password_within = 6.hours

  config.sign_out_via = :delete

  config.omniauth :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'],
                      info_fields: 'email, first_name, last_name'

  config.warden do |manager|
    manager.failure_app = CustomFailure
  end
end
