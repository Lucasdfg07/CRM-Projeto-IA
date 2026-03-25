# frozen_string_literal: true

require "test_helper"

class CampaignContactsForDispatchTest < ActiveSupport::TestCase
  setup do
    @company = Company.create!(name: "Co Test")
    @contact = Contact.create!(company: @company, first_name: "Ana", email: "ana@example.com")
    @segment = Segment.create!(name: "Seg Test", color: "#6366f1")
    @segment.contacts << @contact
    @campaign = Campaign.create!(
      name: "Camp Test",
      subject: "Olá",
      status: "draft",
      recipient_filter: "email"
    )
    @campaign.segments << @segment
  end

  test "contacts_for_dispatch inclui contato com e-mail no segmento" do
    assert_equal 1, @campaign.reload.contacts_for_dispatch.count
    assert_includes @campaign.contacts_for_dispatch.pluck(:id), @contact.id
  end

  test "filtro both exige e-mail e telefone" do
    @campaign.update!(recipient_filter: "both")
    assert_equal 0, @campaign.reload.contacts_for_dispatch.count
  end
end
