class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
        session[:user_id] = @user.id
        redirect_to new_budget_path(from_signup: 1), notice: "会員登録が完了しました"
    else
        render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :nickname, :password, :password_confirmation)
  end
end
