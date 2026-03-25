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

      def normalize_items(raw)
        case raw
        when Array
          raw
        when Hash
          return raw["items"] if raw["items"].is_a?(Array)
          return raw["leads"] if raw["leads"].is_a?(Array)

          [raw]
        else
          []
        end
      end

      def resolve_company(item)
        cid = item["company_id"].presence || ENV["CRM_N8N_DEFAULT_COMPANY_ID"].presence
        raise ActiveRecord::RecordNotFound, "company_id ausente (informe no JSON ou CRM_N8N_DEFAULT_COMPANY_ID)" if cid.blank?

        Company.find(cid)
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
