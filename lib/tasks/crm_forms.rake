# frozen_string_literal: true

namespace :crm do
  namespace :forms do
    desc "Listar formulários (CLI-first)"
    task list: :environment do
      puts Form.order(created_at: :desc).map { |f|
        {
          id: f.id,
          name: f.name,
          slug: f.slug,
          enabled: f.enabled,
          target_segment_id: f.target_segment_id,
          responses: f.form_responses.count
        }
      }.to_json
    end

    desc "Exportar respostas de um formulário em JSON"
    task :export, [:form_id] => :environment do |_t, args|
      form_id = args[:form_id].to_i
      if form_id.zero?
        puts "Uso: bin/rails crm:forms:export[form_id]"
        exit 1
      end

      form = Form.includes(form_fields: [], form_responses: [:form_answers]).find_by(id: form_id)
      unless form
        puts "Form não encontrado: #{form_id}"
        exit 1
      end

      fields = form.form_fields.order(:position).map { |ff| { id: ff.id, label: ff.label, type: ff.field_type } }
      responses = form.form_responses.order(created_at: :desc).limit(500).map do |r|
        {
          id: r.id,
          submitted_at: r.submitted_at&.iso8601,
          email: r.email,
          contact_id: r.contact_id,
          segment_id: r.segment_id,
          answers: r.form_answers.each_with_object({}) { |a, h| h[a.form_field_id] = a.value }
        }
      end

      puts({ form: { id: form.id, name: form.name, slug: form.slug }, fields: fields, responses: responses }.to_json)
    end

    desc "Definir/atualizar segmento alvo de um formulário"
    task :set_segment, [:form_id, :segment_id] => :environment do |_t, args|
      form_id = args[:form_id].to_i
      segment_id = args[:segment_id].to_i

      if form_id.zero? || segment_id.zero?
        puts "Uso: bin/rails crm:forms:set_segment[form_id,segment_id]"
        exit 1
      end

      form = Form.find_by(id: form_id)
      seg  = Segment.find_by(id: segment_id)
      unless form && seg
        puts "Form/Segmento inválido."
        exit 1
      end

      form.update!(target_segment: seg)
      puts "OK: form #{form.id} agora segmenta para #{seg.id} (#{seg.name})"
    end
  end
end

