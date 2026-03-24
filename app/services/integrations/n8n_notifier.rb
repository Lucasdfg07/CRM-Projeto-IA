# frozen_string_literal: true

require "net/http"
require "openssl"
require "json"

module Integrations
  class N8nNotifier
    def self.deliver(action:, resource:, id:, attributes: nil, changes: nil)
      url = ENV["N8N_WEBHOOK_URL"].to_s.strip
      return if url.blank?

      secret = ENV["N8N_WEBHOOK_SECRET"].to_s.presence
      payload = {
        source: "aiox_crm",
        action: action,
        resource: resource,
        id: id,
        attributes: attributes,
        changed_keys: changes,
        sent_at: Time.current.iso8601
      }.compact

      json = JSON.generate(payload)
      uri = URI.parse(url)
      req = Net::HTTP::Post.new(uri.request_uri)
      req["Content-Type"] = "application/json"
      req["X-CRM-Signature"] = webhook_signature(json, secret) if secret

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(req, json)
      end
    rescue StandardError => e
      Rails.logger.error("[N8nNotifier] #{e.class}: #{e.message}")
    end

    def self.webhook_signature(payload, secret)
      "sha256=#{OpenSSL::HMAC.hexdigest('sha256', secret, payload)}"
    end
  end
end
