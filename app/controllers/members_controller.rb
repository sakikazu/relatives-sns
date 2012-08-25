# -*- coding: utf-8 -*-
class MembersController < ApplicationController
  before_filter :authenticate_user!

  # GET /members
  # GET /members.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
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
    @user = User.new(params[:member])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'Member was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
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

    respond_to do |format|
      if @user.update_attributes(params[:member])
        format.html { redirect_to @user, notice: 'Member was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
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
end
