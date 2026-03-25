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

      # -----------------------------------------------------------------------
      # Paginação segura — previne dump completo de dados e DoS
      # Uso: paginate(scope) → retorna scope paginado + meta no header
      # Parâmetros aceitos: ?page=1&per_page=25 (max 100)
      # -----------------------------------------------------------------------
      def paginate(scope)
        per_page = [[params[:per_page].to_i, 1].max, 100].min
        per_page = 25 if per_page.zero?
        page     = [params[:page].to_i, 1].max

        total   = scope.count
        records = scope.limit(per_page).offset((page - 1) * per_page)

        response.set_header("X-Total-Count",   total.to_s)
        response.set_header("X-Page",          page.to_s)
        response.set_header("X-Per-Page",      per_page.to_s)
        response.set_header("X-Total-Pages",   ((total.to_f / per_page).ceil).to_s)
        response.set_header("Access-Control-Expose-Headers",
                            "X-Total-Count, X-Page, X-Per-Page, X-Total-Pages")

        records
      end
    end
  end
end
