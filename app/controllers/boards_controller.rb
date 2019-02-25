class BoardsController < ApplicationController
  before_action :authenticate_user!
  before_action :page_title
  before_action :set_board, only: [:show, :edit, :update, :destroy]
  before_action :set_ups_data, only: [:show]

  # GET /boards
  # GET /boards.xml
  def index
    @sort = params[:sort].blank? ? 1 : params[:sort].to_i
    case @sort
    when 1
      buf = BoardComment.group(:board_id).maximum(:created_at)
      boards_mod = Board.all.map{|b| b.sort_at = (buf[b.id] || b.created_at); b}
      @boards = boards_mod.sort{|a,b| b.sort_at <=> a.sort_at}
      @boards = Kaminari.paginate_array(@boards)
    when 2
      @boards = Board.all
    else
      buf = BoardComment.group(:board_id).maximum(:created_at)
      boards_mod = Board.all.map{|b| b.sort_at = (buf[b.id] || b.created_at); b}
      @boards = boards_mod.sort{|a,b| b.sort_at <=> a.sort_at}
      @boards = Kaminari.paginate_array(@boards)
    end
    @boards = @boards.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @boards }
    end
  end

  # GET /boards/1
  # GET /boards/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @board }
    end
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
    @board.board_comments.create(:user_id => current_user.id, :content => params[:comment], :attach => params[:attach])

    UpdateHistory.create_or_update(current_user.id, UpdateHistory::BOARD_COMMENT, @board)

    flash[:notice] = "コメントを投稿しました"
    redirect_to :action => :show, :id => @board.id
  end

  def destroy_comment
    @bcom = BoardComment.find(params[:id])
    board = @bcom.board
    @bcom.destroy
    redirect_to({:action => :show, :id => board.id}, :notice => "コメントを削除しました")
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
