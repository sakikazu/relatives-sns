module Utility
  def create_comment_by_mutter(params, user_id)
    # mutterとの関連があれば、そのmutterのchildren（レス）を作成
    if self.mutter.present?
      self.mutter.children.create(params)
    # なければ、関連mutterとして、タイムラインには表示されないmutterを作成し、そのchildrenを作成
    else
      invisible_mutter = Mutter.create_with_invisible(user_id)
      self.update_attributes(mutter_id: invisible_mutter.id)
      invisible_mutter.children.create(params)
    end

  end

  def has_parent_mutter?
    self.mutter.present?
  end

  def mutter_comments
    return [] unless self.has_parent_mutter?
    self.mutter.children.includes({user: :user_ext}).reorder("id ASC")
  end
end
