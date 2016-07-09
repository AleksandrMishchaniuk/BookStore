class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_request_environment

  def set_request_environment
    Thread.current[:request] = request
  end
  rescue_from CanCan::AccessDenied do |exception|
      redirect_to main_app.root_path, :alert => exception.message
  end

end
