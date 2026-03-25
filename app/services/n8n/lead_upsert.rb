# frozen_string_literal: true

module N8n
  # Recebe payload do fluxo n8n (objeto ou campos mesclados com crm_payload) e cria/atualiza Contact.
  class LeadUpsert
    LEAD_TEMPERATURES = %w[frio morno quente].freeze

    def initialize(company:, payload:)
      @company = company
      @payload = normalize_payload(payload)
    end

    def call
      contact = find_or_build_contact
      was_new = contact.new_record?
      apply_attributes(contact)
      contact.save!
      attach_segment(contact)
      create_note_activity(contact)
      { contact: contact, created: was_new }
    end

    private

    def normalize_payload(raw)
      h = raw.deep_dup
      h = h.deep_symbolize_keys
      crm = h.delete(:crm_payload)
      crm = crm.deep_symbolize_keys if crm.is_a?(Hash)
      merged = (crm || {}).merge(h)
      if merged[:justificativa_temperatura].blank? && merged[:justificativa_temperativa].present?
        merged[:justificativa_temperatura] = merged.delete(:justificativa_temperativa)
      end
      merged
    end

    def find_or_build_contact
      scope = @company.contacts
      ext = extract_external_id
      if ext.present?
        found = scope.find_by(external_source_id: ext.to_s)
        return found if found
      end

      email = normalize_email(@payload[:email])
      if email.present?
        found = scope.where("lower(email) = ?", email.downcase).first
        return found if found
      end

      phone_raw = @payload[:telefone].presence || @payload[:phone].presence
      norm = Contact.normalize_phone(phone_raw)
      if norm.present?
        found = scope.find_by(phone_normalized: norm)
        return found if found
      end

      scope.new
    end

    def extract_external_id
      @payload[:external_source_id].presence ||
        @payload[:whatsapp_chat_id].presence ||
        @payload[:conversation_id].presence
    end

    def apply_attributes(contact)
      email = normalize_email(@payload[:email])
      phone = @payload[:telefone].presence || @payload[:phone].presence

      contact.company = @company
      contact.first_name = (@payload[:first_name].presence || contact.first_name.presence || default_first_name).to_s
      contact.last_name = @payload[:last_name].presence || contact.last_name
      contact.email = email if email.present?
      contact.phone = phone if phone.present?
      contact.title = @payload[:tipo_atendimento].to_s.truncate(120) if @payload[:tipo_atendimento].present?

      temp = map_temperature(@payload[:temperatura_lead])
      contact.lead_temperature = temp if temp.present?

      ext = extract_external_id
      contact.external_source_id = ext.to_s if ext.present?

      contact.lead_metadata = build_metadata(contact)

      if contact.new_record?
        st = suggest_lifecycle(temp)
        contact.lifecycle_stage = st if st.present?
      end
    end

    def default_first_name
      "Lead"
    end

    def normalize_email(val)
      val.to_s.strip.downcase.presence
    end

    def map_temperature(raw)
      s = raw.to_s.strip.downcase
      case s
      when "frio", "cold" then "frio"
      when "morno", "warm" then "morno"
      when "quente", "hot" then "quente"
      when ""
        nil
      else
        LEAD_TEMPERATURES.include?(s) ? s : nil
      end
    end

    def suggest_lifecycle(temperature)
      case temperature
      when "quente" then "prospect"
      when "morno" then "lead"
      else "lead"
      end
    end

    def build_metadata(contact)
      base = contact.lead_metadata.is_a?(Hash) ? contact.lead_metadata.stringify_keys : {}
      snapshot = @payload.stringify_keys.except("crm_payload")
      snapshot["synced_at"] = Time.current.iso8601
      base.merge("n8n_last" => snapshot)
    end

    def attach_segment(contact)
      sid = @payload[:segment_id].presence
      return if sid.blank?

      segment = Segment.find_by(id: sid)
      return unless segment

      contact.segments << segment unless contact.segments.include?(segment)
    rescue ActiveRecord::RecordInvalid
      nil
    end

    def create_note_activity(contact)
      body_parts = []
      body_parts << @payload[:descricao_crm].presence
      body_parts << @payload[:justificativa_temperatura].presence
      body_parts << @payload[:sugestoes_campanhas].presence
      body_parts << @payload[:proximo_passo].presence
      body = body_parts.compact.join("\n\n---\n\n")
      return if body.blank?

      Activity.create!(
        contact: contact,
        kind: "note",
        subject: "n8n / WhatsApp — #{@payload[:tipo_atendimento].presence || 'lead'}".truncate(500),
        body: body
      )
    end
  end
end
