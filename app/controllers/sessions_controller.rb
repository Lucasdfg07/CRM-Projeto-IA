# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :require_login,        only: %i[new create]
  skip_before_action :check_session_timeout, only: %i[new create]

  def new
  end

  def create
    user = User.find_by(email: params[:email].to_s.downcase.strip)

    if user&.authenticate(params[:password])
      # Proteção contra Session Fixation: gera novo ID de sessão antes de autenticar
      reset_session
      session[:user_id] = user.id
      session[:last_active_at] = Time.current.iso8601
      redirect_to root_path, notice: "Bem-vindo de volta."
    else
      flash.now[:alert] = "E-mail ou senha inválidos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to new_session_path, notice: "Sessão encerrada."
  end
end
