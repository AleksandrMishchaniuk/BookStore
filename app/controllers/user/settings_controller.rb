class User::SettingsController < ApplicationController
  before_action :authenticate_user!

  def edit
    define_variables
  end

  def billing_address
    @billing_address = Address.new(address_params :billing)
    if @billing_address.valid?
      (current_user.billing_address)? current_user.billing_address.update(address_params :billing):
                                      current_user.billing_address = @billing_address
      redirect_to edit_user_settings_path
    else
      define_variables
      render :edit
    end
  end

  def shipping_address
    @shipping_address = Address.new(address_params :shipping)
    if @shipping_address.valid?
      (current_user.shipping_address)? current_user.shipping_address.update(address_params :shipping):
                                       current_user.shipping_address = @shipping_address
      redirect_to edit_user_settings_path
    else
      define_variables
      render :edit
    end
  end

  def email
    if current_user.update(user_params)
      redirect_to edit_user_settings_path
    else
      current_user.reload
      define_variables
      render :edit
    end
  end

  def password
    if current_user.update_with_password(user_params)
      bypass_sign_in current_user
      redirect_to edit_user_settings_path, notice: 'password was changed'
    else
      current_user.reload
      define_variables
      render :edit
    end
  end

  def remove_user
    if params[:confirm] && current_user.destroy
      redirect_to new_user_session_path, notice: 'account was deleted'
    else
      redirect_to edit_user_settings_path, alert: "You should check \"I understand that all data will be lost\""
    end
  end

  protected

  def address_params(type)
    params.require(:user).require(type).require(:address).permit(:first_name, :last_name,
          :address_line, :city, :country, :zip, :phone)
  end

  def user_params
    params.require(:user).permit(:email, :current_password, :password, :password_confirmation)
  end

  def define_variables
    @user ||= current_user
    @billing_address ||= current_user.billing_address || Address.new
    @shipping_address ||= current_user.shipping_address || Address.new
    @email ||= current_user.email
  end

end
