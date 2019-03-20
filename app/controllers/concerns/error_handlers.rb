module ErrorHandlers
  extend ActiveSupport::Concern

  included do
    rescue_from Exception, with: :rescue500
    rescue_from ApplicationController::Forbidden, with: :rescue403
    # NOTE: http://totutotu.hatenablog.com/entry/2015/08/05 の方法はベストプラクティスではないみたいなので、RoutingErrorは無視しとこかな
    # rescue_from ActionController::RoutingError, with: :rescue404
    rescue_from ActiveRecord::RecordNotFound, with: :rescue404
  end

  private

  # NOTE: Exceptionをキャッチしているため、exception_notificationが処理されずメールが飛ばない
  # 手動でメールを飛ばすようにする
  def rescue500(e)
    ExceptionNotifier.notify_exception(e)
    error_log(e, false)
    @exception = e
    render 'errors/500', status: 500
  end

  def rescue403(e)
    error_log(e)
    @exception = e
    render 'errors/403', status: 403
  end

  def rescue404(e)
    error_log(e)
    @exception = e
    render 'errors/404', status: 404
  end

  def error_log(e, backtracable = false)
    logger.error '---- ERROR START'
    logger.error "[#{e.class}] #{e.message}"
    logger.error e.backtrace.join('\n') if backtracable
    logger.error '---- ERROR END'
  end
end
