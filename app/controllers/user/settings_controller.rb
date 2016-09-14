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
      sign_in current_user, bypass: true
      redirect_to edit_user_settings_path, notice: t('views.user.settings.password.success_msg')
    else
      current_user.reload
      define_variables
      render :edit
    end
  end

  def remove_user
    if params[:confirm]
      current_user.soc_auths.each{ |item| item.destroy! }
      current_user.destroy!
      redirect_to new_user_session_path, notice: t('views.user.settings.remove_account.success_msg')
    else
      label_confirm = t('views.user.settings.remove_account.confirm').mb_chars.capitalize
      redirect_to edit_user_settings_path, alert: t('views.user.settings.remove_account.error_msg', label: label_confirm)
    end
  rescue Exception => e
    logger.error 'Remove user error: ' + e.message
    redirect_to edit_user_settings_path, alert: t('.error')
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
    @billing_address ||= current_user.billing_address || Address.new(current_user.data)
    @shipping_address ||= current_user.shipping_address || Address.new(current_user.data)
    @email ||= current_user.email
  end

end
