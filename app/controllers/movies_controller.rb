class MoviesController < ApplicationController
  before_filter :require_user
  before_filter :page_title

  # GET /movies
  # GET /movies.xml
  def index
    @movies = Movie.paginate(:page => params[:page], :per_page => 10, :order => "id DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @movies }
    end
  end

  # GET /movies/1
  # GET /movies/1.xml
  def show
    @movie = Movie.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @movie }
    end
  end

  # GET /movies/new
  # GET /movies/new.xml
  def new
    @movie = Movie.new(:user_id => current_user.id)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @movie }
    end
  end

  # GET /movies/1/edit
  def edit
    @movie = Movie.find(params[:id])
  end

  # POST /movies
  # POST /movies.xml
  def create
    params[:movie][:user_id] = current_user.id
    @movie = Movie.new(params[:movie])

    respond_to do |format|
      if @movie.save
        @movie.update_histories << UpdateHistory.create(:user_id => current_user.id, :action_type => UpdateHistory::MOVIE_CREATE)
        format.html { redirect_to(@movie, :notice => '作成しました') }
        format.xml  { render :xml => @movie, :status => :created, :location => @movie }
      else
##sakikazu todo エラー日本語化 ってかi18n化
        flash[:notice] = "動画ファイルを選択してください"
        format.html { render :action => "new" }
        format.xml  { render :xml => @movie.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /movies/1
  # PUT /movies/1.xml
  def update
    @movie = Movie.find(params[:id])

    respond_to do |format|
      if @movie.update_attributes(params[:movie])
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
    @movie = Movie.find(params[:id])
    @movie.destroy

    respond_to do |format|
      format.html { redirect_to(movies_url) }
      format.xml  { head :ok }
    end
  end

  def create_comment
    exit if params[:comment].blank?
    @movie = Movie.find(params[:movie_id])
    @movie.movie_comments.create(:user_id => current_user.id, :content => params[:comment])

    #UpdateHistory
    uh = UpdateHistory.find(:first, :conditions => {:user_id => current_user.id, :action_type => UpdateHistory::MOVIE_COMMENT, :assetable_id => @movie.id})
    if uh
      uh.update_attributes(:updated_at => Time.now)
    else
      @movie.update_histories << UpdateHistory.create(:user_id => current_user.id, :action_type => UpdateHistory::MOVIE_COMMENT)
    end
  end

  def destroy_comment
    @bcom = MovieComment.find(params[:id])
    movie = @bcom.movie
    @bcom.destroy
    redirect_to :action => :show, :id => movie.id
  end

private
  def page_title
    @page_title = "動画"
  end

end
