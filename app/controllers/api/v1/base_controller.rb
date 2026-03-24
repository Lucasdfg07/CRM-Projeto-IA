# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      include ActionController::HttpAuthentication::Token::ControllerMethods

      before_action :authenticate_api_token!

      rescue_from ActiveRecord::RecordNotFound, with: :not_found

      private

      def authenticate_api_token!
        expected = ENV["CRM_API_TOKEN"].to_s
        if expected.blank?
          render json: { error: "CRM_API_TOKEN não configurado no servidor." }, status: :service_unavailable
          return
        end

        token = request.headers["Authorization"].to_s.delete_prefix("Bearer ").strip
        unless token.bytesize == expected.bytesize && ActiveSupport::SecurityUtils.secure_compare(token, expected)
          render json: { error: "Não autorizado" }, status: :unauthorized
        end
      end

      def not_found
        render json: { error: "Não encontrado" }, status: :not_found
      end
    end
  end
end
