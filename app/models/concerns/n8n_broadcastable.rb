# frozen_string_literal: true

module N8nBroadcastable
  extend ActiveSupport::Concern

  included do
    after_commit :broadcast_n8n_created, on: :create
    after_commit :broadcast_n8n_updated, on: :update
    after_commit :broadcast_n8n_destroyed, on: :destroy
  end

  private

  def broadcast_n8n_created
    Integrations::N8nNotifyJob.perform_later(
      action: "created",
      resource: self.class.name,
      id: id,
      attributes: n8n_safe_attributes
    )
  end

  def broadcast_n8n_updated
    Integrations::N8nNotifyJob.perform_later(
      action: "updated",
      resource: self.class.name,
      id: id,
      attributes: n8n_safe_attributes,
      changes: previous_changes.keys.map(&:to_s)
    )
  end

  def broadcast_n8n_destroyed
    Integrations::N8nNotifyJob.perform_later(action: "destroyed", resource: self.class.name, id: id)
  end

  def n8n_safe_attributes
    attributes.except("password_digest")
  end
end
