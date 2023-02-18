class ErrorsController < ActionController::Base
  def show
    error = request.env["action_dispatch.exception"]
    error_log(error, false)

    case error
    when ActionController::RoutingError, ActiveRecord::RecordNotFound
      render template: "errors/404", status: 404, layout: 'application'
    when ApplicationController::Forbidden
      render template: "errors/403", status: 403, layout: 'application'
    when StandardError
      render template: "errors/500", status: 500, layout: 'application'
    end
  end

  private

  def error_log(e, backtracable = false)
    prefix = '--- ERROR'
    logger.error "\n#{prefix} START"
    logger.error "#{prefix} [#{e.class}] #{e.message}"
    if backtracable
      logger.error "#{prefix} stack trace ---"
      logger.error e.backtrace.join("\n")
    end
    logger.error "#{prefix} END\n"
  end
end
