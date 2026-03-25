# frozen_string_literal: true

class CampaignsController < ApplicationController
  before_action :set_campaign, only: %i[show edit update destroy send_campaign preview duplicate]

  def index
    @campaigns = Campaign.includes(:email_provider, :segments).by_recent
  end

  def show
    @recipients = @campaign.campaign_recipients.order(created_at: :desc).limit(100)
  end

  def new
    @campaign  = Campaign.new(status: "draft", recipient_filter: "email")
    @providers = EmailProvider.where(enabled: true).order(:name)
    @segments  = Segment.order(:name)
  end

  def edit
    @providers = EmailProvider.where(enabled: true).order(:name)
    @segments  = Segment.order(:name)
  end

  def create
    @campaign = Campaign.new(campaign_params)
    @campaign.segment_ids = params[:campaign][:segment_ids].to_a.reject(&:blank?).map(&:to_i)
    if @campaign.save
      redirect_to @campaign, notice: "Campanha criada."
    else
      @providers = EmailProvider.where(enabled: true).order(:name)
      @segments  = Segment.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @campaign.assign_attributes(campaign_params)
    @campaign.segment_ids = params[:campaign][:segment_ids].to_a.reject(&:blank?).map(&:to_i)
    if @campaign.save
      redirect_to @campaign, notice: "Campanha atualizada."
    else
      @providers = EmailProvider.where(enabled: true).order(:name)
      @segments  = Segment.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @campaign.destroy
    redirect_to campaigns_path, notice: "Campanha removida."
  end

  def send_campaign
    unless @campaign.draft? || @campaign.scheduled?
      redirect_to @campaign, alert: "Esta campanha não pode ser enviada."
      return
    end

    if @campaign.email_provider.nil?
      redirect_to @campaign, alert: "Selecione um provedor de email antes de enviar."
      return
    end

    if @campaign.segments.empty?
      redirect_to @campaign, alert: "Adicione pelo menos um segmento antes de enviar."
      return
    end

    if @campaign.contacts_for_dispatch.none?
      redirect_to @campaign, alert: "Nenhum destinatário com e-mail no segmento com o filtro atual (e-mail / telefone)."
      return
    end

    @campaign.update!(status: "sending", sent_at: Time.current)
    Campaigns::DispatchJob.perform_later(@campaign.id)
    redirect_to @campaign, notice: "Campanha iniciada! Os emails estão sendo enviados."
  end

  def preview
    render layout: false
  end

  def duplicate
    copy = @campaign.dup
    copy.name   = "Cópia de #{@campaign.name}"
    copy.status = "draft"
    copy.sent_at = nil
    copy.total_recipients = 0
    copy.delivered_count  = 0
    copy.failed_count     = 0
    copy.save!
    copy.segment_ids = @campaign.segment_ids
    redirect_to edit_campaign_path(copy), notice: "Campanha duplicada."
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:id])
  end

  def campaign_params
    params.require(:campaign).permit(
      :name, :subject, :preview_text, :html_body,
      :email_provider_id, :from_name, :from_email, :reply_to,
      :scheduled_at, :status, :recipient_filter
    )
  end
end
