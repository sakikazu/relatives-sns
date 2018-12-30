class MobileController < ApplicationController
  before_action :authenticate_user!
  after_action :update_request_at, only: [:index]

  ## jpmobile memo
  #JpmobileではControllerにmobile_filterを指定することで DoCoMo、Au、SoftBankの絵文字を透過的に扱うことができる。
  #また、半角・全角の自動変換を用いる場合は 「 :hankaku=>true」
  ###update mobile_filter → hankaku_filter
  hankaku_filter

  layout "mobile"

  def index
    @content_title = "誕生記念日"
    @page_title = "トップ"
    @mutter = Mutter.new(:user_id => current_user.id)
    @mutters = Mutter.includes({:user => :user_ext}).order("id DESC").page(params[:page]).per(12)
    @kinen = UserExt.kinen
  end

  def create
    mutter = Mutter.new(params[:mutter])
    mutter.save
    redirect_to mobile_path
  end

  def destroy
    mutter = Mutter.find(params[:id])
    mutter.destroy
    flash[:notice] = "<Mutter(ID: #{mutter.id})を削除しました>"
    redirect_to :action => :index
  end

  def update_history
    @content_title = "みんなの更新情報"
    @updates = UpdateHistory.sort_updated.page(params[:page]).per(15)
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
    @content_title = "#{@celebration.user.dispname(User::FULLNAME)}さんを祝う"
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
    if params[:celebration_id].present?
      cel = Celebration.find(params[:celebration_id])
    else
      cel = Celebration.where(:anniversary_at => Date.today, :user_id => params[:user_id]).first
    end
    @content_title = "#{cel.user.dispname(User::FULLNAME)}さんへのお祝い"
    @celeb_mutters = cel.present? ? cel.mutters : []
  end 
end
