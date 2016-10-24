# :nodoc:
class LocaleController < ApplicationController
  def change_locale
    route = Rails.application.routes.recognize_path(request.referer)
    route[:locale] = params[:locale]
    session[:locale] = params[:locale]
    redirect_to route
  end
end
