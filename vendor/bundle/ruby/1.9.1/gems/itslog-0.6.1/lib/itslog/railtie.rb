module Itslog
  class Railtie < Rails::Railtie
    config.before_initialize do
      Itslog::Railtie.insert
      ActiveSupport::LogSubscriber.colorize_logging = false
    end
  end

  class Railtie
    def self.insert
      ActiveSupport::BufferedLogger.send(:include, Itslog::BufferedLoggerExtension)
      ActiveSupport::LogSubscriber.send(:include, Itslog::LogSubscriberExtension)
    end
  end
end
