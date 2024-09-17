class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!

  def configure_permitted_parameters
    # Permit username for sign up
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])

    # Permit username for account update
    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
  end

end
