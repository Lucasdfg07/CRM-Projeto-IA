# frozen_string_literal: true

module Api
  module V1
    class ContactsController < BaseController
      before_action :set_contact, only: %i[show update destroy]

      def index
        scope = Contact.includes(:company).order(created_at: :desc)
        scope = scope.where(company_id: params[:company_id]) if params[:company_id].present?
        render json: scope.map { |c| contact_json(c) }
      end

      def show
        render json: contact_json(@contact)
      end

      def create
        contact = Contact.new(contact_params)
        if contact.save
          render json: contact_json(contact), status: :created
        else
          render json: { errors: contact.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @contact.update(contact_params)
          render json: contact_json(@contact)
        else
          render json: { errors: @contact.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @contact.destroy
        head :no_content
      end

      private

      def set_contact
        @contact = Contact.find(params[:id])
      end

      def contact_params
        params.require(:contact).permit(:company_id, :first_name, :last_name, :email, :phone, :title, :lifecycle_stage)
      end

      def contact_json(c)
        c.as_json(only: %i[id company_id first_name last_name email phone title lifecycle_stage created_at updated_at])
          .merge("company_name" => c.company&.name)
      end
    end
  end
end
