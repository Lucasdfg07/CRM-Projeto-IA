# frozen_string_literal: true

class DealsController < ApplicationController
  before_action :set_deal, only: %i[show edit update destroy]

  def index
    @deals = Deal.includes(:company, :contact).order(updated_at: :desc)
  end

  def show
  end

  def new
    @deal = Deal.new(company_id: params[:company_id])
  end

  def edit
  end

  def create
    @deal = Deal.new(deal_params)
    if @deal.save
      redirect_to @deal, notice: "Negócio criado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @deal.update(deal_params)
      redirect_to @deal, notice: "Negócio atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @deal.destroy
    redirect_to deals_path, notice: "Negócio removido."
  end

  private

  def set_deal
    @deal = Deal.find(params[:id])
  end

  def deal_params
    raw = params.require(:deal).permit(:company_id, :contact_id, :name, :amount_reais, :currency, :stage, :probability, :expected_close_on)
    if raw[:amount_reais].present?
      raw[:amount_cents] = (raw.delete(:amount_reais).to_s.tr(",", ".").to_d * 100).round
    end
    raw
  end
end
