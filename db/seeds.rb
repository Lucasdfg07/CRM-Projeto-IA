# frozen_string_literal: true

pass = ENV["SEED_ADMIN_PASSWORD"].presence || "troque-esta-senha"
token = ENV["CRM_API_TOKEN"].presence || SecureRandom.hex(32)

user = User.find_or_initialize_by(email: "admin@aiox.local")
user.password = pass
user.password_confirmation = pass
user.role = "admin"
user.save!

puts "=== AIOX CRM seed ==="
puts "Admin: #{user.email} / senha: #{pass}"
puts "Defina CRM_API_TOKEN no .env. Valor sugerido (se ainda vazio): #{token}"
puts "Copie para .env → CRM_API_TOKEN=#{token}" if ENV["CRM_API_TOKEN"].blank?

["Aurora Labs", "Nebula Ventures", "Pulse Industries"].each do |name|
  Company.find_or_create_by!(name: name) do |c|
    c.sector = "Tecnologia"
    c.website = "https://example.com"
    c.notes = "Conta demo gerada pelo seed."
  end
end

company = Company.first!
Contact.find_or_create_by!(email: "lucas@cliente.demo", company: company) do |c|
  c.first_name = "Lucas"
  c.last_name = "Demo"
  c.phone = "+55 11 99999-0000"
  c.title = "Head of Ops"
  c.lifecycle_stage = "prospect"
end

Deal.find_or_create_by!(name: "Plataforma N8N + CRM", company: company) do |d|
  d.amount_cents = 12_000_000 # R$ 120.000,00
  d.currency = "BRL"
  d.stage = "negotiation"
  d.probability = 65
  d.expected_close_on = 30.days.from_now.to_date
end

deal = Deal.find_by!(name: "Plataforma N8N + CRM")
Activity.find_or_create_by!(subject: "Kickoff comercial", contact: Contact.first!, deal: deal, kind: "meeting") do |a|
  a.user = user
  a.body = "Alinhamento de integração via API e webhooks."
  a.occurred_at = 2.days.ago
end

puts "Empresas: #{Company.count}, contatos: #{Contact.count}, negócios: #{Deal.count}."
