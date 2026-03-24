# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper_method :current_user

  before_action :require_login

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def require_login
    return if current_user

    redirect_to new_session_path, alert: "Faça login para continuar."
  end
end
