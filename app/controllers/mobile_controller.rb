class MobileController < ApplicationController
  before_filter :require_user

  ## jpmobile memo
  #JpmobileではControllerにmobile_filterを指定することで DoCoMo、Au、SoftBankの絵文字を透過的に扱うことができる。
  #また、半角・全角の自動変換を用いる場合は 「 :hankaku=>true」
  mobile_filter :hankaku=>true
  after_filter :set_header

  layout "mobile"

  def index
    @page_title = "トップ"
    @mutter = Mutter.new(:user_id => current_user.id)
    @mutters = Mutter.paginate(:page => params[:page], :per_page => 7, :order => "id DESC")
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
    @updates = UpdateHistory.paginate(:page => params[:page], :per_page => 15, :order => "id DESC")
  end

private
  def set_header
    headers['Content-Type'] = 'application/xhtml+xml;charset=Shift_JIS'
  end

end
