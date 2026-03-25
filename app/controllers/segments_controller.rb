# frozen_string_literal: true

class SegmentsController < ApplicationController
  before_action :set_segment, only: %i[show edit update destroy add_contacts remove_contact]

  def index
    @segments = Segment.order(:name)
  end

  def show
    @contacts = @segment.contacts.includes(:company).order(:first_name)
    @available_contacts = Contact.where.not(id: @segment.contact_ids).includes(:company).order(:first_name).limit(200)
  end

  def new
    @segment = Segment.new(color: "#6366f1")
  end

  def edit
  end

  def create
    @segment = Segment.new(segment_params)
    if @segment.save
      redirect_to @segment, notice: "Segmento criado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @segment.update(segment_params)
      redirect_to @segment, notice: "Segmento atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @segment.destroy
    redirect_to segments_path, notice: "Segmento removido."
  end

  def add_contacts
    ids = params[:contact_ids].to_a.map(&:to_i).reject(&:zero?)
    contacts = Contact.where(id: ids)
    @segment.contacts << contacts - @segment.contacts
    redirect_to @segment, notice: "#{contacts.count} contato(s) adicionado(s)."
  end

  def remove_contact
    contact = Contact.find(params[:contact_id])
    @segment.contacts.delete(contact)
    redirect_to @segment, notice: "Contato removido do segmento."
  end

  private

  def set_segment
    @segment = Segment.find(params[:id])
  end

  def segment_params
    params.require(:segment).permit(:name, :description, :color)
  end
end
