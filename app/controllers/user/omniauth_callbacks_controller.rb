# :nodoc:
class User::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @auth = SocAuth.where(uid: data[:uid], provider: data[:provider]).first
    unless @auth
      @user = User.find_or_create_by!(email: data[:info][:email]) do |user|
        user.password = Devise.friendly_token[0, 20]
      end
      @auth = SocAuth.create!(
        uid: data[:uid],
        provider: data[:provider],
        user_id: @user.id,
        data: {
          first_name: data[:info][:first_name],
          last_name: data[:info][:last_name]
        }
      )
    end
    sign_in_and_redirect @auth.user
  rescue StandardError => e
    logger.error 'Facebook auth error: ' + e.message
    redirect_to new_user_session_path(locale: session[:locale]),
                alert: t('oauth.msg.error')
  end

  protected

  def data
    request.env['omniauth.auth']
  end
end
