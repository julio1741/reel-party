class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  # Handle CSRF token errors in production
  rescue_from ActionController::InvalidAuthenticityToken, with: :handle_csrf_token_error

  private

  def handle_csrf_token_error
    Rails.logger.error "CSRF token error for #{request.remote_ip}"
    redirect_to root_path, alert: 'Security token expired. Please try again.'
  end
end
