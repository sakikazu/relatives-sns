class MuttersController < ApplicationController
  before_filter :redirect_if_mobile
  before_filter :require_user, :except => :rss

  def search
    str = params[:search_text]
    @mutters = Mutter.where('content like :q', :q => "%#{str}%").order('id DESC').limit(30)
    @action_flg = !params[:action_flg]
  end

  def rss
    @site_title = "AdanHP"
    @site_url = root_url
    @site_description = @site_title
    @author = "sakikazu"

    @contents = []
    @mutters = Mutter.find(:all, :limit => 5, :order => "id DESC")
    @mutters.each do |obj|
      @contents << {:title => "[#{obj.created_at.to_s(:short3)}] つぶやき(#{obj.user.dispname})", :description => obj.content, :updated_at => obj.created_at}
    end
    @uhs = UpdateHistory.sort_updated.find(:all, :limit => 5)
    @uhs.each do |obj|
      ai = UpdateHistory::ACTION_INFO[obj.action_type]
      time = obj.updated_at || obj.created_at
      @contents << {
        :title => "[#{time.to_s(:short3)}] [#{ai[:content_name]}]#{obj.user.dispname}が「#{obj.assetable.title}」#{ai[:info]}",
        :description => obj.assetable.title,
        :updated_at => time}
    end

    respond_to do |format|
      format.html
      format.rss { render :layout => false }
    end
  end

  def all
    @mutters = Mutter.paginate(:page => params[:page], :per_page => 50, :order => "id DESC")
    @users = User.all
  end

  def user
    @mutters = Mutter.paginate(:conditions => {:user_id => params[:user_id]}, :page => params[:page], :per_page => 50, :order => "id DESC")
    @users = User.all
    render :action => :all
  end

  def index
raise # ExceptionNotifierテスト用
    @page_title = "トップ"
    @mutter = Mutter.new(:user_id => current_user.id)
    @mutters = Mutter.includes([{:user => :user_ext}, :celebration]).order("id DESC").limit(30)
    @login_users = User.includes(:user_ext).order("last_request_at DESC").limit(15)
    @updates = UpdateHistory.includes({:user => :user_ext}).sort_updated.limit(10)
    @album_thumbs = AlbumPhoto.rnd_photos

    ###日齢
    @nichirei, @nichirei_future = current_user.user_ext.nichirei

    ###誕生記念日(年齢／日齢)
    @kinen = UserExt.kinen
  end

  def create
    mutter = Mutter.new(params[:mutter])

    # mutterにファイルが添付されなかったら、AjaxでPOSTされてくる
    if request.xhr?
      mutter.save
      @mutters = Mutter.includes([{:user => :user_ext}, :celebration]).order("id DESC").limit(30)
      render :partial => "list"
    else
      respond_to do |format|
        if mutter.save
          format.html { redirect_to(mutters_path, :notice => '') }
          format.xml  { render :xml => mutter, :status => :created, :location => mutter }
        else
          format.html { redirect_to(mutters_path, :notice => 'つぶやきを入力しないと投稿できません') }
          format.xml  { render :xml => mutter.errors, :status => :unprocessable_entity }
        end
      end
    end

### ajax 失敗
    #@mutters = Mutter.all(:order => "id desc")
    #render :partial => "list", :locals => {:mutters => @mutters}
  end

  def destroy
    mutter = Mutter.find(params[:id])
    name = mutter.user.login
    mutter.destroy
    flash[:notice] = "#{name}のつぶやきを削除しました"
    redirect_to :action => :index
  end

  def update_history_all
    @uhs = UpdateHistory.sort_updated.paginate(:page => params[:page], :per_page => 50)
  end

  def slider_update
    @album_thumbs = AlbumPhoto.rnd_photos
  end

  def celebration_new
    user = User.find(params[:user_id])
    celeb = Celebration.where(:anniversary_at => Date.today, :user_id => user.id).first
    if celeb.present?
      if celeb.mutters.where(:user_id => current_user.id).present?
        @flag = false
      else
        @mutter = celeb.mutters.new(:user_id => current_user.id, :content => 'おめでとう！')
        @flag = true
      end
      @celebration = celeb
    else
      @celebration = Celebration.new(:anniversary_at => Date.today, :user_id => user.id)
      @mutter = @celebration.mutters.new(:user_id => current_user.id, :content => 'おめでとう！')
      @flag = true
    end
    render :layout => "simple"
  end

  def celebration_create
    @celebration = Celebration.where(params[:celebration]).first
    if @celebration.blank?
      @celebration = Celebration.create(params[:celebration])
    end
    params[:mutter][:celebration_id] = @celebration.id
    Mutter.create(params[:mutter])
    redirect_to({:action => :index}, :notice => 'お祝いをしました。「お祝いを見る」から確認できます。')
  end

  def celebration
    #memo 当日以降ならcelebration_idをもとに抽出する
    if params[:celebration_id].present?
      cel = Celebration.find(params[:celebration_id])
    else
      cel = Celebration.where(:anniversary_at => Date.today, :user_id => params[:user_id]).first
    end
    #ランダム抽出 -sample
    @celeb_mutters = cel.present? ? cel.mutters.sample(cel.mutters.size) : []
  end

end
