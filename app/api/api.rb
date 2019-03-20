class API < Grape::API
  format :json
  # formatter :json, Grape::Formatter::Rabl
  # default_format :json

  prefix 'api'
  version 'v1', using: :path

  # INVALID_TOKEN_ERROR = {status: 404, message: "Invalid token."}

  # --- private methods ---
  helpers do
    def build_timeline_data(mutters)
      timeline = []
      mutters.each do |mutter|
        photo_path = mutter.photo.present? ? mutter.photo.image(:large) : "";
        movie_path = (mutter.movie.present? and mutter.movie.is_ready?) ? mutter.movie.uploaded_full_path : "";
        movie_thumb_path = (mutter.movie.present? and mutter.movie.is_ready?) ? mutter.movie.thumb_path : "";
        is_encoding_movie = (mutter.movie.present? and not mutter.movie.is_ready?) ? true : false

        timeline << {
          mutter_id: mutter.id,
          username: mutter.user.dispname,
          # message: mutter.view_content,
          message: mutter.content,
          photo_path: photo_path,
          movie_path: movie_path,
          movie_thumb_path: movie_thumb_path,
          is_encoding_movie: is_encoding_movie,
          profile_image_path: mutter.user_image_path,
          post_time: mutter.created_at.strftime("%Y-%m-%d %H:%M:%S"),
          reply_id: mutter.reply_id,
          for_sort_at: mutter.for_sort_at.strftime("%Y-%m-%d %H:%M:%S"),
          can_modify: (mutter.user_id == @user.id) ? true : false,
          deleted_at: mutter.deleted_at
        }
      end
      timeline
    end

    def auth_with_token(token)
      @user = User.find_by_authentication_token(token)
      err_invalid_token if @user.blank?
    end

    def strong_params
      ActionController::Parameters.new(params).permit(:title)
    end
    def err401
      error!('401 Unauthorized', 401)
    end
    def err_invalid_token
      error!('404 Invalid token.', 404)
    end
  end


  resource :timeline do
    # GET /api/v1/timeline/initial?token=XXXX
    desc "get initial timeline data"
    # note: validation
    # params do
      # requires :token, type: Integer
      # optional :name, type: String
    # end
    get :initial do
      auth_with_token(params[:token])
      limit = params[:limit].presence || 15

      # とりあえず、「ひとりごと」はアプリには表示しないようにしよう
      parents = Mutter.includes_all.only_parents.without_wrapper.updated_order.limit(limit)
      # note: pluck(:id)だとすごい時間かかる。なぜ？？
      children = Mutter.includes_all.where(reply_id: parents.map{|n| n.id})
      mutters = parents + children
      timeline = build_timeline_data(mutters)
      return {
        timeline: timeline,
        latest_request_at: Time.now.to_s(:normal)
      }
    end

    # 指定時間以降更新があれば、特定件数返す
    # GET /api/timeline/latest?latest_request_at=XXX&token=XXXX
    desc "get latest timeline data"
    get :latest do
      auth_with_token(params[:token])
      limit = params[:limit].presence || 15

      # 更新があるかチェック
      current_time = Time.zone.parse(params[:latest_request_at])
      updated_mutters = Mutter.with_deleted.where("for_sort_at > ? or deleted_at > ?", current_time, current_time)
      updated_nices = Nice.where("created_at > ?", current_time)
      if updated_mutters.blank? and updated_nices.blank?
        return {
          timeline: []
        }
      end

      # todo refactoring
      # とりあえず、「ひとりごと」はアプリには表示しないようにしよう
      # 削除されたものも返したいので含む
      parents = Mutter.with_deleted.includes_all.only_parents.without_wrapper.updated_order.limit(limit)
      children = Mutter.with_deleted.includes_all.where(reply_id: parents.map{|n| n.id})
      mutters = parents + children
      timeline = build_timeline_data(mutters)
      return {
        timeline: timeline,
        latest_request_at: Time.now.to_s(:normal)
      }
    end

    # GET /api/timeline/older?oldest_mutter_id=XXX&token=XXXX
    desc "get older timeline data"
    get :older do
      auth_with_token(params[:token])

      # とりあえず、「ひとりごと」はアプリには表示しないようにしよう
      mutters = Mutter.includes_all.where("id < ?", params[:oldest_mutter_id]).limit(params[:limit])
      timeline = build_timeline_data(mutters)
      return {
        timeline: timeline
      }
    end

    # POST /api/timeline/post
    desc "post mutter"
    post :post do
      ua =  headers["User-Agent"]
      p params
      body = nil

      # note: Androidだとbodyキーが存在するがiOSでは存在しない。まあこのままでいっか
      if params.has_key? :body
        body = JSON.parse(params[:body])
      else
        body = params
      end

      p "body:#{body}"
      p "token:#{body["token"]}"
      auth_with_token(body["token"])

      reply_id = body["parent_mutter_id"].present? ? body["parent_mutter_id"].to_i : nil
      # note: すごい、AndroidからのFileのパラメータがUploadedFileのinitializeにちゃんと一致する！規格あんのかな
      file = params[:mediaFile].present? ? ActionDispatch::Http::UploadedFile.new(params[:mediaFile]) : nil
      p file
      # todo 現状、アプリから文字列として時間を受け取ると、タイムゾーン考慮されてないので-9hで入るな。とりあえず、サーバーの方で時間は埋めとくが、これだと少し遅い時間になるのでどうにかして
      # Mutter.create(user_id: @user.id, content: body["message"], image: file, for_sort_at: body["for_sort_at"])
      Mutter.create(user_id: @user.id, content: body["message"], image: file, reply_id: reply_id, ua: ua)
      UserExtension.send_gcm(@user.dispname, body["message"])
      return {
        status: 201
      }

    end

    # POST /api/timeline/delete
    desc "delete mutter"
    delete :delete do
      p params
      auth_with_token(params["token"])

      mutter = Mutter.find_by_id(params["mutter_id"])
      return {} if mutter.blank?

      mutter.destroy

      return {
        status: 201
      }

    end

  end

  # アクティブ状況
  resource :active_status do
    # GET /api/v1/active_status
    desc "get active status"
    get do
      # todo まあ、一応必要か
      # @user = User.find_by_authentication_token(params[:token])
      # err_invalid_token if @user.blank?

      requested_users = []
      User.requested_users.each do |user|
        access_time = user.last_request_at.present? ? user.last_request_at.strftime("%Y-%m-%d %H:%M:%S") : ""
        requested_users << {
          name: user.dispname,
          profile_image_path: user.user_ext.image(:small),
          access_time: access_time,
        }
      end
      return {
        requested_users: requested_users
      }
    end
  end

  # login, logout
  resource :token do
    # POST /api/v1/token
    desc "login"
    post do
      username = params[:username]
      password = params[:password]

      return {status: 406, message: "The request must contain the user username and password."} if username.blank? or password.blank?

      @user = User.find_by_username(username.downcase)

      return {status: 400, message: "Invalid username or passoword."} if @user.blank?

      @user.ensure_authentication_token
      @user.save(validate: false)

      if not @user.valid_password?(password)
        {status: 401, message: "Invalid username or passoword."}
      else
        {status: 200, result: {token: @user.authentication_token}}
      end
    end

    # DELETE /api/v1/token
    desc "logout"
    delete do
      @user = User.find_by_authentication_token(params[:token])
      err_invalid_token if @user.blank?
      @user.reset_authentication_token!
      return {status: 200, result: {token: params[:token]}}
    end

  end

  resource :register_id do
    # POST /api/v1/register_id
    desc 'プッシュ通知用regId登録'
    post do
      auth_with_token(params[:token])
      reg_id = params[:register_id]
      if reg_id.present?
        @user.save_extension(UserExtension::PUSH_APNS_OR_GCM, UserExtension::TYPE_GCM)
        @user.save_extension(UserExtension::PUSH_DEVICE_TOKEN, reg_id)
      end
      return {status: 200}
    end
  end

  resource :user do
    desc 'ユーザー追加'
    post do

    end
  end
end
