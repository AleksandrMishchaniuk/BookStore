class User::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    @auth = SocAuth.where(uid: data[:uid], provider: data[:provider]).first()
    unless @auth
      @user = User.find_or_create_by!(email: data[:info][:email]) do |user|
                user.password = Devise.friendly_token[0,20]
              end
      @auth = SocAuth.create!(
                uid: data[:uid],
                provider: data[:provider],
                user_id: @user.id,
                data: {
                  first_name: extra_data(data, :first_name),
                  last_name: extra_data(data, :last_name)
                }
      )
    end
    sign_in_and_redirect @auth.user
  rescue Exception => e
    # byebug
    redirect_to new_user_session_path(locale: session[:locale]), alert: t('oauth.msg.error')
  end

  protected

  def data
    request.env['omniauth.auth']
  end

  def extra_data(data, key)
    raise 'argument \'data\' should be kind of HashClass' unless data.kind_of? Hash
    data[:extra].try(:[], :raw_info).try(:[], key)
  end

end
