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

        timeline << {
          mutter_id: mutter.id,
          username: mutter.user.dispname,
          # message: mutter.view_content,
          message: mutter.content,
          photo_path: photo_path,
          movie_path: movie_path,
          movie_thumb_path: movie_thumb_path,
          profile_image_path: mutter.user_image_path,
          post_time: mutter.created_at.strftime("%Y-%m-%d %H:%M:%S"),
          reply_id: mutter.reply_id,
          for_sort_at: mutter.for_sort_at.strftime("%Y-%m-%d %H:%M:%S"),
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

      # とりあえず、「ひとりごと」はアプリには表示しないようにしよう
      parents = Mutter.includes_all.parents_mod.limit(15)
      # note: pluck(:id)だとすごい時間かかる。なぜ？？
      children = Mutter.includes_all.where(reply_id: parents.map{|n| n.id})
      mutters = parents + children
      timeline = build_timeline_data(mutters)
      return {
        timeline: timeline
      }
    end

    # GET /api/timeline/latest?latest_mutter_id=XXX&token=XXXX
    desc "get latest timeline data"
    get :latest do
      auth_with_token(params[:token])

      # todo refactoring
      # とりあえず、「ひとりごと」はアプリには表示しないようにしよう
      mutters = Mutter.includes_all.where("id > ?", params[:latest_mutter_id])
      timeline = build_timeline_data(mutters)
      return {
        timeline: timeline
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
      p params
      body = JSON.parse(params[:body])
      p "body:#{body}"
      p "token:#{body["token"]}"
      auth_with_token(body["token"])

      reply_id = body["parent_mutter_id"].present? ? body["parent_mutter_id"].to_i : nil
      # note: すごい、AndroidからのFileのパラメータがUploadedFileのinitializeにちゃんと一致する！規格あんのかな
      file = params[:mediaFile].present? ? ActionDispatch::Http::UploadedFile.new(params[:mediaFile]) : nil
      p file
      # todo 現状、アプリから文字列として時間を受け取ると、タイムゾーン考慮されてないので-9hで入るな。とりあえず、サーバーの方で時間は埋めとくが、これだと少し遅い時間になるのでどうにかして
      # Mutter.create(user_id: @user.id, content: body["message"], image: file, for_sort_at: body["for_sort_at"])
      Mutter.create(user_id: @user.id, content: body["message"], image: file, reply_id: reply_id)
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
          profile_image_path: user.profile_path,
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


  resource :user do
    desc 'ユーザー追加'
    post do

    end
  end
end
