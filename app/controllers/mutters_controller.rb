# -*- coding: utf-8 -*-
class MuttersController < ApplicationController
  # for mobile
  before_filter :redirect_if_mobile, :except => [:new_from_mail, :create_from_mail]
  after_filter :update_request_at, only: [:index, :update_disp, :create]

  before_filter :authenticate_user!, :except => :rss
  before_filter :set_new_mutter_obj, only: [:index, :all, :search, :update_disp]
  cache_sweeper :mutter_sweeper, :only => [:create, :destroy, :create_from_mail, :celebration_create]

  def graph
    # allが選択された時も、年月選択フィールドは今月を選択しておきたいので@mutterを設定しておく
    if params[:mutter].blank? or params[:all].present?
      @mutter = Mutter.new(year: Date.today.year, month: Date.today.month)
    else
      @mutter = Mutter.new(params[:mutter])
    end

    if params[:all].present?
      @mutters_count = Mutter.group("DATE_FORMAT(created_at, '%Y/%m')").count
      @mutters_count = @mutters_count.map{|m| ["#{m[0]}/01", m[1]]}
      @format = "%y年%m月"
      @min = '2008-04'
      @interval = "1 year"
      @range_for_title = "全期間：2008年 - #{Date.today.year}年"
      @flg = 0
    else
      year = @mutter.year
      month = @mutter.month

      if year.present? and month.present?
        @mutters_count = Mutter.where("created_at >= ? and created_at <= ?", "#{year}/#{month}/1", "#{year}/#{month}/31").group("DATE_FORMAT(created_at, '%Y/%m/%d')").count.to_a
        @format = "%#d日"
        @min = "#{year}-#{month}-1"
        @interval = "1 day"
        @range_for_title = "#{year}年#{month}月"

        # 初期表示(今月分を表示する）
      elsif year.present? and month.blank?
        @mutters_count = Mutter.where("created_at >= ? and created_at <= ?", "#{year}/1/1", "#{year}/12/31").group("DATE_FORMAT(created_at, '%Y/%m')").count
        @mutters_count = @mutters_count.map{|m| ["#{m[0]}/01", m[1]]}
        @format = "%m月"
        @min = "#{year}-1-1" 
        @interval = "1 month"
        @range_for_title = "#{year}年"
      end
    end
  end

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


  #
  # つぶやき検索
  # mutters#indexからはAjaxで呼ばれる
  # mutters#allからはgetで呼ばれる
  #
  def search
    @action_flg = params["mutter"][:action_flg].to_i
    case @action_flg
    when 0
      @mutters = Mutter.includes_all.parents_mod
    when 1
      str = params["mutter"][:search_word]
      @mutters = Mutter.includes_all.where('content like :q', :q => "%#{str}%").order('id DESC')

      # 検索ワードを画面に表示し続けるため
      @mutter = Mutter.new(params[:mutter])
    when 2
      @mutters = Mutter.includes_all.where('mutters.image_file_name IS NOT NULL').order('id DESC')
    when 3
      @mutters = Mutter.includes_all.where('content like :q', :q => "%http%").order('id DESC')
    end
    @mutters = @mutters.page(params[:page]).per(30)

    # 検索時は右サイドバーを出さないように（理由は忘れた）
    @action_is_search = true

    respond_to do |format|
      format.html {render :action => "all"}
      format.js
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
    @uhs = UpdateHistory.view_normal.limit(5)
    @uhs.each do |obj|
      ai = UpdateHistory::ACTION_INFO[obj.action_type]
      time = obj.updated_at || obj.created_at
      @contents << {
        :title => "[#{time.to_s(:short3)}] [#{ai[:content_name]}]#{obj.user.dispname}が「#{obj.content.title}」#{ai[:info]}",
        :description => obj.content.title,
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
#todo kaminariにしてみたけどincludeしたらどうなる？？
    @mutters = Mutter.includes_all.user_is(params[:user_id]).parents_mod.page(params[:page]).per(30)

    # AutoPager対応
    @autopagerable = true

    unless read_fragment :mutter_by_user
      @users_mcnt = Mutter.group(:user_id).count
      @users = User.where(:id => @users_mcnt.keys).includes(:user_ext)
    end
  end

  def index
    @layout_type = 1
    @slideshow_visible = true
    @page_title = "トップ"

    updates_count = request.smart_phone? ? 5 : 10
    @updates = UpdateHistory.includes({:user => :user_ext}).view_normal.limit(updates_count)
    login_users_count = request.smart_phone? ? 7 : 40
    @login_users = User.includes(:user_ext).where("role != ?", User::TEST_USER).order("last_request_at DESC").limit(login_users_count)

    # from lesys
    @fix_title = ""
    #sakikazu ↓は、includesだったら、関連先が存在しないデータでも取得されてしまって不都合になるんだけど、joinsなら存在するデータのみなので良い。
    #この対応で合ってるのかな？ちなみに、joinsしたところに、includesも入れるとエラーになった
    # @mutters = mutter.includes_all.id_desc.limit(30)

    # つぶやき時間降順で親つぶやきのみを取得
    # unless read_fragment :mutter_data
    @mutters = Mutter.includes_all.parents_mod.page(params[:page]).per(7)
    # end

    @album_thumbs = Photo.rnd_photos

    # つぶやきの表示更新時間（ミリ秒指定）
    @dispupdate_interval = 10 * 1000

    ###日齢
    @nichirei, @nichirei_future = current_user.user_ext.nichirei

    ###誕生記念日(年齢／日齢)
    @kinen = UserExt.kinen

    # AutoPager対応
    @autopagerable = true

  end


  #
  # 選択されたmutterの位置から前後5つずつのmutterを取得する
  # 子が選択された場合、その子の前後mutterを取得し、その中かから親をユニークで取得
  #
  def show
    mutter = Mutter.find(params[:id])
    num = 5
    min = mutter.id - num
    max = mutter.id + num
    mutters_arround = Mutter.where(id: min..max)
    # 取得した前後のmutterの親IDを取得（自分が親なら自ID）
    ids = mutters_arround.map{|m| m.reply_id || m.id}
    mutter_ids = ids.uniq
    @mutters = Mutter.includes_all.where(id: mutter_ids)
  end

  def create
    @mutter = Mutter.new(params[:mutter])
    ua = request.env["HTTP_USER_AGENT"]
    @mutter.ua = ua

    # mutterにファイルが添付されなかったら、AjaxでPOSTされてくる
    if request.xhr?
      @mutter.save
      @mutters = Mutter.includes_all.parents_mod.limit(20)
      # 新規post用に入れ替える
      @created_mutter = @mutter
      @mutter = Mutter.new(:user_id => current_user.id)
      render :partial => "list"
    else
      respond_to do |format|
        if @mutter.save
          format.html { redirect_to mutters_path, notice: 'つぶやきを投稿しました。' }
          format.json { render json: @mutter, status: :created, location: @mutter }
        else
          format.html { redirect_to(mutters_path, :notice => 'つぶやきを入力しないと投稿できません') }
          format.json { render json: @mutter.errors, status: :unprocessable_entity }
        end
      end
    end

### ajax 失敗
    #@mutters = Mutter.all(:order => "id desc")
    #render :partial => "list", :locals => {:mutters => @mutters}
  end

  def destroy
    @mutter = Mutter.find(params[:id])
    @mutter.destroy
    @mutters = Mutter.includes_all.parents_mod.limit(20)
    render "update_list.js"
  end

  def update_history_all
    @updates = UpdateHistory.view_normal.page(params[:page]).per(50)
  end

  def slider_update
    @album_thumbs = Photo.rnd_photos
  end

  def celebration_new
    # お祝いする対象ユーザーの今日か昨日のCelebrationデータを取得
    user = User.find(params[:user_id])
    celeb = Celebration.where(:anniversary_at => [Date.today, Date.today - 1.day], :user_id => user.id).first
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
    params[:mutter][:ua] = request.env["HTTP_USER_AGENT"]

    Mutter.create(params[:mutter])
    redirect_to({:action => :index}, :notice => 'お祝いをしました。「お祝いを見る」から確認できます。')
  end

  def celebration
    #memo 当日以降ならcelebration_idをもとに抽出する
    if params[:celebration_id].present?
      cel = Celebration.find(params[:celebration_id])
    else
      cel = Celebration.where(:anniversary_at => [Date.today, Date.today - 1.day], :user_id => params[:user_id]).first
    end
    #ランダム抽出 -sample
    @celeb_mutters = cel.present? ? cel.mutters.sample(cel.mutters.size) : []
  end


  #
  # つぶやき表示更新
  #
  # 最後にされたつぶやきのIDをcookieに入れておき、
  # その後、定期的なJSでの呼び出しによって新しいつぶやきがないかチェックし、
  # 存在したら表示を更新する
  #
  def update_disp
    @mutters = Mutter.updated_datas(cookies)
    if @mutters.blank?
      render :text => ""
    else
      render :partial => "list"
    end
  end


  # つぶやき新着チェック
  # (ブラウザのNotificationにて表示する用)
  # (JSで一定時間ごとに呼び出している)
  #
  def update_check
    if cookies[:update_check_id].blank?
      cookies[:update_check_id] = Mutter.last.id
      render :text => ""
      return
    end

    prev_check = cookies[:update_check_id].to_i
    @mutters = Mutter.where("id > ?", prev_check)
    #自分のつぶやきは無視する
    @mutters.reject!{|m| m.user.id == current_user.id}
    if @mutters.size > 0
      cookies[:update_check_id] = Mutter.last.id
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
      redirect_to album_path(up.content, "sort" => 2, "ups_page" => @ups_page, "ups_id" => up.id)
    when UpdateHistory::ALBUM_COMMENT
      redirect_to album_path(up.content, "ups_page" => @ups_page, "ups_id" => up.id)
    when UpdateHistory::ALBUMPHOTO_CREATE
      redirect_to album_path(up.content, "sort" => 1, "ups_page" => @ups_page, "ups_id" => up.id)
    when UpdateHistory::ALBUMPHOTO_COMMENT_FOR_PHOTO
      redirect_to album_photo_path(up.content.album, up.content, "ups_page" => @ups_page, "ups_id" => up.id)
    when UpdateHistory::BOARD_CREATE, UpdateHistory::BOARD_COMMENT
      redirect_to board_path(up.content, "ups_page" => @ups_page, "ups_id" => up.id)
    when UpdateHistory::MOVIE_CREATE, UpdateHistory::MOVIE_COMMENT
      redirect_to movie_path(up.content, "ups_page" => @ups_page, "ups_id" => up.id)
    when UpdateHistory::BLOG_CREATE, UpdateHistory::BLOG_COMMENT
      redirect_to blog_path(up.content, "ups_page" => @ups_page, "ups_id" => up.id)
    end
  end



  private
  def recursive_for_update_all_view(prev, current, next_page)
    if prev.content == current.content
      next_page += 1
      up_next = UpdateHistory.view_offset(next_page).first
      recursive_for_update_all_view(current, up_next, next_page)
    else
      return current, next_page
    end
  end


  #
  # 新規レス用のオブジェクト生成
  # ※トップページでは、メインつぶやきのオブジェクトにもなる
  #
  def set_new_mutter_obj
    @mutter = Mutter.new(:user_id => current_user.id)
  end

end
