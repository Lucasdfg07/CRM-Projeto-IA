# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper_method :current_user

  before_action :require_login
  before_action :check_session_timeout

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def require_login
    return if current_user

    redirect_to new_session_path, alert: "Faça login para continuar."
  end

  # ---------------------------------------------------------------------------
  # Timeout de sessão por inatividade
  # Padrão: 60 minutos (configurável via SESSION_TIMEOUT_MINUTES)
  # ---------------------------------------------------------------------------
  def check_session_timeout
    return unless session[:user_id]

    timeout_minutes = ENV.fetch("SESSION_TIMEOUT_MINUTES", "60").to_i
    last_active = session[:last_active_at]

    if last_active && Time.current > Time.zone.parse(last_active) + timeout_minutes.minutes
      session.delete(:user_id)
      session.delete(:last_active_at)
      redirect_to new_session_path, alert: "Sessão expirada por inatividade. Faça login novamente."
      return
    end

    session[:last_active_at] = Time.current.iso8601
  end
end
