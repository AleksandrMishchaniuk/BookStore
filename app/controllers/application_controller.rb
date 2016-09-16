class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale
  before_filter :set_request_environment
  before_filter :set_session_environment
  before_action :define_order_in_progress
  after_action :save_order_in_progress
  after_filter :store_location
  rescue_from CanCan::AccessDenied do |exception|
      redirect_to main_app.forbidden_path
  end

  attr_accessor :order

  def change_locale
    route = Rails.application.routes.recognize_path(request.referer)
    route[:locale] = params[:locale]
    session[:locale] = params[:locale]
    redirect_to route
  end

  protected

  def define_order_in_progress
    @order ||= order_factory.order
    @order.persist_strategy = order_factory.persist_strategy(@order)
  end

  def save_order_in_progress
    @order.keep_strategy = order_factory.keep_strategy(@order)
    @order.keep_by_strategy
  end

  def order_factory
    @order_factory ||= OrderFactory.new(self)
  end

  def set_request_environment
    Thread.current[:request] = request
  end
  def set_session_environment
    Thread.current[:session] = session
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
  def default_url_options
    { locale: I18n.locale }
  end

  # Devise hooks
  def after_sign_out_path_for(resource_or_scope)
    request.referrer || root_locale_path
  end

  def after_sign_in_path_for(resource)
    url = session[:previous_url] || root_locale_path
    route = Rails.application.routes.recognize_path(url)
    route[:locale] = session[:locale] || I18n.locale
    Rails.application.routes.generate_extras(route)[0]
  end

  def store_location
    return unless request.get?
    if (request.path != main_app.new_user_session_path &&
        request.path != main_app.new_user_registration_path &&
        request.path != main_app.new_user_password_path &&
        request.path != main_app.edit_user_password_path &&
        request.path != main_app.new_user_unlock_path &&
        request.path != "/users/confirmation" &&
        request.path != main_app.destroy_user_session_path &&
        request.path != main_app.change_locale_path &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath
    end
  end

end
