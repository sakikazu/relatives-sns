class UsersController < ApplicationController
  #before_filter :require_no_user, :only => [:new, :create]
  #before_filter :require_user, :only => [:index, :show, :edit, :update]
  before_filter :require_user
  before_filter :page_title
  
  def index
    @users = User.all(:include => "user_ext", :order => "user_exts.root11, users.id")
  end

  def all
    @users = User.all(:include => "user_ext", :order => "user_exts.updated_at DESC")
  end

  def new
    render :text => "権限がありません。" unless current_user.admin?
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "#{@user.login} を登録しました！"
      redirect_back_or_default new_user_url
    else
      render :action => :new
    end
  end
  
  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = @current_user
  end
  
  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "更新しました。"
      redirect_to :action => :show, :id => @user.id
    else
      render :action => :edit
    end
  end

  def edit_ex
    @user_ext = @current_user.user_ext
  end

  def update_ex
    @current_user.user_ext.update_attributes(params[:user_ext])
    flash[:notice] = "更新しました。"
    redirect_to :action => :show, :id => @current_user.user_ext.user.id
  end

  def login_history
    @lhs = LoginHistory.paginate(:page => params[:page], :per_page => 100, :order => "created_at DESC")
  end

private
  def page_title
    @page_title = "親戚データ"
  end

end
