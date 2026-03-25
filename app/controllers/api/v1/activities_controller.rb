# frozen_string_literal: true

module Api
  module V1
    class ActivitiesController < BaseController
      before_action :set_activity, only: %i[show update destroy]

      def index
        scope = Activity.includes(:contact, :deal, :user).order(occurred_at: :desc)
        scope = scope.where(contact_id: params[:contact_id]) if params[:contact_id].present?
        scope = scope.where(deal_id: params[:deal_id]) if params[:deal_id].present?
        render json: paginate(scope).map { |a| activity_json(a) }
      end

      def show
        render json: activity_json(@activity)
      end

      def create
        activity = Activity.new(activity_params)
        if activity.save
          render json: activity_json(activity), status: :created
        else
          render json: { errors: activity.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @activity.update(activity_params)
          render json: activity_json(@activity)
        else
          render json: { errors: @activity.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @activity.destroy
        head :no_content
      end

      private

      def set_activity
        @activity = Activity.find(params[:id])
      end

      def activity_params
        params.require(:activity).permit(:contact_id, :deal_id, :user_id, :kind, :subject, :body, :occurred_at)
      end

      def activity_json(a)
        a.as_json(only: %i[id contact_id deal_id user_id kind subject body occurred_at created_at updated_at])
          .merge(
            "contact_name" => a.contact&.full_name,
            "deal_name" => a.deal&.name
          )
      end
    end
  end
end
