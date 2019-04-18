class UserSessionsController < ApplicationController
  skip_before_action :require_login, except: [:destroy]

  def new
    @user = User.new
  end

  def create
    if @user = login(params[:email], params[:password], params[:remember])
      cookies.encrypted[:user_id] = current_user.id
      redirect_back_or_to('/presenter', notice: 'Login successful')
    else
      flash.now[:alert] = 'Login failed'
      render action: 'new'
    end
  end

  def destroy
    logout
    cookies.encrypted[:user_id] = nil
    redirect_to(:login, notice: 'Logged out!')
  end
end
