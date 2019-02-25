class MoviesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movie, only: [:show, :edit, :update, :destroy]
  before_action :init
  before_action :set_ups_data, only: [:show]

  # GET /movies
  # GET /movies.xml
  def index
    @sort = params[:sort].blank? ? 1 : params[:sort].to_i
    case @sort
    when 1
      @movies = Movie.where("movie_type = ? or movie_type IS NULL", Movie::TYPE_NORMAL).order('id DESC').page(params[:page]).per(20)
    else
      @movies = Movie.where(:movie_type => Movie::TYPE_MODIFY).order('id DESC').page(params[:page]).per(20)
    end

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
  end

  # NOTE: 動画作成はアルバムからなので、これは使ってないような
  # POST /movies
  # POST /movies.xml
  def create
    params[:movie][:user_id] = current_user.id
    params[:movie][:is_ready] = false
    @movie = Movie.new(movie_params)

    respond_to do |format|
      if @movie.save and @movie.ffmp.valid?
        EncodeWorker.perform_async @movie.id
        @movie.update_histories.create(user_id: current_user.id, action_type: UpdateHistory::MOVIE_CREATE)
        format.html { redirect_to @movie, notice: '動画をアップロードしました.' }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /movies/1
  # PUT /movies/1.xml
  def update
    # 動画が指定されなかったら動画エンコードを行わない
    selected_movie = params[:movie][:movie]
    if selected_movie.present?
      params[:movie][:is_ready] = false
    end
    respond_to do |format|
      if @movie.update_attributes(movie_params) and @movie.ffmp.valid?
        if selected_movie.present?
          EncodeWorker.perform_async @movie.id
        end
        format.html { redirect_to(@movie, :notice => '更新しました') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @movie.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.xml
  def destroy
    @movie.destroy

    respond_to do |format|
      format.html { redirect_to(movies_url, notice: '削除しました') }
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
      params.require(:movie).permit(:title, :description, :movie_type, :user_id, :movie, :thumb, :is_ready, :album_id)
  end

  def comment_params
    params.permit(:content, :user_id, :ua, :for_sort_at)
  end

end
