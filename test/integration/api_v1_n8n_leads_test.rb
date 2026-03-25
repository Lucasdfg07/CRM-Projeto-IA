# frozen_string_literal: true

require "test_helper"

class ApiV1N8nLeadsTest < ActionDispatch::IntegrationTest
  setup do
    @token = "test-crm-token-for-n8n"
    ENV["CRM_API_TOKEN"] = @token
    ENV["CRM_N8N_DEFAULT_COMPANY_ID"] = companies(:one).id.to_s
  end

  teardown do
    ENV.delete("CRM_API_TOKEN")
    ENV.delete("CRM_N8N_DEFAULT_COMPANY_ID")
  end

  test "rejeita sem token" do
    post "/api/v1/n8n_leads",
      params: [sample_payload].to_json,
      headers: { "Content-Type" => "application/json" }
    assert_response :unauthorized
  end

  test "cria lead a partir de array JSON (payload n8n)" do
    post "/api/v1/n8n_leads",
      params: [sample_payload].to_json,
      headers: {
        "Authorization" => "Bearer #{@token}",
        "Content-Type" => "application/json"
      }

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 1, body["results"].size
    assert body["results"].first["created"]

    c = Contact.order(:id).last
    assert_equal "morno", c.lead_temperature
    assert c.lead_metadata["n8n_last"].is_a?(Hash)
    assert_equal 1, c.activities.where(kind: "note").count
  end

  test "atualiza lead existente pelo telefone" do
    contact = contacts(:one)
    contact.update!(phone: "(11) 98888-7777", company: companies(:one))

    payload = sample_payload.merge(
      "email" => "novo@exemplo.com",
      "telefone" => "11988887777",
      "temperatura_lead" => "quente"
    )

    post "/api/v1/n8n_leads",
      params: [payload].to_json,
      headers: {
        "Authorization" => "Bearer #{@token}",
        "Content-Type" => "application/json"
      }

    assert_response :success
    contact.reload
    assert_equal "novo@exemplo.com", contact.email
    assert_equal "quente", contact.lead_temperature
  end

  private

  def sample_payload
    {
      "tipo_atendimento" => "atendimento humano",
      "entendeu_objetivo_cliente" => "Teste",
      "email" => nil,
      "telefone" => nil,
      "temperatura_lead" => "morno",
      "justificativa_temperatura" => "Teste justificativa",
      "precisa_de_mais_dados" => true,
      "dados_necessarios" => ["Cidade"],
      "mensagem_cliente" => "Oi",
      "proximo_passo" => "Coletar cidade",
      "descricao_crm" => "Descrição detalhada",
      "sugestoes_campanhas" => "Remarketing",
      "crm_payload" => {
        "justificativa_temperativa" => "Fallback typo"
      }
    }
  end
end
