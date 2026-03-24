# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @counts = {
      companies: Company.count,
      contacts: Contact.count,
      deals_open: Deal.where.not(stage: %w[won lost]).count,
      activities_week: Activity.where("occurred_at >= ?", 7.days.ago).count
    }
    @pipeline = Deal.where.not(stage: %w[won lost]).group(:stage).count
    @recent_activities = Activity.includes(:contact, :deal).order(occurred_at: :desc).limit(8)
  end
end
