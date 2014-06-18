# 2014-06-17: Version5のためのデータ移行
#
# * PhotoComment: Mutter.create
# * MovieComment: Mutter.create
#
# * BlogComment: Comment.create
# * AlbumComment: Comment.create
# * HistoryComment: Comment.create
#
# * Movie.update_attributes(album_id: my_album.id)
# * Mutter.image?: Photo.create, Mutter.nices ->[copy]-> Photo.nices
#
# note:
# * mutter.rbの、has_attached_fileの設定を有効にしておくこと！
#

logger = Logger.new("log/move_data_to_ver5.error.log")


# todo どこに置けばいいんだろう(ApplicationControllerにおいたものはtaskからは読めず)
def watch_queries
  events = []
  callback = -> name,start,finish,id,payload { events << payload[:sql] }
  ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
    yield
  end
  events
end

namespace :tmp_work do
  desc "data move for version5"
  task :to_ver5 => :environment do
    logger.info "\n\nstart :to_ver5 [#{Time.now()}]"

    queries = watch_queries do
      PhotoComment.all.each do |comment|
        if comment.photo.blank?
          logger.warn "warning: NothingParent #{comment.class.to_s} id: #{comment.id}"
          next
        end

        param = {content: comment.content, user_id: comment.user_id, created_at: comment.created_at, for_sort_at: comment.created_at}
        begin
          created_mutter = comment.photo.create_comment_by_mutter(param)
          logger.debug "success: #{comment.class.to_s} id: #{comment.id} | createdMutter id: #{created_mutter.id}"
        rescue => e
          logger.error "error: #{comment.class.to_s} id: #{comment.id} (#{e.message})"
        end
      end

      MovieComment.all.each do |comment|
        if comment.movie.blank?
          logger.warn "warning: NothingParent #{comment.class.to_s} id: #{comment.id}"
          next
        end

        param = {content: comment.content, user_id: comment.user_id, created_at: comment.created_at, for_sort_at: comment.created_at}
        begin
          created_mutter = comment.movie.create_comment_by_mutter(param)
          logger.debug "success: #{comment.class.to_s} id: #{comment.id} | createdMutter id: #{created_mutter.id}"
        rescue => e
          logger.error "error: #{comment.class.to_s} id: #{comment.id} (#{e.message})"
        end
      end

      BlogComment.all.each do |c|
        begin
          comment = Comment.new(content: c.content, user_id: c.user_id, created_at: c.created_at, parent_id: c.blog_id, parent_type: "Blog")
          # memo これだと、blogデータが存在しない場合は、parent_id, parent_typeがnilになって生成されてしまうので、上記のように直接指定にした
          # comment.parent = c.blog
          comment.save
          logger.debug "success: #{c.class.to_s} id: #{c.id}"
        rescue => e
          logger.error "error: #{c.class.to_s} id: #{c.id} (#{e.message})"
        end
      end

      AlbumComment.all.each do |c|
        begin
          comment = Comment.new(content: c.content, user_id: c.user_id, created_at: c.created_at, parent_id: c.album_id, parent_type: "Album")
          comment.save
          logger.debug "success: #{c.class.to_s} id: #{c.id}"
        rescue => e
          logger.error "error: #{c.class.to_s} id: #{c.id} (#{e.message})"
        end
      end

      HistoryComment.all.each do |c|
        begin
          comment = Comment.new(content: c.content, user_id: c.user_id, created_at: c.created_at, parent_id: c.history_id, parent_type: "History")
          comment.save
          logger.debug "success: #{c.class.to_s} id: #{c.id}"
        rescue => e
          logger.error "error: #{c.class.to_s} id: #{c.id} (#{e.message})"
        end
      end

      # 動画をアルバムに入れる
      Movie.where(album_id: nil).each do |m|
        begin
          current_user = m.user
          Album.create_having_owner(current_user) if current_user.my_album.blank?
          current_user.reload
          m.update_attributes(album_id: current_user.my_album.id)
          logger.debug "success: #{m.class.to_s} id: #{m.id}"
        rescue => e
          logger.error "error: #{m.class.to_s} id: #{m.id} (#{e.message})"
        end
      end

      # 画像持ちのMutterは、Photoモデルを作成して関連付ける
      Mutter.where.not(image_file_name: nil).each do |m|
        begin
          saved_media = m._save_related_media
          next if saved_media.blank?
          m.nices.each do |org_nice|
            nice = Nice.new(org_nice.attributes)
            nice.id = nil
            nice.asset = saved_media
            nice.save
          end
          logger.debug "success: #{m.class.to_s} id: #{m.id}"
        rescue => e
          logger.error "error: #{m.class.to_s} id: #{m.id} (#{e.message})"
        end
      end
    end

    # todo 各メソッドごとに出力するよう共通化したい
    # logger.debug queries.join("\n")
  end
end
