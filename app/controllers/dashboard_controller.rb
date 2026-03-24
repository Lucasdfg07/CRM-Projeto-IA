# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @counts = {
      companies:       Company.count,
      contacts:        Contact.count,
      deals_open:      Deal.where.not(stage: %w[won lost]).count,
      activities_week: Activity.where("occurred_at >= ?", 7.days.ago).count
    }

    @pipeline          = Deal.where.not(stage: %w[won lost]).group(:stage).count
    @recent_activities = Activity.includes(:contact, :deal).order(occurred_at: :desc).limit(8)

    # ── Chart data — últimos 30 dias ──────────────────────────────
    last_30    = 30.days.ago.to_date
    date_range = (last_30..Date.today).to_a

    @chart_labels = date_range.map { |d| d.strftime("%d/%m") }

    contacts_raw   = Contact.where("DATE(created_at) >= ?", last_30).group("DATE(created_at)").count
    deals_raw      = Deal.where("DATE(created_at) >= ?", last_30).group("DATE(created_at)").count
    activities_raw = Activity.where("DATE(occurred_at) >= ?", last_30).group("DATE(occurred_at)").count

    @contacts_by_day   = date_range.map { |d| contacts_raw[d.to_s] || 0 }
    @deals_by_day      = date_range.map { |d| deals_raw[d.to_s] || 0 }
    @activities_by_day = date_range.map { |d| activities_raw[d.to_s] || 0 }

    @activities_by_kind    = Activity::KINDS.map { |k| Activity.where(kind: k).count }
    @deals_stage_counts    = Deal::STAGES.map { |s| Deal.where(stage: s).count }
    @contacts_by_lifecycle = Contact::LIFECYCLES.map { |l| Contact.where(lifecycle_stage: l).count }

    active_stages          = Deal::STAGES.reject { |s| %w[won lost].include?(s) }
    @pipeline_value_by_stage = active_stages.map { |s| (Deal.where(stage: s).sum(:amount_cents) / 100.0).round(2) }
  end
end
