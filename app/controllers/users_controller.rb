# -*- coding: utf-8 -*-

# これは、db:seedからしかユーザー登録できないときの機能。既存のユーザーに対して、パスワードなどを変更することが登録となるもの。

# AdanHP4では使用していない
class UsersController < Devise::RegistrationsController
  def new
    render action: "registrations/new"
  end

  # ユーザーに新規登録はさせず、予め登録されたアカウントのパスワードを変更することがユーザー登録となる
  def create
    emsg = nil
    username = params[:user][:username]
    pass = params[:user][:password]
    pass2 = params[:user][:password_confirmation]
    user = User.find_by_username(username)
    if user.blank?
      emsg = 'このユーザー名はシステムに登録されていません。システム管理人に登録の依頼をしてください。'
    elsif pass.blank?
      emsg = 'パスワードを入力してください。'
    elsif pass != pass2
      emsg = '確認用パスワードが一致しません。'
    else
      user.update_attributes(password: pass, password_confirmation: pass2)
    end

    if emsg.blank?
      flash[:notice] = 'ユーザーの登録をしました。'
      sign_in(resource_name, user)
      # これだとエラー時にgemの方のViewを見に行ってしまう
      # respond_with user, :location => after_sign_up_path_for(user)
      redirect_to root_path
    else
      flash[:notice] = emsg
      render action: "registrations/new"
    end
  end

end


