class NicesController < ApplicationController
  def recent
#sakikazu 現在、同じコンテンツでも、複数人が評価してたら人数分出てしまうので、コンテンツごとにまとめたい。ソート対象は、最後に評価した人物のnice.created_at

    # まず多めに50個取得しておいて、後で各コンテンツに10個ずつ分ける。
    # これだと一つのコンテンツだけ10個になって、あとは0ってことも起こりうるが、とりあえずこれでいい
    data = Nice.order("id DESC").limit(60)
    data2 = data.group_by{|d| d[:nice_type] =~ /(Mutter|AlbumPhoto|Movie|Blog)/;$1}
    @mutter_data = data2["Mutter"].present? ? data2["Mutter"].slice(0,10) : []
    @movie_data = data2["Movie"].present? ? data2["Movie"].slice(0,10) : []
    @photo_data = data2["AlbumPhoto"].present? ? data2["AlbumPhoto"].slice(0,10) : []
    @blog_data = data2["Blog"].present? ? data2["Blog"].slice(0,10) : []
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
  end

  def create
    nice = Nice.new(:user_id => current_user.id)
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
end
