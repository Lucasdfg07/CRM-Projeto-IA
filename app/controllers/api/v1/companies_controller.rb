# frozen_string_literal: true

module Api
  module V1
    class CompaniesController < BaseController
      before_action :set_company, only: %i[show update destroy]

      def index
        companies = Company.order(created_at: :desc)
        render json: companies.as_json(only: %i[id name sector website notes created_at updated_at])
      end

      def show
        render json: @company.as_json(only: %i[id name sector website notes created_at updated_at])
      end

      def create
        company = Company.new(company_params)
        if company.save
          render json: company.as_json(only: %i[id name sector website notes created_at updated_at]), status: :created
        else
          render json: { errors: company.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @company.update(company_params)
          render json: @company.as_json(only: %i[id name sector website notes created_at updated_at])
        else
          render json: { errors: @company.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @company.destroy
        head :no_content
      end

      private

      def set_company
        @company = Company.find(params[:id])
      end

      def company_params
        params.require(:company).permit(:name, :sector, :website, :notes)
      end
    end
  end
end
