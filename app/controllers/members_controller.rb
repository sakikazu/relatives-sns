class MembersController < ApplicationController
  before_action :authenticate_user!, except: ["relation"]
  before_action :page_title

  # 家系図
  def relation
    all_users = User.includes_ext.order("user_exts.birth_day ASC")
    root11_users = all_users.select{|u| u.parent_id == nil}
    @users = []
    root11_users.each do |user|
      @users << recursive_relation(user, all_users)
    end
  end

  def recursive_relation(user, users)
    user_h = {id: user.id,
              name: user.dispname(User::FULLNICK),
              age_h: user.user_ext.age_h,
              sex_h: user.user_ext.sex_name,
              blood_h: user.user_ext.blood_name,
              address: user.user_ext.address,
              birth_dead_h: user.user_ext.birth_dead_h,
              is_dead: user.user_ext.dead_day.present?,
              image_path: user.user_ext.image? ? user.user_ext.image(:thumb) : "/images/missing.gif"
    }

    children = users.select{|u| u.parent_id == user.id}
    if children.blank?
      return user_h.merge({has_members_num: 0, family: []})
    else
      has_members_num = 0
      family = []

      children.each do |child|
        has_members_num += 1

        child_h = recursive_relation(child, users)
        family << child_h
        has_members_num += child_h[:has_members_num]
      end
      return user_h.merge({has_members_num: has_members_num, family: family})
    end
  end

  # GET /members
  # GET /members.json
  def index
    @users = User.includes_ext.order("users.root11, users.id")

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
    @user = User.find(params[:id])

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
    @users = User.includes_ext.order("user_exts.birth_day ASC")

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /members/1/edit
  def edit
    @user = User.find(params[:id])
    @users = User.includes_ext.order("user_exts.birth_day ASC")
  end

  # POST /members
  # POST /members.json
  def create
    @user = User.new(member_params)
    @user.username = (0...4).map{ ('a'..'z').to_a[rand(26)] }.join

    respond_to do |format|
      if @user.save(validate: false)
        # redirect_back_or_default new_user_url

        format.html { redirect_to finish_create_member_path(@user), notice: "#{@user.dispname(User::FULLNAME)}を登録しました." }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def finish_create
    @user = User.find(params[:id])
  end

  # PUT /members/1
  # PUT /members/1.json
  def update
    @user = User.find(params[:id])
    @user.attributes = member_params

    respond_to do |format|
      if @user.save(validate: false)
        format.html { redirect_to relation_members_path, notice: "#{@user.dispname(User::FULLNAME)}の情報を更新しました." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit_account
    @user = User.find(params[:id])
  end

  def update_account
    @user = User.find(params[:id])
    @user.attributes = user_params

    respond_to do |format|
      if @user.save
        format.html { redirect_to edit_member_path(@user), notice: "#{@user.dispname(User::FULLNAME)}のユーザー名とパスワードが設定されました." }
        format.json { head :no_content }
      else
        format.html { render action: "edit_account" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit_ex
    @user_ext = current_user.user_ext

    # user_extに名前が登録されていなかったら、userの方から取得してくる
    @user_ext.familyname = @user_ext.user.familyname if @user_ext.familyname.blank? && @user_ext.user.familyname.present?
    @user_ext.givenname = @user_ext.user.givenname if @user_ext.givenname.blank? && @user_ext.user.givenname.present?
  end

  def update_ex
    current_user.user_ext.update_attributes(user_ext_params)
    redirect_to({:action => :show, :id => current_user.user_ext.user.id}, notice: '更新しました.')
  end

  # DELETE /members/1
  # DELETE /members/1.json
  def destroy
    @user = User.find(params[:id])
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

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end

  def member_params
      params.require(:user).permit(:familyname, :givenname, :root11, :generation, :role, :email, :remember_me, :last_request_at, :parent_id, user_ext_attributes: [:id, :image, :nickname, :sex, :blood, :addr1, :addr2, :addr3, :addr4, :addr_from, :birth_day, :dead_day])
  end

  def user_ext_params
      params.require(:user_ext).permit(:familyname, :givenname, :nickname, :sex, :blood, :email, :addr1, :addr2, :addr3, :addr4, :addr_from, :birth_day, :dead_day, :job, :hobby, :skill, :free_text, :image, :character, :jiman, :dream, :sonkei, :kyujitsu, :myboom, :fav_food, :unfav_food, :fav_movie, :fav_book, :fav_sports, :fav_music, :fav_game, :fav_brand, :hosii, :ikitai, :yaritai, :user_id)
  end

end
