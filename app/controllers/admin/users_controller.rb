class Admin::UsersController < ApplicationController
  def new
    @user = User.new
  end

  def edit
    @user = User.new(user_path)

    if @user.save
      redirect_to admin_user_url(@user), notice: "ユーザー「#{@user.name}」を登録しました"
    else
      render :new
    end
  end

  def show
  end

  def index
  end

  private

  def user_params
    params.require(:user).permit(:name, :email,:admin, :password, :password_confirmation)
  end
end
