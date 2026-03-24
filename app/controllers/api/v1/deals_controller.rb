# frozen_string_literal: true

module Api
  module V1
    class DealsController < BaseController
      before_action :set_deal, only: %i[show update destroy]

      def index
        scope = Deal.includes(:company, :contact).order(updated_at: :desc)
        scope = scope.where(company_id: params[:company_id]) if params[:company_id].present?
        render json: scope.map { |d| deal_json(d) }
      end

      def show
        render json: deal_json(@deal)
      end

      def create
        deal = Deal.new(deal_params)
        if deal.save
          render json: deal_json(deal), status: :created
        else
          render json: { errors: deal.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @deal.update(deal_params)
          render json: deal_json(@deal)
        else
          render json: { errors: @deal.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @deal.destroy
        head :no_content
      end

      private

      def set_deal
        @deal = Deal.find(params[:id])
      end

      def deal_params
        params.require(:deal).permit(:company_id, :contact_id, :name, :amount_cents, :currency, :stage, :probability, :expected_close_on)
      end

      def deal_json(d)
        d.as_json(only: %i[id company_id contact_id name amount_cents currency stage probability expected_close_on created_at updated_at])
          .merge(
            "company_name" => d.company&.name,
            "contact_name" => d.contact&.full_name,
            "amount_decimal" => d.amount_decimal
          )
      end
    end
  end
end
