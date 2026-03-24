# frozen_string_literal: true

# N8N e outros clientes HTTP em origens diferentes (configure CORS_ORIGINS no .env)

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*Array(ENV.fetch("CORS_ORIGINS", "*").split(",").map(&:strip)))
    resource "/api/*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      credentials: false
  end
end
