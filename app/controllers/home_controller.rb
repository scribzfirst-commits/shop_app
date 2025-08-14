class HomeController < ApplicationController

  def index
     @products = Product.all
  end

  def edituser
    # You can load the current user here if needed
    @user = current_user
  end

  def updateuser
    if current_user.update(user_params)
      redirect_to root_path, notice: "Profile updated successfully!"
    else
      flash.now[:alert] = "Failed to update profile."
      render :edituser
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :avatar)
  end

end
