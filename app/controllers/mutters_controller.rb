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
      @contents << {:title => "[#{obj.created_at.to_s(:short3)}] つぶやき(#{obj.user.dispname})", :description => obj.content, :created_at => obj.created_at}
    end
    @uhs = UpdateHistory.sort_updated.find(:all, :limit => 5)
    @uhs.each do |obj|
      ai = UpdateHistory::ACTION_INFO[obj.action_type]
      @contents << {:title => "[#{obj.created_at.to_s(:short3)}] [#{ai[:content_name]}]#{obj.user.dispname}が「#{obj.assetable.title}」#{ai[:info]}", :description => obj.assetable.title, :created_at => obj.created_at}
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
    @page_title = "トップ"
    @mutter = Mutter.new(:user_id => current_user.id)
    @mutters = Mutter.all(:order => "id DESC", :limit => 30)
    @users = User.find(:all, :order => "current_login_at DESC", :limit => 10)
    @updates = UpdateHistory.sort_updated.find(:all, :limit => 10)

    ###日齢
    mybirth = current_user.user_ext.birth_day
    if mybirth 
      @nichirei = (Date.today - mybirth).to_i
      @nichirei_future = []
    	[5000,7777,10000,11111,15000,20000,22222,25000,30000,33333,35000,40000,44444,45000,50000].each do |kinen|
        break if @nichirei_future.size >= 2
        if @nichirei < kinen
          kinenday = Date.today + (kinen - @nichirei) 
          @nichirei_future << [kinen, kinenday]
        end
      end
    end

    ###誕生記念日(年齢／日齢)
    @kinen = []
    kinenbirth_array = [20 => '二十歳', 60 => '還暦', 77 => '喜寿', 88 => '米寿', 99 => '白寿']
    kinenday_array = [10000,20000,30000,40000]

    UserExt.find(:all, :conditions => "birth_day is not NULL").each do |ue|
      birday_tmp = Date.new(Date.today.year, ue.birth_day.month, ue.birth_day.day)
    
      ##--年齢--##

      #今年の誕生日が過ぎていたら来年の誕生日で計算する（例えば、本日が2008/12/25だったら、1/5の誕生日の人は2009/1/5で計算する）
      if (birday_tmp - Date.today) < 0
        birday_tmp = birday_tmp + 1.year
      end
    
      #記念日が10日以内なら表示
      diffday = birday_tmp - Date.today
      if diffday <= 10
        #年齢が登録記念日に該当するなら記念日名を、そうでないなら「誕生日」と出力
        years = (birday_tmp - ue.birth_day) / 365
        kinen_name =  kinenbirth_array[years] || "誕生日"
        @kinen << {:name => ue.user.dispname(User::FULLNAME), :count => diffday, :kinen_name => kinen_name}
      end

      ##--日齢--##
      kinenday_array.each do |k|
        diffday = k - (Date.today - ue.birth_day)
        #記念日齢が10日以内なら表示
        if diffday >= 0 and diffday <= 10
          kinen_name = "#{k}日齢"
          @kinen << {:name => ue.user.dispname(User::FULLNAME), :count => diffday, :kinen_name => kinen_name}
          #初めの日齢のみ表示
          break 
        end
      end
    end
  end


  def create
    mutter = Mutter.new(params[:mutter])
    respond_to do |format|
      if mutter.save
        format.html { redirect_to(mutters_path, :notice => '') }
        format.xml  { render :xml => mutter, :status => :created, :location => mutter }
      else
        format.html { redirect_to(mutters_path, :notice => 'つぶやきを入力しないと投稿できません') }
        format.xml  { render :xml => mutter.errors, :status => :unprocessable_entity }
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

end
