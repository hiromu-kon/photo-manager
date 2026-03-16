class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def current_user
    return nil unless session[:user_id]

    @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_login
    return if current_user

    redirect_to root_path
  end
end
