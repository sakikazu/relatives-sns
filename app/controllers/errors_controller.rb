class ErrorsController < ActionController::Base
  def show
    error = request.env["action_dispatch.exception"]
    error_log(error, false)

    case error
    when ActionController::RoutingError, ActiveRecord::RecordNotFound
      render_error(status: 404, template: "errors/404", message: "404 Not Found")
    when ApplicationController::Forbidden
      render_error(status: 403, template: "errors/403", message: "403 Forbidden")
    when StandardError
      render_error(status: 500, template: "errors/500", message: "500 Internal Server Error")
    end
  end

  private

  # リクエスト形式ごとに例外ページの返し方を切り替える
  def render_error(status:, template:, message:)
    if request.format.json?
      render json: { error: message }, status: status
    elsif request.format.html?
      render template: template, status: status, layout: "application", formats: [:html]
    else
      render plain: message, status: status
    end
  end

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
