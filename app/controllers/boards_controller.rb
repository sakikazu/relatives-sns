# -*- coding: utf-8 -*-
class BoardsController < ApplicationController
  before_filter :require_user
  before_filter :page_title

  # GET /boards
  # GET /boards.xml
  def index
    @sort = params[:sort].blank? ? 1 : params[:sort].to_i
    case @sort 
    when 1
      buf = BoardComment.maximum(:created_at, :group => :board_id)
      boards_mod = Board.all.map{|b| b.sort_at = (buf[b.id] || b.created_at); b}
      @boards = boards_mod.sort{|a,b| b.sort_at <=> a.sort_at}.paginate(:page => params[:page], :per_page => 20)
    when 2
      @boards = Board.paginate(:page => params[:page], :per_page => 20, :order => "created_at DESC")
    else
      buf = BoardComment.maximum(:created_at, :group => :board_id)
      boards_mod = Board.all.map{|b| b.sort_at = (buf[b.id] || b.created_at); b}
      @boards = boards_mod.sort{|a,b| b.sort_at <=> a.sort_at}.paginate(:page => params[:page], :per_page => 20)
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
      @boards = boards_mod.sort{|a,b| b.sort_at <=> a.sort_at}.paginate(:page => params[:page], :per_page => 7)
    when 2
      @boards = Board.paginate(:page => params[:page], :per_page => 7, :order => "created_at DESC")
    else
      buf = BoardComment.maximum(:created_at, :group => :board_id)
      boards_mod = Board.all.map{|b| b.sort_at = (buf[b.id] || b.created_at); b}
      @boards = boards_mod.sort{|a,b| b.sort_at <=> a.sort_at}.paginate(:page => params[:page], :per_page => 7)
    end

    set_header
    render :action => :index_mobile, :layout => "mobile"
  end

  # GET /boards/1
  # GET /boards/1.xml
  def show
    #更新情報一括閲覧用
    @ups_page, @ups_action_info = update_allview_helper(params[:ups_page], params[:ups_id])

    @board = Board.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @board }
    end
  end

  def show_mobile
    @board = Board.find(params[:id])
    @board_comments = @board.board_comments.paginate(:page => params[:page], :per_page => 10, :order => "created_at DESC")
    set_header
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
    @board = Board.find(params[:id])
  end

  # POST /boards
  # POST /boards.xml
  def create
    params[:board][:user_id] = current_user.id
    @board = Board.new(params[:board])

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
    @board = Board.find(params[:id])

    respond_to do |format|
      if @board.update_attributes(params[:board])
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
    @board = Board.find(params[:id])
    @board.destroy

    respond_to do |format|
      format.html { redirect_to(boards_url) }
      format.xml  { head :ok }
    end
  end

  def create_comment
    @board = Board.find(params[:board_id])
    @board.board_comments.create(:user_id => current_user.id, :content => params[:comment], :attach => params[:attach])

    #UpdateHistory
    uh = UpdateHistory.find(:first, :conditions => {:user_id => current_user.id, :action_type => UpdateHistory::BOARD_COMMENT, :assetable_id => @board.id})
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
    @board.board_comments.create(:user_id => current_user.id, :content => params[:comment], :attach => params[:attach])

    #UpdateHistory
    uh = UpdateHistory.find(:first, :conditions => {:user_id => current_user.id, :action_type => UpdateHistory::BOARD_COMMENT, :assetable_id => @board.id})
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
  def page_title
    @page_title = "掲示板"
  end

end
