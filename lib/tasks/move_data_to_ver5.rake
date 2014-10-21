# 2014-06-21:
#
# * MutterからPhoto作成の処理が失敗したものを、再作成
# * Photoのファイル名にハッシュを入れて複雑化

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

logger = Logger.new "tmp/move_data_to_ver5.error.log"


# todo どこに置けばいいんだろう(ApplicationControllerにおいたものはtaskからは読めず)
# ActiveRecordで発行されたSQLを出力する
def watch_queries
  events = []
  callback = -> name,start,finish,id,payload { events << payload[:sql] }
  ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
    yield
  end
  events
end

namespace :tmp_work do

  desc "Fix faild Mutter Photo file for version5"
  task :to_ver5_fix_faild_mutter_photo_file => :environment do
    faild_mutter_ids = [15751,15636,15548,14749,14748,14723,14706,14587,14434,13503,13213,12868,12865,12803,12570,12519,12516,12213,11825,11034,10754]

    puts("スクリプトを実行します。env: [#{ENV['RAILS_ENV']}]")
    puts("対象: #{faild_mutter_ids.join(",")}")
    puts("* Mutter.imageをPaperclipにしてるかな？")
    puts("* _save_related_mediaを、globから取得するような形式で更新したかな？")
    puts("よろしいですか？(y/n)")
    print("> ")
    str = STDIN.gets
    if (str.chop != "y")
      puts("中断します")
      exit
    end

    logger.info "\n\nstart :to_ver5 [to_ver5_fix_faild_mutter_photo_file] [#{Time.now()}]"
    Mutter.where(id: faild_mutter_ids).each do |m|
      Dir.glob("/usr/local/site/adan/releases/20140618003416/public/upload/mutter/#{m.id}/original/*") do |f|
        if File.exists?(f)
          logger.debug "processing.. image_file: #{f}"
          begin
            saved_media = m._save_related_media(f)
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
    end
  end

  # Photoのファイル名を、元ファイル名を使用するのをやめて、idから生成するようにした(日本語が入ると取り扱いが面倒なため)
  desc "Rename Photo filename for version5"
  task :to_ver5_rename_photo_filename => :environment do
    puts("スクリプトを実行します。env: [#{ENV['RAILS_ENV']}] よろしいですか？(y/n)")
    print("> ")
    str = STDIN.gets
    if (str.chop != "y")
      puts("中断します")
      exit
    end

    logger.info "\n\nstart :to_ver5 [to_ver5_rename_filename] [#{Time.now()}]"

    Photo.all.each do |photo|
      p "processing.. album/#{photo.album_id}/#{photo.id}/:style/#{photo.image_file_name}"

      oldfilepath_org = Rails.root.to_path + "/public/upload/album/#{photo.album_id}/#{photo.id}/original/#{photo.image_file_name}"
      oldfilepath_large = Rails.root.to_path + "/public/upload/album/#{photo.album_id}/#{photo.id}/large/#{photo.image_file_name}"
      oldfilepath_thumb = Rails.root.to_path + "/public/upload/album/#{photo.album_id}/#{photo.id}/thumb/#{photo.image_file_name}"
      if File.exists?(oldfilepath_org)
        oldfilepath = oldfilepath_org
      elsif File.exists?(oldfilepath_large)
        oldfilepath = oldfilepath_large
      elsif File.exists?(oldfilepath_thumb)
        oldfilepath = oldfilepath_thumb
      else
        logger.error "対象のファイルが存在しません[album/#{photo.album_id}/#{photo.id}/:style/#{photo.image_file_name}"
        next
      end

      file = File.open(oldfilepath)
      photo.image = file
      photo.save
      logger.debug "#{oldfilepath} -> #{photo.image.path}"
    end
  end

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
