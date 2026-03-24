# frozen_string_literal: true

module Integrations
  class N8nNotifyJob < ApplicationJob
    queue_as :default

    def perform(action:, resource:, id:, attributes: nil, changes: nil)
      Integrations::N8nNotifier.deliver(action: action, resource: resource, id: id, attributes: attributes, changes: changes)
    end
  end
end
