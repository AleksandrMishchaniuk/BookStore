class User::PasswordsController < Devise::PasswordsController

  protected

  def after_resetting_password_path_for(resource)
    root_locale_path
  end
end
