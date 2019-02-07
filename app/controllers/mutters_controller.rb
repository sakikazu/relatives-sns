class MuttersController < ApplicationController
  include ApplicationHelper

  after_action :update_request_at, only: [:index, :create]

  before_action :authenticate_user!, :except => :rss
  before_action :set_new_mutter_obj, only: [:index, :all, :search]
  # todo 2014-05-12
  # cache_sweeper :mutter_sweeper, :only => [:create, :destroy, :create_from_mail, :celebration_create]

  before_action :set_mutter, only: [:destroy]

  def graph
    # allが選択された時も、年月選択フィールドは今月を選択しておきたいので@mutterを設定しておく
    if params[:mutter].blank? or params[:all].present?
      @mutter = Mutter.new(year: Date.today.year, month: Date.today.month)
    else
      @mutter = Mutter.new(mutter_params)
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


  #
  # つぶやき検索
  # (親子構造にせず、フラットに表示する）
  # mutters#indexからはAjaxで呼ばれる
  # mutters#allからはgetで呼ばれる
  #
  def search
    if params["mutter"].blank? or params["mutter"]["action_flg"].blank? # mutters#indexでAutoPagerで読み込まれた場合
      @action_flg = 0
    else
      params[:mutter] = params["mutter"]
      @action_flg = params[:mutter][:action_flg].to_i
      @search_word = params[:mutter][:search_word]
      @user_id = params[:mutter][:user_id]
    end
    @leave_me = params[:leave_me].blank? ? false : true

    case @action_flg
    when 0 # 検索結果解除
      @mutters = Mutter.includes_all.parents_mod
    when 1 # ワードから検索
      @mutters = Mutter.includes_all.order('id DESC')
    when 2 # 画像か動画を含むものを検索
      mutter_ids_with_photo = Photo.pluck("mutter_id").compact
      mutter_ids_with_photo += Movie.pluck("mutter_id").compact
      @mutters = Mutter.includes_all.where(id: mutter_ids_with_photo).order('id DESC')
    when 3 # URLを含むものを検索
      @mutters = Mutter.includes_all.where('content like :q', :q => "%http%").order('id DESC')
    end

    # 検索時の共通処理(解除操作の場合はパラメータがないので通らない)
    @mutters = @mutters.where(user_id: @user_id) if @user_id.present?
    @mutters = @mutters.where('content like :q', :q => "%#{@search_word}%") if @search_word.present?

    # 「ひとりごと」
    @mutters = @mutters.where(leave_me: @leave_me)

    @mutters = @mutters.page(params[:page])

    # 検索ワードを画面に表示し続けるため
    @mutter = Mutter.new(mutter_params) if params[:mutter].present?

    # 検索時は右サイドバーを出さないように
    # （理由は右サイドバーを表示するためのデータ取得をやりたくないからだったはず）
    @action_is_search = true

    if request.xhr?
      if params[:page].present?
        render partial: 'list'
      else
        render 'search.js'
      end
      return
    else
      respond_to do |format|
        format.html {render :action => "all"}
        format.js
      end
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
    @mutters = Mutter.includes_all.user_is(params[:user_id]).parents_mod.page(params[:page]).per(15)

    unless read_fragment :mutter_by_user
      @users_mcnt = Mutter.group(:user_id).count
      @users = User.where(:id => @users_mcnt.keys).includes(:user_ext)
    end
  end

  def index
    @slideshow_visible = true
    @page_title = "トップ"

    updates_count = request.smart_phone? ? 5 : 10
    @updates = UpdateHistory.view_normal.limit(updates_count)
    login_users_count = request.smart_phone? ? 7 : 40
    @login_users = User.requested_users(login_users_count)

    # from lesys
    @fix_title = ""
    #sakikazu ↓は、includesだったら、関連先が存在しないデータでも取得されてしまって不都合になるんだけど、joinsなら存在するデータのみなので良い。
    #この対応で合ってるのかな？ちなみに、joinsしたところに、includesも入れるとエラーになった
    # @mutters = mutter.includes_all.id_desc.limit(30)

    # つぶやき時間降順で親つぶやきのみを取得
    # unless read_fragment :mutter_data
    @mutters = Mutter.includes_all.parents_mod.page(params[:page])
    # end

    @leave_me = params[:leave_me].blank? ? false : true
    if @leave_me.present?
      current_user.save_extension(UserExtension::LAST_READ_LEAVE_ME_AT, Time.now())
      @count_unread_leave_me_mutters = 0
    else
      ext = current_user.find_extension(UserExtension::LAST_READ_LEAVE_ME_AT)
      last_read_at = ext.present? ? ext[:value] : Time.parse("2000/1/1")
      @count_unread_leave_me_mutters = @mutters.where(leave_me: true).where.not(user_id: current_user.id).where("created_at > ?", last_read_at).count
    end
    @mutters = @mutters.where(leave_me: @leave_me)

    @album_thumbs = Photo.rnd_photos

    ###日齢
    @nichirei, @nichirei_future = current_user.user_ext.nichirei

    ###誕生記念日(年齢／日齢)
    @kinen = UserExt.kinen
  end


  #
  # 選択されたmutterの位置から前後5つずつのmutterを取得する
  # 子が選択された場合、その子の前後mutterを取得し、その中かから親をユニークで取得
  #
  def show
    # todo
    # このときのMutter一覧の中で削除すると、_mutter_with_comments.html.erbがホームでの削除前提なのか、動的にViewが更新されない。削除はされる。気が向いたら修正しよう
    # ここでレスしたら、この画面で更新されてほしいがホームに行ってしまう。これもー。
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

  # NOTE: 作成後の画面更新は、MutterのコールバックでActionCableによって行っている
  def create
    if params[:mutter][:content].blank?
      @error_message = 'つぶやきを入力しないと投稿できません'
      render 'create.js'
      return
    end

    params[:mutter].merge!(Mutter.extra_params(current_user, request))
    @mutter = Mutter.new(mutter_params)
    unless @mutter.save
      @error_message = @mutter.errors.full_messages.first
    end
  end

  def destroy
    unless editable(current_user, @mutter.user)
      @error_message = '削除権限がありません。'
      render "update_list.js"
      return
    end
    mutter_leave_me = @mutter.leave_me
    @mutter.destroy
    @mutters = Mutter.includes_all.parents_mod.page(params[:page])
    @mutters = @mutters.where(leave_me: mutter_leave_me)
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
    @celebration = Celebration.where(celebration_params).first
    if @celebration.blank?
      @celebration = Celebration.create(celebration_params)
    end

    params[:mutter].merge!(Mutter.extra_params(current_user, request, @celebration.id))
    Mutter.create(mutter_params)
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

  # つぶやき新着チェック
  # (ブラウザのNotificationにて表示する用)
  # (JSで一定時間ごとに呼び出している)
  #
  def update_check
    if cookies[:update_check_id].blank?
      cookies[:update_check_id] = Mutter.last.id
      render plain: ""
      return
    end

    prev_check = cookies[:update_check_id].to_i
    @mutters = Mutter.where("id > ?", prev_check)
    #自分のつぶやきは無視する
    @mutters.reject!{|m| m.user.id == current_user.id}
    if @mutters.size > 0
      cookies[:update_check_id] = Mutter.last.id
      # render plain: @mutters.uniq_by{|m| m.user}.map{|m| m.user.dispname}.join(",")
      render :partial => "mutter_update"
    else
      render plain: ""
    end
  end

  # 更新情報一括閲覧
  def update_allview
    next_page = params[:ups_page].blank? ? 0 : params[:ups_page].to_i
    if next_page > 0
      up_prev = UpdateHistory.view_offset(next_page - 1).first
      up_current = UpdateHistory.view_offset(next_page).first
      up, next_page = recursive_for_update_all_view(up_prev, up_current, next_page)
    else
      up = UpdateHistory.view_offset(next_page).first
    end

    if up.blank?
      redirect_to root_path
      return
    end

    @ups_page = next_page + 1

    ai = UpdateHistory::ACTION_INFO[up.action_type]
    case up.action_type
    when UpdateHistory::ALBUM_CREATE
      redirect_to album_path(up.content, "ups_page" => @ups_page, "ups_id" => up.id)
    when UpdateHistory::ALBUM_COMMENT
      redirect_to album_path(up.content, focus_comment: 1, "ups_page" => @ups_page, "ups_id" => up.id)
    when UpdateHistory::ALBUMPHOTO_CREATE
      redirect_to album_path(up.content, "album[sort_flg]" => 1, "album[user_id]" => up.user_id, "ups_page" => @ups_page, "ups_id" => up.id)
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
    return nil, nil if prev.blank? or current.blank?
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

  # Use callbacks to share common setup or constraints between actions.
  def set_mutter
      @mutter = Mutter.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def mutter_params
      params.require(:mutter).permit(:user_id, :content, :reply_id, :created_at, :updated_at, :celebration_id, :image, :for_sort_at, :year, :month, :search_word, :action_flg, :ua, :leave_me)
  end

  def celebration_params
      params.require(:celebration).permit(:anniversary_at, :user_id)
  end
end
