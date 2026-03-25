# frozen_string_literal: true

class EmailProvidersController < ApplicationController
  before_action :set_provider, only: %i[show edit update destroy test_connection set_default]

  def index
    @providers = EmailProvider.order(is_default: :desc, name: :asc)
  end

  def show
  end

  def new
    @provider = EmailProvider.new(provider_type: "smtp", port: 587, starttls: true)
  end

  def edit
  end

  def create
    @provider = EmailProvider.new(provider_params.except(:smtp_password_input))
    @provider.smtp_password = params.dig(:email_provider, :smtp_password_input)
    if @provider.save
      redirect_to email_providers_path, notice: "Provedor criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @provider.assign_attributes(provider_params.except(:smtp_password_input))
    pw = params.dig(:email_provider, :smtp_password_input)
    @provider.smtp_password = pw if pw.present?
    if @provider.save
      redirect_to email_providers_path, notice: "Provedor atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @provider.destroy
    redirect_to email_providers_path, notice: "Provedor removido."
  end

  def test_connection
    result = EmailProviders::ConnectionTester.new(@provider).test
    if result[:success]
      redirect_to email_providers_path, notice: result[:message]
    else
      redirect_to email_providers_path, alert: result[:message]
    end
  end

  def set_default
    @provider.update!(is_default: true)
    redirect_to email_providers_path, notice: "#{@provider.name} definido como padrão."
  end

  private

  def set_provider
    @provider = EmailProvider.find(params[:id])
  end

  def provider_params
    params.require(:email_provider).permit(
      :name, :provider_type, :host, :port, :username,
      :from_name, :from_email, :ssl, :starttls, :is_default, :enabled
    )
  end
end
