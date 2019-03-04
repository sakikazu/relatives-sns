class MoviesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movie, only: [:show, :edit, :update, :destroy]
  before_action :init
  before_action :set_ups_data, only: [:show]

  # GET /movies
  # GET /movies.xml
  def index
    @sort = params[:sort].blank? ? 1 : params[:sort].to_i
    @movies = case @sort
              when 1
                Movie.where("movie_type = ? or movie_type IS NULL", Movie::TYPE_NORMAL)
              else
                Movie.where(:movie_type => Movie::TYPE_MODIFY)
              end
    @movies = @movies.id_desc.page(params[:page]).per(15)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @movies }
    end
  end

  # GET /movies/1
  # GET /movies/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @movie }
    end
  end

  # GET /movies/1/edit
  def edit
    # NOTE: turbolinksのせいだと思うが、動画アップロードのform#idがnewとeditとで同じだと、
    # head内の"turbolinks:load"で登録したsubmitイベントリスナーが、ページ遷移によって重複して登録されてしまった
    # documentオブジェクトをキャッシュしてるが、違うURLだと、同じform#idでもイベントリスナーを再度登録しちゃう感じかなぁ
    @movie_form_id = 'movie-form-edit'
  end

  # AjaxでのみPOSTされる
  #
  # POST /movies
  # POST /movies.xml
  def create
    @movie = Movie.new(movie_params)
    @movie.user_id = current_user.id
    @movie.is_ready = false

    if @movie.save and @movie.ffmp.valid?
      @movie.workered_encode
      @movie.update_histories.create(user_id: current_user.id, action_type: UpdateHistory::MOVIE_CREATE)
      render json: {}, status: :created
    else
      render json: @movie.errors.full_messages, status: :unprocessable_entity
    end
  end

  # AjaxでのみPOSTされる
  #
  # PUT /movies/1
  # PUT /movies/1.xml
  def update
    # 動画が指定されなかったら動画エンコードを行わない
    @movie.is_ready = false if movie_params[:movie].present?
    if @movie.update(movie_params) and @movie.ffmp.valid?
      @movie.workered_encode
      render json: {}, status: :created
    else
      render json: @movie.errors.full_messages, status: :unprocessable_entity
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.xml
  def destroy
    unless editable(current_user, @movie.user)
      redirect_back fallback_location: root_path, alert: '削除権限がありません。'
      return
    end
    @movie.destroy

    respond_to do |format|
      format.html { redirect_to(movies_url, notice: '動画を削除しました') }
      format.xml  { head :ok }
    end
  end

  def create_comment
    if params[:content].blank?
      @error_message = 'コメントを入力しないと投稿できません'
      render 'shared/error_alert.js'
      return
    end

    params.merge!(Mutter.extra_params(current_user, request))
    @movie = Movie.find(params[:id])

    @movie.create_comment_by_mutter(comment_params)

    UpdateHistory.for_creating_comment(@movie, UpdateHistory::MOVIE_COMMENT, current_user.id)
  end

  def destroy_comment
    Mutter.find(params[:mutter_id]).destroy
    @movie = Movie.find(params[:id])
    UpdateHistory.for_destroying_comment(@movie, UpdateHistory::MOVIE_COMMENT, current_user.id, @movie.mutter_comments.last)
    render 'create_comment.js'
  end

  private
  def init
    @page_content_type = "動画"
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_movie
    @movie = Movie.find(params[:id])
    @page_content_title = @movie.title if @movie.present?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def movie_params
      params.require(:movie).permit(:title, :description, :movie_type, :user_id, :movie, :thumb, :album_id)
  end

  def comment_params
    params.permit(:content, :user_id, :ua, :for_sort_at)
  end

end
