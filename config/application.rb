require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ShopApp
  class Application < Rails::Application

    config.load_defaults 8.0

    config.autoload_lib(ignore: %w[assets tasks])

    # ✅ Set timezone to IST
    config.time_zone = 'Asia/Kolkata'
    config.active_record.default_timezone = :local
   
  end
end
