# frozen_string_literal: true

# =============================================================================
# Permissions Policy (antiga Feature Policy)
# =============================================================================
# Desativa acesso a APIs sensíveis do browser que um CRM não precisa.
# Impede que scripts maliciosos ativem câmera, microfone, geolocalização, etc.
# =============================================================================

Rails.application.config.permissions_policy do |policy|
  policy.camera        :none
  policy.microphone    :none
  policy.geolocation   :none
  policy.gyroscope     :none
  policy.accelerometer :none
  policy.usb           :none
  policy.payment       :none
  policy.fullscreen    :self
end
