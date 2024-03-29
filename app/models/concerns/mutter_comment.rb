# NOTE: Photo, MovieのコメントをMutterで作成するようにしているが、無理があった
# 理由は、つぶやき機能でアップロードされる写真、動画へのコメントをMutterとして作り、それをさらにアルバムの中でそのまま見たいとうことで、
# コメントをMutterに一元化するというものだったはず。速度面でも、つぶやき一覧ではPhotoやMovieも読み込む必要があり、問題がある。
# TODO: Facebookのタイムラインみたいにするにはどう設計すればいい？Mutterモデルがもっと上のレイヤーになってかぶせる感じかなぁ
module MutterComment
  def create_comment_by_mutter(params)
    # mutterとの関連があれば、そのmutterのchildren（レス）を作成
    if self.mutter.present?
      self.mutter.children.create(params)
    # なければ、関連mutterとして、タイムラインには表示されないmutterを作成し、そのchildrenを作成
    else
      invisible_mutter = Mutter.create_with_invisible(self.user_id)
      self.update(mutter_id: invisible_mutter.id)
      invisible_mutter.children.create(params)
    end

  end

  def has_parent_mutter?
    self.mutter.present?
  end

  # TODO: CommentからMutterに変更する前のコメントデータはどうしてるの？移行してる？
  def mutter_comments
    return [] unless self.has_parent_mutter?
    @comments ||= self.mutter.children.includes({user: :user_ext}).id_asc
  end
end
