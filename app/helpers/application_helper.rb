# frozen_string_literal: true

module ApplicationHelper
  def nav_class(path)
    base = "block rounded-lg px-3 py-2 transition "
    if current_page?(path)
      base + "bg-cyan-500/15 text-cyan-100 ring-1 ring-cyan-400/40"
    else
      base + "text-slate-300 hover:bg-white/5 hover:text-white"
    end
  end

  def format_money_cents(cents)
    return "—" if cents.nil?

    number_to_currency(cents / 100.0, unit: "R$ ", separator: ",", delimiter: ".")
  end

  def lifecycle_label(stage)
    I18n.t("crm.lifecycle_stages.#{stage}", default: stage.to_s.humanize)
  end

  def deal_stage_label(stage)
    I18n.t("crm.deal_stages.#{stage}", default: stage.to_s.humanize)
  end

  def activity_kind_label(kind)
    I18n.t("crm.activity_kinds.#{kind}", default: kind.to_s.humanize)
  end

  def recipient_filter_label(filter)
    I18n.t("crm.recipient_filters.#{filter}", default: filter.to_s)
  end
end
