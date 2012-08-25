# -*- coding: utf-8 -*-
class UpdateHistorySweeper < ActionController::Caching::Sweeper
  observe UpdateHistory

  def after_save(record)
    expire_public_page
  end

  def after_destroy(record)
    expire_public_page
  end

  private
  def expire_public_page
    expire_fragment :update_history
  end
end
