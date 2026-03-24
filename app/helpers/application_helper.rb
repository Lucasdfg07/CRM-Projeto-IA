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
end
