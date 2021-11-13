class UsersController < ApplicationController #Контроллер пользователя

  def show # Метод вывода пользователя
    @user = User.find(params[:id])
  end

  def new # Метод создания пользователя
    @user = User.new
  end

  def create # Метод создания и сохранения пользователя 
    @user = User.new(user_params)
    if @user.save # Вход в лк, если пользователь сохранен
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else # Если пользватель не сохранен, создается новый пользователь
      render 'new'
    end
  end

  private

    def user_params # Метод передачи данных пользователя
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
