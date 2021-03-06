class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :activate]
  before_action :require_admin, only: [:index, :destroy, :activate]
  before_action :correct_user, only: [:show, :edit, :update]
  skip_before_filter :require_login, only: [:new, :create]
  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        if ENV['RAILS_ENV'].to_s == 'production' or ENV['RAILS_ENV'].to_s == 'demo'
          UserMailer.register_email(@user)
        end
        format.html { redirect_to login_path, alert: "Account created successfully! Registration is in progress, you will get an email when the account is active" }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
      respond_to do |format|
          if @user.update(user_params_update)
            format.html { redirect_to @user, notice: 'User was successfully updated.' }
            format.json { render :show, status: :ok, location: @user }
          else
            format.html { render :edit }
            format.json { render json: @user.errors, status: :unprocessable_entity }
          end
      end
  end

  def activate
    respond_to do |format|
      if @user.update_attribute(:active, !@user.active)
        if ENV['RAILS_ENV'].to_s == 'production' or ENV['RAILS_ENV'].to_s == 'demo'
          UserMailer.welcome_email(@user)
        end
        format.html {  redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { redirect_to users_url, notice: 'User update error.' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :admin)
    end

     def user_params_update
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :admin, :active)
    end

    def correct_user
      if current_user and !current_user.admin and params[:id].to_i != current_user.id
        flash[:error] = "Rights needed"
        redirect_to(controller: 'pages', action: 'dashboard', notice: 'Rights needed!')
      end
    end

    def require_admin
      if current_user and !current_user.admin
        flash[:error] = "Admin rights needed"
        redirect_to(controller: 'pages', action: 'dashboard', notice: 'Admin rights needed!')
      end
    end

end
