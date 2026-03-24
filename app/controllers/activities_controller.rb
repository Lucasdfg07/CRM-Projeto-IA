# frozen_string_literal: true

class ActivitiesController < ApplicationController
  before_action :set_activity, only: %i[show edit update destroy]

  def index
    @activities = Activity.includes(:contact, :deal, :user).order(occurred_at: :desc).limit(100)
  end

  def show
  end

  def new
    @activity = Activity.new(
      contact_id: params[:contact_id],
      deal_id: params[:deal_id],
      user_id: current_user.id,
      kind: "note"
    )
  end

  def create
    @activity = Activity.new(activity_params)
    @activity.user_id ||= current_user.id
    if @activity.save
      redirect_to activities_path, notice: "Atividade registrada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @activity.update(activity_params)
      redirect_to @activity, notice: "Atividade atualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @activity.destroy
    redirect_to activities_path, notice: "Atividade excluída."
  end

  private

  def set_activity
    @activity = Activity.find(params[:id])
  end

  def activity_params
    params.require(:activity).permit(:contact_id, :deal_id, :user_id, :kind, :subject, :body, :occurred_at)
  end
end
