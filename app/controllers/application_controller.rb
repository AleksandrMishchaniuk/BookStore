class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_request_environment
  before_action :define_order_in_progress
  after_filter :store_location
  rescue_from CanCan::AccessDenied do |exception|
      redirect_to main_app.root_path, :alert => exception.message
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

  def order
    @order
  end

  def set_request_environment
    Thread.current[:request] = request
  end

  def after_sign_out_path_for(resource_or_scope)
    request.referrer || root_path
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  def store_location
    return unless request.get?
    if (request.path != "/users/sign_in" &&
        request.path != "/users/sign_up" &&
        request.path != "/users/password/new" &&
        request.path != "/users/password/edit" &&
        request.path != "/users/confirmation" &&
        request.path != "/users/sign_out" &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath
    end
  end
end
