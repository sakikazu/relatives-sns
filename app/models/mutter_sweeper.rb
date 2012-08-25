# -*- coding: utf-8 -*-
class MutterSweeper < ActionController::Caching::Sweeper
  observe Mutter

  def after_save(record)
    expire_public_page
  end

  def after_destroy(record)
    expire_public_page
  end

  private
  def expire_public_page
    expire_fragment :mutter_by_user
    # expire_fragment :mutter_data
  end
end
