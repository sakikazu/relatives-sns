class MoviesController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_movie, only: [:show, :edit, :update, :destroy]
  before_action :init

  # GET /movies
  # GET /movies.xml
  def index
    @sort = params[:sort].blank? ? 1 : params[:sort].to_i
    case @sort
    when 1
      @movies = Movie.where("movie_type = ? or movie_type IS NULL", Movie::TYPE_NORMAL).page(params[:page]).per(10)
    else
      @movies = Movie.where(:movie_type => Movie::TYPE_MODIFY).page(params[:page]).per(10)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @movies }
    end
  end

  # GET /movies/1
  # GET /movies/1.xml
  def show
    #更新情報一括閲覧用
    @ups_page, @ups_action_info = update_allview_helper(params[:ups_page], params[:ups_id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @movie }
    end
  end

  # GET /movies/new
  # GET /movies/new.xml
  def new
    @movie = Movie.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @movie }
    end
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies
  # POST /movies.xml
  def create
    params[:movie][:user_id] = current_user.id
    params[:movie][:is_ready] = false
    @movie = Movie.new(movie_params)

    respond_to do |format|
      if @movie.save and @movie.ffmp.valid?
        EncodeWorker.perform_async @movie.id
        @movie.update_histories << UpdateHistory.create(:user_id => current_user.id, :action_type => UpdateHistory::MOVIE_CREATE)
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
    if params[:comment].blank?
      render :text => "", :status => 500
      return
    end

    @movie = Movie.find(params[:movie_id])
    @movie.movie_comments.create(:user_id => current_user.id, :content => params[:comment])

    #UpdateHistory
    uh = UpdateHistory.where(:user_id => current_user.id, :action_type => UpdateHistory::MOVIE_COMMENT, :content_id => @movie.id).first
    if uh
      uh.update_attributes(:updated_at => Time.now)
    else
      @movie.update_histories << UpdateHistory.create(:user_id => current_user.id, :action_type => UpdateHistory::MOVIE_COMMENT)
    end
  end

  def destroy_comment
    @bcom = MovieComment.find(params[:comment_id])
    movie = @bcom.movie
    @bcom.destroy
    redirect_to({:action => :show, :id => movie.id}, notice: "コメントを削除しました")
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
      params.require(:movie).permit(:title, :description, :movie_type, :user_id, :movie, :thumb, :is_ready)
  end

end
