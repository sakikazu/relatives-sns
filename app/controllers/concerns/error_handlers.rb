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

  def rescue500(e)
    @exception = e
    render 'errors/500', status: 500
  end

  def rescue403(e)
    @exception = e
    render 'errors/403', status: 403
  end

  def rescue404(e)
    @exception = e
    render 'errors/404', status: 404
  end
end
