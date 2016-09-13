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

  def change_locale
    route = Rails.application.routes.recognize_path(request.referer)
    route[:locale] = params[:locale]
    session[:locale] = params[:locale]
    redirect_to route
  end

  protected

  def define_order_in_progress
    @order = Order.find(session[:order_in_progress_id]) if session[:order_in_progress_id]
    @order ||=  current_user.try(:order_in_progress) || order_from_session || Order.new
  end

  def order_from_session
    return false unless session[:cart_items]
    order = Order.new
    order.carts = session[:cart_items].map { |item| Cart.new(item) }
    order
  end

  def save_order_in_progress
    if !order.persisted?
      session_to_nil(:order_in_progress_id)
      session[:cart_items] = order.cart_items.map { |item| item.attributes }
    elsif user_signed_in?
      session_to_nil(:cart_items)
      session_to_nil(:order_in_progress_id)
      order.order_state ||= OrderState.in_progress
      current_user.orders << order unless current_user.orders.include? order
    else
      session_to_nil(:cart_items)
      session[:order_in_progress_id] = order.id
    end
  end

  def session_to_nil(key)
    session[key] = nil unless session[key].nil?
  end

  def order
    @order
  end

  def order=(var)
    @order = var
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
    request.referrer || root_locale
  end

  def after_sign_in_path_for(resource)
    url = session[:previous_url] || root_locale
    route = Rails.application.routes.recognize_path(url)
    route[:locale] = I18n.locale
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
