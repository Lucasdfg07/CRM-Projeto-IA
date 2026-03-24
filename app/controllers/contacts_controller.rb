# frozen_string_literal: true

class ContactsController < ApplicationController
  before_action :set_company, except: [:index]
  before_action :set_contact, only: %i[show edit update destroy]

  def index
    @contacts = Contact.includes(:company).order(created_at: :desc)
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
end
