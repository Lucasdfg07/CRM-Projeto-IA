# frozen_string_literal: true

class FormsController < ApplicationController
  before_action :set_form, only: %i[show edit update destroy]

  def index
    @forms = Form.by_recent
  end

  def show
    @responses = @form.form_responses.order(created_at: :desc).limit(100)
  end

  def new
    @form = Form.new(accent_color: "#22d3ee", theme: "neo", enabled: true)
    @form.form_fields.build(label: "Seu e-mail", field_type: "email", required: true, position: 1)
    @form.form_fields.build(label: "Seu nome", field_type: "text", required: true, position: 2)
  end

  def edit
  end

  def create
    @form = Form.new(form_params)
    normalize_positions(@form)
    if @form.save
      redirect_to @form, notice: "Formulário criado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @form.assign_attributes(form_params)
    normalize_positions(@form)
    if @form.save
      redirect_to @form, notice: "Formulário atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @form.destroy
    redirect_to forms_path, notice: "Formulário removido."
  end

  private

  def set_form
    @form = Form.find(params[:id])
  end

  def form_params
    params.require(:form).permit(
      :name, :description, :slug, :theme, :accent_color, :enabled, :target_segment_id,
      form_fields_attributes: %i[id label field_type required position placeholder options _destroy]
    )
  end

  def normalize_positions(form)
    fields = form.form_fields.reject(&:marked_for_destruction?)
    fields.each_with_index { |f, idx| f.position = idx + 1 if f.position.to_i <= 0 }
  end
end

