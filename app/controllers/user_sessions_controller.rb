class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  layout "blank", :only => :new
  
  def new
    @page_title = "ログイン"
    @user_session = UserSession.new
    #render :layout => false
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      LoginHistory.create(:user_id => UserSession.find.record.id)
      flash[:notice] = "ログインしました"
      redirect_back_or_default root_url
    else
      render :layout => "blank", :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = "ログアウトしました"
    redirect_back_or_default new_user_session_url
  end
end
