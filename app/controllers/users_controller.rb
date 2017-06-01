class UsersController < ApplicationController
  def new
    @user = User.new
  end
  
  def show 
    @user = User.find(params[:id])
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      # ユーザー登録が完了したら、登録情報でログイン
      log_in @user
      
      # ユーザー登録の成功を表示して、ユーザページへ遷移
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
end
