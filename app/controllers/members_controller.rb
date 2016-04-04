class MembersController < ApplicationController
  before_filter :authenticate_user!, except: ["relation"]
  before_filter :page_title

  # 家系図
  def relation
    @users = [
      {id: 1, name: "崎村輝美", age: 67, relational: "長男", has_members_num: 5, family: [
        {id: 11, name: "キヨコ", age: 63, relational: "妻", has_members_num: 0, family: nil},
        {id: 12, name: "和孝", age: 33, relational: "長男", has_members_num: 0, family: nil},
        {id: 13, name: "泰孝", age: 32, relational: "次男", has_members_num: 2, family: [
          {id: 101, name: "まさみ", age: 42, relational: "妻", has_members_num: 0, family: nil},
          {id: 102, name: "kouta", age: 4, relational: "長男", has_members_num: 0, family: nil},
        ]},
      ]},
      {id: 2, name: "崎村まき", age: 60, relational: "五女", has_members_num: 3, family: [
        {id: 21, name: "政孝", age: 63, relational: "夫", has_members_num: 0, family: nil},
        {id: 22, name: "たかひろ", age: 33, relational: "長男", has_members_num: 0, family: nil},
        {id: 23, name: "ちさ", age: 32, relational: "次男", has_members_num: 2, family: [
          {id: 121, name: "aaa", age: 6, relational: "長女", has_members_num: 0, family: nil},
          {id: 122, name: "bbb", age: 4, relational: "長男", has_members_num: 0, family: nil},
        ]},
      ]},
      {id: 3, name: "崎村ゆかり", age: 53, relational: "六女", has_members_num: 3, family: nil},
    ]
  end

  # GET /members
  # GET /members.json
  def index
    @users = User.includes("user_ext").order("users.root11, users.id")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def all
    @users = User.includes("user_ext").order("user_exts.updated_at DESC")
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
    @parent_user = params[:parent_user]
    @user = User.new
    @user.parent_id = @parent_user[:id]
    @user.build_user_ext

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /members/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /members
  # POST /members.json
  def create
    @user = User.new(member_params)

    respond_to do |format|
      if @user.save
        flash[:notice] = "#{@user.login} を登録しました！"
        redirect_back_or_default new_user_url

        # format.html { redirect_to @user, notice: 'Member was successfully created.' }
        # format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /members/1
  # PUT /members/1.json
  def update
    @user = User.find(params[:id])
    p params

    respond_to do |format|
      if @user.update_attributes(member_params)
        format.html { redirect_to member_path(@user), notice: '更新しました.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
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
    @user.destroy

    respond_to do |format|
      format.html { redirect_to members_url }
      format.json { head :no_content }
    end
  end


private
  def page_title
    @page_title = "親戚データ"
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def member_params
      params.require(:user).permit(:username, :familyname, :givenname, :root11, :generation, :role, :email, :password, :password_confirmation, :remember_me, :last_request_at, :parent_id, user_ext_attributes: [:image])
  end

  def user_ext_params
      params.require(:user_ext).permit(:familyname, :givenname, :nickname, :sex, :blood, :email, :addr1, :addr2, :addr3, :addr4, :addr_from, :birth_day, :job, :hobby, :skill, :free_text, :image, :character, :jiman, :dream, :sonkei, :kyujitsu, :myboom, :fav_food, :unfav_food, :fav_movie, :fav_book, :fav_sports, :fav_music, :fav_game, :fav_brand, :hosii, :ikitai, :yaritai, :user_id)
  end

end
