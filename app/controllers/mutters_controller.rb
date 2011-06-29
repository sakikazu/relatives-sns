class MuttersController < ApplicationController
  before_filter :redirect_if_mobile, :except => [:new_from_mail, :create_from_mail]
  after_filter :set_header, :only => [:new_from_mail, :create_from_mail]
  before_filter :require_user, :except => :rss
  cache_sweeper :mutter_sweeper, :only => [:create, :destroy, :create_from_mail, :celebration_create]

  def new_from_mail
    config = YAML.load(File.read(File.join(Rails.root, 'config', 'gmail.yml')))
    @to = config['to']
    env = Rails.env == "development" ? "[dev]" : ""
    @subject = "[a-dan-hp]#{env}mutter[user_id]#{current_user.id}"
    if request.mobile?
      @content_title = "画像付きつぶやき"
      render :layout => 'mobile'
    end
  end

  def create_from_mail
    Mutter.create_from_mail
    redirect_to(mutters_path, :notice => 'メールからつぶやきました。それが表示されてないときは、前の画面に戻って再度「つぶやく」ボタンを押してください。')
  end

  def search
    @action_flg = params[:action_flg].to_i
    case @action_flg
    when 0
      @mutters = Mutter.includes_all.order("id DESC").limit(30)
    when 1
      str = params[:search_text]
      @mutters = Mutter.includes_all.where('content like :q', :q => "%#{str}%").order('id DESC').limit(30)
    when 2
      @mutters = Mutter.includes_all.where('image_file_name IS NOT NULL').order('id DESC').limit(30)
    when 3
      @mutters = Mutter.includes_all.where('content like :q', :q => "%http%").order('id DESC').limit(30)
    end
  end

  def rss
    @site_title = "AdanHP"
    @site_url = root_url
    @site_description = @site_title
    @author = "sakikazu"

    @contents = []
    @mutters = Mutter.id_desc.limit(5)
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
#sakimura ↓だとMutterすべてのレコードのカウントをJOINして出すので時間かかってる。kaminariならそんなことないのかなぁ。limit(30)とかやってもダメね。
    # @mutters = Mutter.includes([{:user => :user_ext}]).order("id DESC").paginate(:page => params[:page], :per_page => 30)
#sakimura ページネート時のフラグメントキャッシュ方法がわからん。いらんかなー。いや要らんでしょう。更新頻度高いのにページごとに保存て効率悪そう
    @mutters = Mutter.user_is(params[:user_id]).paginate(:page => params[:page], :per_page => 30)
    unless read_fragment :mutter_by_user
      @users_mcnt = Mutter.group(:user_id).count
      @users = User.where(:id => @users_mcnt.keys).includes(:user_ext)
    end
  end

  def index
    @page_title = "トップ"
    @mutter = Mutter.new(:user_id => current_user.id)
    # unless read_fragment :mutter_data
    @mutters = Mutter.includes_all.id_desc.limit(30)
    # end
    @updates = UpdateHistory.includes({:user => :user_ext}).sort_updated.limit(10)
    @login_users = User.includes(:user_ext).where("role != ?", User::TEST_USER).order("last_request_at DESC").limit(20)
    @album_thumbs = AlbumPhoto.rnd_photos
    @dispupdate_interval = 10 * 1000

    ###日齢
    @nichirei, @nichirei_future = current_user.user_ext.nichirei

    ###誕生記念日(年齢／日齢)
    @kinen = UserExt.kinen
  end

  # nicesからのみ呼ばれる
  def show
    @mutter = Mutter.find(params[:id])
    #現在のmutterの位置から前後5つずつのmutterを取得する
    num = 5
    count = Mutter.where("id < ?", @mutter.id).count
    @mutters = Mutter.includes_all.offset(count - num).limit(num*2+1)
    @mutters = @mutters.reverse
  end

  def create
    mutter = Mutter.new(params[:mutter])

    # mutterにファイルが添付されなかったら、AjaxでPOSTされてくる
    if request.xhr?
      mutter.save
      @mutters = Mutter.includes_all.id_desc.limit(30)
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
    @updates = UpdateHistory.includes({:user => :user_ext}).sort_updated.paginate(:page => params[:page], :per_page => 50)
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

  #つぶやき表示更新
  def update_disp
    prev_check = Time.parse(cookies[:update_disp_at]) rescue Time.now
    cookies[:update_disp_at] = Time.now
    new_mutters = Mutter.where("created_at > ?", prev_check)
    if new_mutters.size > 0
      @mutters = Mutter.includes_all.id_desc.limit(30)
      render :partial => "list"
    else
      render :text => ""
    end
  end  

  #つぶやき新着チェック
  def update_check
    prev_check = Time.parse(cookies[:update_check_at]) rescue Time.now
    cookies[:update_check_at] = Time.now
    @mutters = Mutter.where("created_at > ?", prev_check)
    #自分のつぶやきは無視する
    @mutters.reject!{|m| m.user.id == current_user.id}
    if @mutters.size > 0
      # render :text => @mutters.uniq_by{|m| m.user}.map{|m| m.user.dispname}.join(",")
      render :partial => "mutter_update"
    else
      render :text => ""
    end
  end

  #更新情報一括閲覧
  def update_allview
    next_page = params[:ups_page].blank? ? 0 : params[:ups_page].to_i
    if next_page > 0
      up_prev = UpdateHistory.view_offset(next_page - 1).first
      up_current = UpdateHistory.view_offset(next_page).first
      up, next_page = recursive_for_update_all_view(up_prev, up_current, next_page)
    else
      up = UpdateHistory.view_offset(next_page).first
    end

    @ups_page = next_page + 1

    ai = UpdateHistory::ACTION_INFO[up.action_type]
    case up.action_type
    when UpdateHistory::ALBUM_CREATE
      redirect_to album_path(up.assetable, "sort" => 2, "ups_page" => @ups_page, "ups_id" => up.id)
    when UpdateHistory::ALBUM_COMMENT
      redirect_to album_path(up.assetable, "ups_page" => @ups_page, "ups_id" => up.id)
    when UpdateHistory::ALBUMPHOTO_CREATE
      redirect_to album_path(up.assetable, "sort" => 1, "ups_page" => @ups_page, "ups_id" => up.id)
    when UpdateHistory::ALBUMPHOTO_COMMENT_FOR_PHOTO
      redirect_to slideshow_album_photo_path(up.assetable, "ups_page" => @ups_page, "ups_id" => up.id)
    when UpdateHistory::BOARD_CREATE, UpdateHistory::BOARD_COMMENT
      redirect_to board_path(up.assetable, "ups_page" => @ups_page, "ups_id" => up.id)
    when UpdateHistory::MOVIE_CREATE, UpdateHistory::MOVIE_COMMENT
      redirect_to movie_path(up.assetable, "ups_page" => @ups_page, "ups_id" => up.id)
    when UpdateHistory::BLOG_CREATE, UpdateHistory::BLOG_COMMENT
      redirect_to blog_path(up.assetable, "ups_page" => @ups_page, "ups_id" => up.id)
    end
  end

  private
  def recursive_for_update_all_view(prev, current, next_page)
    if prev.assetable == current.assetable
      next_page += 1
      up_next = UpdateHistory.view_offset(next_page).first
      recursive_for_update_all_view(current, up_next, next_page)
    else
      return current, next_page
    end
  end

end
