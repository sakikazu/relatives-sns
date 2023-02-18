require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Adan4
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.i18n.default_locale = :ja
    config.time_zone = 'Asia/Tokyo'

    # エラーページにlayoutを適用させたいため
    # see. https://qiita.com/mr-myself/items/c2f4fb2e5dcee6a336f3#comment-23298b703d75b7d27487
    config.exceptions_app = ->(env) { ErrorsController.action(:show).call(env) }
  end
end
