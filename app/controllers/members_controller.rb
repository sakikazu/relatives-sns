class MembersController < ApplicationController
  before_action :authenticate_user!, except: ["relation"]
  before_action :page_title
  before_action :set_user, only: [:show, :edit, :update, :edit_account, :update_account, :destroy]
  before_action :restrict_other_family, only: [:edit, :update, :edit_account, :update_account, :destroy]

  # 家系図
  # NOTE: ログインなしでも見れるようにしている。理由は、集まりの席などでこのページを共有することが多いが、
  # そこで誰でも見れるようにしておくと、他のページにも興味が出た場合にログイン情報登録のモチベーションになるため。
  # 外部の人間も見る可能性はあるが、本名や生年月日は許容するとして、住所は非表示とする
  def relation
    # TODO: current_user.present?を改めて変数にし、明確にして使うというやり方はどうなのか、うまいやり方ある？
    @logined = current_user.present? ? true : false
    @relationed_users = User.build_relationed_users
    @count_by_generation = User.count_by_generation(@relationed_users)
  end

  # GET /members
  # GET /members.json
  def index
    @users = User.myfamily(current_user).includes_ext.order(:generation)
    @users += User.notfamily(current_user).includes_ext.order("root11, generation")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def all
    @users = User.includes_ext.order("user_exts.updated_at DESC")
  end

  def login_history
    @lhs = LoginHistory.order("created_at DESC").page(params[:page]).per(100)
  end

  def map
    #県名(addr1)が空でないユーザーのみ対象
    user_exts = UserExt.includes(:user).where("(addr1 is not NULL) and (addr1 != '')")
    gcodes = Geocode.all
    @user_exts = []
    @user_exts_err = []
    user_exts.each do |user_x|
      address = user_x.address
      gc = gcodes.find{|g| g.address == address}
      if gc.present?
        user_x.lat = gc.lat
        user_x.lng = gc.lng
        @user_exts << user_x
      else
        #テーブルに登録されていなかったらジオコーディングで取得する
        if(x = user_x.geocode).present?
          user_x.lat = x["lat"]
          user_x.lng = x["lng"]
          @user_exts << user_x
          Geocode.create(:address => address, :lat => x["lat"], :lng => x["lng"])
        else
          @user_exts_err << user_x
        end
      end
    end
  end


  # GET /members/1
  # GET /members/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /members/new
  # GET /members/new.json
  def new
    @user = User.new
    @user.build_user_ext
    @user.parent_id = params[:parent_user_id]
    restrict_other_family
    @users = User.includes_ext.order("user_exts.birth_day ASC")

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /members/1/edit
  def edit
    @users = User.includes_ext.order("user_exts.birth_day ASC")
  end

  def edit_me
    @user = current_user
    @users = User.includes_ext.order("user_exts.birth_day ASC")

    # todo: 必要かなぁ
    # user_extに名前が登録されていなかったら、userの方から取得してくる
    # @user_ext.familyname = @user_ext.user.familyname if @user_ext.familyname.blank? && @user_ext.user.familyname.present?
    # @user_ext.givenname = @user_ext.user.givenname if @user_ext.givenname.blank? && @user_ext.user.givenname.present?

    render 'edit'
  end

  # POST /members
  # POST /members.json
  def create
    @user = User.new(member_params)
    restrict_other_family
    @user.username = (0...4).map{ ('a'..'z').to_a[rand(26)] }.join

    respond_to do |format|
      if @user.save
        # redirect_back_or_default new_user_url

        format.html { redirect_to member_path(@user), notice: "#{@user.dispname(User::FULLNAME)}を登録しました." }
        format.json { render json: @user, status: :created, location: @user }
      else
        @users = User.includes_ext.order("user_exts.birth_day ASC")
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /members/1
  # PUT /members/1.json
  def update
    respond_to do |format|
      # NOTE: 現在更新してるのはUserExtであることに注意。Userと合わせて更新するように変更するかもだが
      if @user.user_ext.update(user_ext_params)
        format.html { redirect_to member_path(@user), notice: "#{@user.dispname(User::FULLNAME)}の情報を更新しました." }
        format.json { head :no_content }
      else
        # @users = User.includes_ext.order("user_exts.birth_day ASC")
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit_account
  end

  def update_account
    @user.attributes = user_params

    respond_to do |format|
      if @user.save
        format.html { redirect_to member_path(@user), notice: "#{@user.dispname(User::FULLNAME)}のユーザー名とパスワードが設定されました." }
        format.json { head :no_content }
      else
        format.html { render action: "edit_account" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /members/1
  # DELETE /members/1.json
  def destroy
    unless current_user.admin?
      redirect_back fallback_location: root_path, alert: '削除権限がありません。'
      return
    end

    name = @user.dispname(User::FULLNAME)
    @user.destroy

    respond_to do |format|
      format.html { redirect_to relation_members_url, notice: "#{name}を削除しました." }
      format.json { head :no_content }
    end
  end


private
  def page_title
    @page_title = "親戚データ"
  end

  def set_user
    @user = User.find(params[:id])
  end

  def restrict_other_family
    raise Forbidden unless current_user.editable(@user)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation, :familyname, :givenname)
  end

  def member_params
      params.require(:user).permit(:familyname, :givenname, :root11, :generation, :role, :email, :remember_me, :last_request_at, :parent_id, user_ext_attributes: [:id, :image, :nickname, :sex, :blood, :addr1, :addr2, :addr3, :addr4, :addr_from, :birth_day, :dead_day])
  end

  def user_ext_params
      params.require(:user_ext).permit(:familyname, :givenname, :nickname, :sex, :blood, :addr1, :addr2, :addr3, :addr4, :addr_from, :birth_day, :dead_day, :job, :hobby, :skill, :free_text, :image, :character, :jiman, :dream, :sonkei, :kyujitsu, :myboom, :fav_food, :unfav_food, :fav_movie, :fav_book, :fav_sports, :fav_music, :fav_game, :fav_brand, :hosii, :ikitai, :yaritai, :user_id)
  end
end
