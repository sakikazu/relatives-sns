class API < Grape::API
  format :json
  # formatter :json, Grape::Formatter::Rabl
  # default_format :json

  prefix 'api'
  version 'v1', using: :path

  # INVALID_TOKEN_ERROR = {status: 404, message: "Invalid token."}

  # --- private methods ---
  helpers do
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
      @user = User.find_by_authentication_token(params[:token])
      err_invalid_token if @user.blank?

      timeline = []
      Mutter.includes_all.parents_mod.limit(15).each do |mutter|
        photo_path = mutter.photo.present? ? mutter.photo.image(:large) : "";
        movie_path = (mutter.movie.present? and mutter.movie.is_ready?) ? mutter.movie.uploaded_full_path : "";
        movie_thumb_path = (mutter.movie.present? and mutter.movie.is_ready?) ? mutter.movie.thumb_path : "";

        timeline << {
          username: mutter.user.dispname,
          # message: mutter.view_content,
          message: mutter.content,
          photo_path: photo_path,
          movie_path: movie_path,
          movie_thumb_path: movie_thumb_path,
          profile_image_path: mutter.user_image_path,
          post_time: mutter.created_at.strftime("%Y-%m-%d %H:%M:%S"),
        }
      end
      return {
        timeline: timeline
      }
    end

    # GET /api/timeline/updated?token=XXXX
    desc "get updated timeline data"
    get :updated do
      @user = User.find_by_authentication_token(params[:token])
      err_invalid_token if @user.blank?

      return {
        mutters: Mutter.limit(10),
        photos: Photo.limit(5),
        users: User.limit(3)
      }
    end

    # POST /api/timeline/post
    desc "post mutter"
    post :post do
      body = JSON.parse(params[:body])
      @user = User.find_by_authentication_token(body["token"])
      err_invalid_token if @user.blank?

      # note: すごい、AndroidからのFileのパラメータがUploadedFileのinitializeにちゃんと一致する！規格あんのかな
      file = ActionDispatch::Http::UploadedFile.new(params[:mediaFile])
      p file
      Mutter.create(user_id: @user.id, content: body["message"], image: file)
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
      requested_users = []
      User.requested_users.each do |user|
        requested_users << {
          name: user.dispname,
          profile_image_path: user.profile_path,
          access_time: user.last_request_at,
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
