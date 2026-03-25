# frozen_string_literal: true

class ContactsController < ApplicationController
  before_action :set_company, except: [:index]
  before_action :set_contact, only: %i[show edit update destroy]

  def index
    @contacts = Contact.includes(:company).order(created_at: :desc)
    @contacts = apply_contact_filters(@contacts)
    @companies = Company.order(:name)
  end

  def show
  end

  def new
    @contact = @company.contacts.build
  end

  def edit
  end

  def create
    @contact = @company.contacts.build(contact_params)
    if @contact.save
      redirect_to company_contact_path(@company, @contact), notice: "Contato criado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @contact.update(contact_params)
      redirect_to company_contact_path(@company, @contact), notice: "Contato atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact.destroy
    redirect_to company_path(@company), notice: "Contato removido."
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_contact
    @contact = @company.contacts.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(:first_name, :last_name, :email, :phone, :title, :lifecycle_stage)
  end

  def apply_contact_filters(scope)
    scope = scope.where(company_id: params[:company_id]) if params[:company_id].present?

    if params[:q].present?
      term = "%#{ActiveRecord::Base.sanitize_sql_like(params[:q].strip)}%"
      scope = scope.where(
        "LOWER(contacts.first_name) LIKE LOWER(?) OR LOWER(COALESCE(contacts.last_name,'')) LIKE LOWER(?) OR LOWER(COALESCE(contacts.email,'')) LIKE LOWER(?) OR LOWER(COALESCE(contacts.phone,'')) LIKE LOWER(?)",
        term, term, term, term
      )
    end

    case params[:channel]
    when "email"
      scope = scope.merge(Contact.with_email)
    when "phone"
      scope = scope.merge(Contact.with_phone)
    when "both"
      scope = scope.merge(Contact.with_email_and_phone)
    end

    scope = scope.where(lifecycle_stage: params[:lifecycle]) if params[:lifecycle].present? && Contact::LIFECYCLES.include?(params[:lifecycle])

    scope
  end
end
