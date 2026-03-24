# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[new create]
  before_action :ensure_first_user_only, only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params.merge(role: "admin"))
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Conta criada. Você é o administrador."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def ensure_first_user_only
    return unless User.exists?

    redirect_to new_session_path, alert: "Cadastro já foi concluído."
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
