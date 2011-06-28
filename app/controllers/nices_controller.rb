class NicesController < ApplicationController
  before_filter :require_user
  before_filter :page_title
  cache_sweeper :nice_sweeper, :only => [:create, :destroy]

  def recent
#sakikazu 現在、同じコンテンツでも、複数人が評価してたら人数分出てしまうので、コンテンツごとにまとめたい。ソート対象は、最後に評価した人物のnice.created_at
    #sakikazu ページネートは、コンテンツごとに置いてるが、ページを送ると、すべてのコンテンツが次ページのデータになる。問題はないけど、理想は、Ajaxでそのコンテンツのみだな
      # →あ、少なくともkaminariのAjaxのやつではできるわ
    @nices = {}
    %w(Mutter AlbumPhoto Movie Blog).each do |type|
      @nices[type.downcase] = Nice.where(:nice_type => type).order("id DESC").paginate(:page => params[:page], :per_page => 10)
    end
    @sort = 1
  end

  def wasnice
    @user = params[:user_id].present? ? User.find(params[:user_id]) : current_user

    contents = {}
    # 一つのコンテンツの評価人数を取得(type(Mutterなど)とIDでグループ化したときのそれぞれの個数)
    data = Nice.where(:niced_user_id => @user.id).group(:nice_type, :nice_id).count
    data2 = data.map{|d| {:type => d[0][0], :id => d[0][1], :count => d[1]}}
    # ブロック中の正規表現のグループで分ける。「$1」はマッチ文字列を返すようにするため
    data3 = data2.group_by{|d| d[:type] =~ /(Mutter|AlbumPhoto|Movie|Blog)/;$1}
    ["Mutter", "AlbumPhoto", "Movie", "Blog"].each do |c|
      next if data3[c].blank?
      # 評価人数でソートして降順にする
      data4 = data3[c].sort_by{|d| d[:count]}.reverse
      # 上位10個のみ取得
      contents[c] = data4.slice(0,10)
    end
    @mutter_data = contents["Mutter"] || []
    @movie_data = contents["Movie"] || []
    @photo_data = contents["AlbumPhoto"] || []
    @blog_data = contents["Blog"] || []

    @users = Nice.select('distinct niced_user_id').map{|n| User.find(n.niced_user_id)}

    @sort = 4
  end

  def donice
    @nices = {}
    @user = params[:user_id].present? ? User.find(params[:user_id]) : current_user
    nices = Nice.where(:user_id => @user.id).order("id DESC")

    nices = nices.group_by{|n| n[:nice_type] =~ /(Mutter|AlbumPhoto|Movie|Blog)/;$1}
    %w(Mutter AlbumPhoto Movie Blog).each do |type|
      @nices[type.downcase] = nices[type].present? ? nices[type].paginate(:page => params[:page], :per_page => 10) : {}
    end

    @users = Nice.select('distinct user_id').map{|n| User.find(n.user_id)}

    @sort = 3
  end

  def ranking
    contents = {}
    # 一つのコンテンツの評価人数を取得(type(Mutterなど)とIDでグループ化したときのそれぞれの個数)
    data = Nice.group(:nice_type, :nice_id).count
    data2 = data.map{|d| {:type => d[0][0], :id => d[0][1], :count => d[1]}}
    # ブロック中の正規表現のグループで分ける。「$1」はマッチ文字列を返すようにするため
    data3 = data2.group_by{|d| d[:type] =~ /(Mutter|AlbumPhoto|Movie|Blog)/;$1}
    ["Mutter", "AlbumPhoto", "Movie", "Blog"].each do |c|
      next if data3[c].blank?
      # 評価人数でソートして降順にする
      data4 = data3[c].sort_by{|d| d[:count]}.reverse
      # 上位10個のみ取得
      contents[c] = data4.slice(0,10)
    end
    @mutter_data = contents["Mutter"] || []
    @movie_data = contents["Movie"] || []
    @photo_data = contents["AlbumPhoto"] || []
    @blog_data = contents["Blog"] || []
    @sort = 2
  end

  def create
    @content_type = params[:type]
    case @content_type
    when "mutter"
      @content = Mutter.find(params[:content_id].to_i)
    when "photo"
      @content = AlbumPhoto.find(params[:content_id].to_i)
    when "movie"
      @content = Movie.find(params[:content_id].to_i)
    when "blog"
      @content = Blog.find(params[:content_id].to_i)
    end
    @update_area = params[:area]

    nice = Nice.new(:user_id => current_user.id, :niced_user_id => @content.user_id)

    # 一つのコンテンツに評価できるのは、ユーザー一人につき一回のみ
    exist_check = Nice.where(:user_id => current_user.id, :nice_id => @content.id, :nice_type => @content.class.name)
    if exist_check.blank?
      @content.nices << nice
    end
  end

  def destroy
    @content_type = params[:type]
    @update_area = params[:area]
    nice = Nice.find(params[:id])
    @content = nice.nice
    nice.destroy
    render "create.js"
  end

private
  def page_title
    @page_title = "人気"
  end

end
