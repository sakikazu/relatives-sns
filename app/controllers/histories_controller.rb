class HistoriesController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_history, only: [:show, :edit, :update, :destroy]

  # GET /histories
  # GET /histories.xml
  def index
    @histories = History.includes([{:user => :user_ext}, :history_comments]).all
    @history = History.new

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @histories }
    end
  end

  def new
    @history = History.new
    render "form", :layout => false
  end

  # GET /histories/1/edit
  def edit
    render "form", :layout => false
  end

  # POST /histories
  # POST /histories.xml
  def create
    params[:history][:user_id] = current_user.id
    @history = History.new(history_params)
    if @history.save
      # format.html { redirect_to(@history, :notice => 'History was successfully created.') }
      # format.xml  { render :xml => @history, :status => :created, :location => @history }

    #sakikazu memo ここ、Ajaxのエラーハンドリングはどうすべきなんだろう
    else
      # format.html { render :action => "new" }
      # format.xml  { render :xml => @history.errors, :status => :unprocessable_entity }
    end

    @histories = History.includes([{:user => :user_ext}, :history_comments]).all
  end

  # PUT /histories/1
  # PUT /histories/1.xml
  def update
    if @history.update_attributes(history_params)
      # format.html { redirect_to(@history, :notice => 'History was successfully updated.') }
      # format.xml  { head :ok }
    else
      # format.html { render :action => "edit" }
      # format.xml  { render :xml => @history.errors, :status => :unprocessable_entity }
    end

    @histories = History.includes([{:user => :user_ext}, :history_comments]).all
  end

  # DELETE /histories/1
  # DELETE /histories/1.xml
  def destroy
    @history.destroy

    respond_to do |format|
      format.html { redirect_to(histories_url, :notice => "削除しました") }
      format.xml  { head :ok }
    end
  end

  def new_comment
    @comment = HistoryComment.new(:user_id => current_user.id, :history_id => params[:history_id])
    render :layout => false
  end

  def create_comment
    @comment = HistoryComment.new(history_comment_params)
    if @comment.save
      redirect_to(histories_path, :notice => "コメントしました")
    else
      redirect_to(histories_path, :notice => "エラー：コメント内容を入力してください")
    end
  end

  def destroy_comment
    @comment = HistoryComment.find(params[:id])
    @comment.destroy
    redirect_to(histories_path, :notice => "コメントを削除しました")
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_history
      @history = History.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def history_params
      params.require(:history).permit(:user_id, :episode_year, :episode_month, :episode_day, :about_flg, :content, :src_user_name)
  end

  def history_comment_params
      params.require(:history_comment).permit(:user_id, :history_id, :content)
  end

end
