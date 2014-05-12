class BoardsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :page_title
  before_action :set_board, only: [:show, :edit, :update, :destroy, :show_mobile]

  # GET /boards
  # GET /boards.xml
  def index
    @sort = params[:sort].blank? ? 1 : params[:sort].to_i
    case @sort
    when 1
      buf = BoardComment.maximum(:created_at, :group => :board_id)
      boards_mod = Board.all.map{|b| b.sort_at = (buf[b.id] || b.created_at); b}
      @boards = boards_mod.sort{|a,b| b.sort_at <=> a.sort_at}
      @boards = Kaminari.paginate_array(@boards).page(params[:page]).per(20)
    when 2
      @boards = Board.page(params[:page]).per(20)
    else
      buf = BoardComment.maximum(:created_at, :group => :board_id)
      boards_mod = Board.all.map{|b| b.sort_at = (buf[b.id] || b.created_at); b}
      @boards = boards_mod.sort{|a,b| b.sort_at <=> a.sort_at}
      @boards = Kaminari.paginate_array(@boards).page(params[:page]).per(20)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @boards }
    end
  end

  def index_mobile
    @content_title = "掲示板"
    @sort = params[:sort].blank? ? 1 : params[:sort].to_i
    case @sort 
    when 1
      buf = BoardComment.maximum(:created_at, :group => :board_id)
      boards_mod = Board.all.map{|b| b.sort_at = (buf[b.id] || b.created_at); b}
      @boards = boards_mod.sort{|a,b| b.sort_at <=> a.sort_at}
      @boards = Kaminari.paginate_array(@boards).page(params[:page]).per(7)
    when 2
      @boards = Board.page(params[:page]).per(7)
    else
      buf = BoardComment.maximum(:created_at, :group => :board_id)
      boards_mod = Board.all.map{|b| b.sort_at = (buf[b.id] || b.created_at); b}
      @boards = boards_mod.sort{|a,b| b.sort_at <=> a.sort_at}.page(params[:page]).per(7)
    end

    render :action => :index_mobile, :layout => "mobile"
  end

  # GET /boards/1
  # GET /boards/1.xml
  def show
    #更新情報一括閲覧用
    @ups_page, @ups_action_info = update_allview_helper(params[:ups_page], params[:ups_id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @board }
    end
  end

  def show_mobile
    @board_comments = @board.board_comments.page(params[:page]).per(10)
    render :action => :show_mobile, :layout => "mobile"
  end

  # GET /boards/new
  # GET /boards/new.xml
  def new
    @board = Board.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @board }
    end
  end

  # GET /boards/1/edit
  def edit
  end

  # POST /boards
  # POST /boards.xml
  def create
    params[:board][:user_id] = current_user.id
    @board = Board.new(board_params)

    respond_to do |format|
      if @board.save
        @board.update_histories << UpdateHistory.create(:user_id => current_user.id, :action_type => UpdateHistory::BOARD_CREATE)
        format.html { redirect_to(@board, :notice => '作成しました') }
        format.xml  { render :xml => @board, :status => :created, :location => @board }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @board.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /boards/1
  # PUT /boards/1.xml
  def update
    respond_to do |format|
      if @board.update_attributes(board_params)
        format.html { redirect_to(@board, :notice => '更新しました') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @board.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /boards/1
  # DELETE /boards/1.xml
  def destroy
    @board.destroy

    respond_to do |format|
      format.html { redirect_to(boards_url, notice: "削除しました") }
      format.xml  { head :ok }
    end
  end

  def create_comment
    @board = Board.find(params[:board_id])
    @board.board_comments.create(:user_id => current_user.id, :content => params.permit(:comment), :attach => params.permit(:attach))

    #UpdateHistory
    uh = UpdateHistory.find(:first, :conditions => {:user_id => current_user.id, :action_type => UpdateHistory::BOARD_COMMENT, :content_id => @board.id})
    if uh
      uh.update_attributes(:updated_at => Time.now)
    else
      @board.update_histories << UpdateHistory.create(:user_id => current_user.id, :action_type => UpdateHistory::BOARD_COMMENT)
    end

    flash[:notice] = "コメントを投稿しました"
    redirect_to :action => :show, :id => @board.id
  end

  def create_comment_mobile
    @board = Board.find(params[:board_id])
    @board.board_comments.create(:user_id => current_user.id, :content => params.permit(:comment), :attach => params.permit(:attach))

    #UpdateHistory
    uh = UpdateHistory.find(:first, :conditions => {:user_id => current_user.id, :action_type => UpdateHistory::BOARD_COMMENT, :content_id => @board.id})
    if uh
      uh.update_attributes(:updated_at => Time.now)
    else
      @board.update_histories << UpdateHistory.create(:user_id => current_user.id, :action_type => UpdateHistory::BOARD_COMMENT)
    end

    redirect_to({:action => :show_mobile, :id => @board.id}, :notice => "コメントを投稿しました")
  end

  def destroy_comment
    @bcom = BoardComment.find(params[:id])
    board = @bcom.board
    @bcom.destroy
 
    if request.mobile?
      redirect_to({:action => :show_mobile, :id => board.id}, :notice => "コメントを削除しました")
    else
      redirect_to({:action => :show, :id => board.id}, :notice => "コメントを削除しました")
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_board
      @board = Board.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def board_params
      params.require(:board).permit(:title, :description, :attach, :user_id)
  end

  def page_title
    @page_title = "掲示板"
  end

end
