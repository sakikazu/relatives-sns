class NicesController < ApplicationController
  before_action :authenticate_user!

  def recent
#sakikazu 現在、同じコンテンツでも、複数人が評価してたら人数分出てしまうので、コンテンツごとにまとめたい。ソート対象は、最後に評価した人物のnice.created_at
    #sakikazu ページネートは、コンテンツごとに置いてるが、ページを送ると、すべてのコンテンツが次ページのデータになる。問題はないけど、理想は、Ajaxでそのコンテンツのみだな
      # →あ、少なくともkaminariのAjaxのやつではできるわ
    @nices = {}
    %w(Mutter Photo Movie Blog).each do |type|
      # @nices[type.downcase] = Nice.where(:asset_type => type).order("id DESC").page(:page => params[:page]).per(10)
      @nices[type.downcase] = Nice.joins(:user).where(:asset_type => type).order("id DESC").limit(10)
    end
    @mutter = Mutter.new(:user_id => current_user.id) # Mutterのレス用
  end

  def wasnice
    @user = params[:user_id].present? ? User.find(params[:user_id]) : current_user

    contents = {}
    # 一つのコンテンツの評価人数を取得(type(Mutterなど)とIDでグループ化したときのそれぞれの個数)
    data = Nice.where(:niced_user_id => @user.id).group(:asset_type, :asset_id).count
    data2 = data.map{|d| {:type => d[0][0], :id => d[0][1], :count => d[1]}}
    # ブロック中の正規表現のグループで分ける。「$1」はマッチ文字列を返すようにするため
    data3 = data2.group_by{|d| d[:type] =~ /(Mutter|Photo|Movie|Blog)/;$1}
    ["Mutter", "Photo", "Movie", "Blog"].each do |c|
      next if data3[c].blank?
      # 評価人数でソートして降順にする
      data4 = data3[c].sort_by{|d| d[:count]}.reverse
      # 上位10個のみ取得
      contents[c] = data4.slice(0,10)
    end
    @mutter_data = contents["Mutter"] || []
    @movie_data = contents["Movie"] || []
    @photo_data = contents["Photo"] || []
    @blog_data = contents["Blog"] || []

    @users = Nice.niced_users
    @mutter = Mutter.new(:user_id => current_user.id) # Mutterのレス用
  end

  def donice
    @nices = {}
    @user = params[:user_id].present? ? User.find(params[:user_id]) : current_user
    nices = Nice.joins(:user).where(:user_id => @user.id).order("id DESC")

    nices = nices.group_by{|n| n[:asset_type] =~ /(Mutter|Photo|Movie|Blog)/;$1}
    %w(Mutter Photo Movie Blog).each do |type|
      # todo 元々paginate対応の予定だったが、辞めたので暫定的に配列10個取得してる
      @nices[type.downcase] = nices[type].present? ? nices[type][0..9] : []
    end

    @users = Nice.nicing_users
  end

  def ranking
    # TODO: ランキングページの各コンテンツごとにページネーションできるようになっているが、ページネーションはコンテンツごとにページ分けるほうがいいな
    # NOTE: コンテンツ指定の場合はAjax、指定しない場合は非Ajax
    ct = params[:content_type].to_i
    if ct == 1 || ct == 0
      @mutter_data = Ranking.total.mutter.page(params[:page]).per(10)
      @content_name = "mutter"
    end
    if ct == 2 || ct == 0
      @photo_data = Ranking.total.photo.page(params[:page]).per(10)
      @content_name = "photo"
    end
    if ct == 3 || ct == 0
      @blog_data = Ranking.total.blog.page(params[:page]).per(10)
      @content_name = "blog"
    end
    if ct == 4 || ct == 0
      @movie_data = Ranking.total.movie.page(params[:page]).per(10)
      @content_name = "movie"
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @content_type = params[:type]
    content_id = params[:content_id].to_i
    case @content_type
    when "mutter"
      @content = Mutter.find(content_id)
    when "photo"
      @content = Photo.find(content_id)
    when "movie"
      @content = Movie.find(content_id)
    when "blog"
      @content = Blog.find(content_id)
    end
    @update_area = params[:area]

    nice_params = {:user_id => current_user.id, :niced_user_id => @content.user_id}
    nice = Nice.new(nice_params)

    # 一つのコンテンツに評価できるのは、ユーザー一人につき一回のみ
    exist_check = Nice.where(:user_id => current_user.id, :asset_id => @content.id, :asset_type => @content.class.name)
    if exist_check.blank?
      @content.nices << nice
      create_related_content_nice(@content, nice_params)
    end
  end

  # todo: リファクタリングしたい・・
  def destroy
    @content_type = params[:type]
    @update_area = params[:area]
    nice = Nice.find(params[:id])
    return if nice.blank?
    @content = nice.asset
    nice.destroy
    destroy_related_content_nice(@content)
    render "create.js"
  end


private

  def create_related_content_nice(org_content, nice_params)
    nice = Nice.new(nice_params)
    content = related_content(org_content)
    content.nices << nice if content.present?
  end

  def destroy_related_content_nice(org_content)
    content = related_content(org_content)
    content.nices.where(user_id: current_user.id).destroy_all if content.present?
  end

  def related_content(org_content)
    if org_content.class == Mutter and org_content.photo.present?
      org_content.photo
    elsif org_content.class == Mutter and org_content.movie.present?
      org_content.movie
    elsif [Movie, Photo].include?(org_content.class) and org_content.mutter.present?
      org_content.mutter
    else
      nil
    end
  end

end
