# frozen_string_literal: true

module Api
  module V1
    # Ingestão de leads vindos do n8n (WhatsApp + agente de IA). Aceita objeto único ou array.
    class N8nLeadsController < BaseController
      def create
        raw = parse_json_body!
        items = normalize_items(raw)
        if items.blank?
          render json: { error: "Payload vazio ou formato não suportado." }, status: :bad_request
          return
        end

        results = []
        ActiveRecord::Base.transaction do
          items.each do |item|
            item = item.deep_stringify_keys
            company = resolve_company(item)
            result = N8n::LeadUpsert.new(company: company, payload: item).call
            results << {
              created: result[:created],
              contact: contact_json(result[:contact])
            }
          end
        end

        render json: { results: results }, status: :ok
      rescue JSON::ParserError
        render json: { error: "JSON inválido." }, status: :bad_request
      rescue ActionController::BadRequest => e
        render json: { error: e.message }, status: :bad_request
      end

      private

      def parse_json_body!
        body = request.body.read
        request.body.rewind
        raise ActionController::BadRequest, "Body vazio" if body.blank?

        JSON.parse(body)
      end

      def extract_default_company_id_from_body(raw)
        return if raw.is_a?(Array)

        raw.is_a?(Hash) ? raw["company_id"].presence || raw["companyId"].presence : nil
      end

      def normalize_items(raw)
        root_cid = extract_default_company_id_from_body(raw)
        case raw
        when Array
          raw.map { |it| inject_company_id(it, root_cid) }
        when Hash
          if raw["items"].is_a?(Array)
            return raw["items"].map { |it| inject_company_id(it, root_cid) }
          end
          if raw["leads"].is_a?(Array)
            return raw["leads"].map { |it| inject_company_id(it, root_cid) }
          end

          [inject_company_id(raw, root_cid)]
        else
          []
        end
      end

      def inject_company_id(item, root_cid)
        h = item.deep_stringify_keys
        h["company_id"] ||= root_cid if root_cid.present?
        h
      end

      # Não use Company.find sem contexto: vira 404 genérico ("Não encontrado") e confunde o n8n.
      def resolve_company(item)
        cid = item["company_id"].presence ||
              params[:company_id].presence ||
              ENV["CRM_N8N_DEFAULT_COMPANY_ID"].presence
        if cid.blank?
          return Company.first if Company.count == 1

          raise ActionController::BadRequest,
                "Informe company_id no JSON do lead (ou no envelope { \"company_id\": N, \"leads\": [...] }), " \
                "ou na URL (?company_id=N), ou defina CRM_N8N_DEFAULT_COMPANY_ID no servidor " \
                "(há mais de uma empresa no CRM)."
        end

        company = Company.find_by(id: cid)
        unless company
          raise ActionController::BadRequest,
                "Empresa id=#{cid.inspect} não existe. Use um id válido de /api/v1/companies."
        end

        company
      end

      def contact_json(c)
        c.as_json(
          only: %i[
            id company_id first_name last_name email phone phone_normalized title lifecycle_stage
            lead_temperature lead_metadata external_source_id created_at updated_at
          ]
        ).merge("company_name" => c.company&.name)
      end
    end
  end
end
