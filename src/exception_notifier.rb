require_relative 'app_logger'

class ExceptionNotifier
  def self.notify(exception)
    logger = AppLogger.instance.logger
    logger.error(exception.message)
    logger.error(exception.backtrace.join("\n"))
    Sentry.capture_exception(exception) unless ENV['DEVELOPMENT']
  end
end