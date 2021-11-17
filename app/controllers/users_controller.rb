class UsersController < ApplicationController #Контроллер пользователя
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

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

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end  
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User delete"
    redirect_to users_url
  end

  private

    def user_params # Метод передачи данных пользователя
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

end