# frozen_string_literal: true

class FormResponsesController < ApplicationController
  skip_before_action :require_login
  skip_before_action :check_session_timeout
  protect_from_forgery with: :exception

  before_action :set_form
  layout "public_form"

  def new
    redirect_to root_path, alert: "Formulário desabilitado." and return unless @form.enabled?
    @fields = @form.form_fields
  end

  def create
    redirect_to root_path, alert: "Formulário desabilitado." and return unless @form.enabled?

    submitted_at = Time.current
    raw_answers = params.fetch(:answers, {}).to_unsafe_h

    response = @form.form_responses.build(
      submitted_at: submitted_at,
      ip: request.remote_ip,
      user_agent: request.user_agent.to_s.truncate(255)
    )

    fields = @form.form_fields.to_a
    answers_by_field_id = {}
    fields.each do |field|
      val = raw_answers[field.id.to_s]
      val = val.to_s.strip
      next if val.blank?
      answers_by_field_id[field.id] = val
    end

    email = extract_email(fields, answers_by_field_id)
    response.email = email

    contact = upsert_contact_from_answers(email, fields, answers_by_field_id)
    if contact
      response.contact = contact
      if @form.target_segment
        response.segment = @form.target_segment
        contact.segments << @form.target_segment unless contact.segments.exists?(@form.target_segment.id)
      end
    end

    response.save!
    answers_by_field_id.each do |field_id, value|
      response.form_answers.create!(form_field_id: field_id, value: value)
    end

    redirect_to form_public_path(@form.slug), notice: "Resposta enviada com sucesso."
  rescue ActiveRecord::RecordInvalid => e
    @fields = @form.form_fields
    flash.now[:alert] = e.record.errors.full_messages.first || "Não foi possível enviar."
    render :new, status: :unprocessable_entity
  rescue StandardError
    @fields = @form.form_fields
    flash.now[:alert] = "Não foi possível enviar sua resposta. Tente novamente."
    render :new, status: :unprocessable_entity
  end

  private

  def set_form
    @form = Form.find_by!(slug: params[:slug])
  end

  def form_public_path(slug)
    "/f/#{slug}"
  end

  def extract_email(fields, answers_by_field_id)
    email_field = fields.find(&:email?)
    email = answers_by_field_id[email_field.id] if email_field
    email.to_s.strip.presence
  end

  def upsert_contact_from_answers(email, fields, answers_by_field_id)
    return nil if email.blank?

    first_name = guess_first_name(fields, answers_by_field_id, email)
    last_name  = guess_last_name(fields, answers_by_field_id)
    phone      = guess_phone(fields, answers_by_field_id)

    company = Company.find_or_create_by!(name: "Leads Web") { |c| c.sector = "Marketing" }

    contact = Contact.find_or_initialize_by(email: email)
    contact.company = company if contact.company_id.blank?
    contact.first_name = first_name if contact.first_name.blank?
    contact.last_name  = last_name  if last_name.present? && contact.last_name.blank?
    contact.phone      = phone      if phone.present? && contact.phone.blank?
    contact.lifecycle_stage = "lead" if contact.lifecycle_stage.blank?
    contact.save!
    contact
  end

  def guess_first_name(fields, answers_by_field_id, email)
    by_label = fields.find { |f| f.label.to_s.downcase.include?("nome") && f.field_type == "text" }
    name = by_label ? answers_by_field_id[by_label.id] : nil
    name = name.to_s.strip
    return name.split.first if name.present?
    email.to_s.split("@").first.to_s.split(/[.\-_]/).first.to_s.capitalize.presence || "Lead"
  end

  def guess_last_name(fields, answers_by_field_id)
    by_label = fields.find { |f| f.label.to_s.downcase.include?("sobrenome") }
    return nil unless by_label
    answers_by_field_id[by_label.id].to_s.strip.presence
  end

  def guess_phone(fields, answers_by_field_id)
    phone_field = fields.find { |f| f.field_type == "phone" || f.label.to_s.downcase.include?("telefone") }
    return nil unless phone_field
    answers_by_field_id[phone_field.id].to_s.strip.presence
  end
end

