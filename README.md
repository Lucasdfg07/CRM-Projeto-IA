<h1 align="center">
  <br>
  AIOX CRM
  <br>
</h1>

<p align="center">
  CRM comercial moderno, construído com Ruby on Rails, integrado ao N8N para automação de workflows e governado pelo método AIOX.
</p>

<p align="center">
  <img alt="Ruby" src="https://img.shields.io/badge/Ruby-3.4.8-CC342D?style=flat-square&logo=ruby&logoColor=white"/>
  <img alt="Rails" src="https://img.shields.io/badge/Rails-7.1.6-CC0000?style=flat-square&logo=rubyonrails&logoColor=white"/>
  <img alt="Tailwind CSS" src="https://img.shields.io/badge/Tailwind_CSS-v4-06B6D4?style=flat-square&logo=tailwindcss&logoColor=white"/>
  <img alt="License" src="https://img.shields.io/badge/license-MIT-blue?style=flat-square"/>
  <img alt="AIOX" src="https://img.shields.io/badge/AIOX-Governed-8B5CF6?style=flat-square"/>
</p>

---

## Sobre o Projeto

O **AIOX CRM** é uma plataforma de gestão de relacionamento com o cliente (CRM) desenvolvida para times comerciais que precisam de rastreabilidade completa do pipeline de vendas. Construído com **Ruby on Rails 7.1**, oferece uma interface web responsiva, uma API REST completa e integração nativa com **N8N** para automação de follow-ups, notificações e workflows personalizados.

O projeto segue o **método AIOX** — um framework de desenvolvimento orientado a histórias com agentes especializados de IA — garantindo qualidade, segurança e manutenibilidade profissionais.

---

## Funcionalidades

### Gestão Comercial
- **Empresas** — Cadastro completo com setor, website e notas
- **Contatos** — Vinculados a empresas, com lifecycle stage (`lead → prospect → customer → churned`)
- **Negócios (Deals)** — Pipeline com estágios configuráveis (`qualification → proposal → negotiation → won/lost`), valor em R$ e probabilidade de fechamento
- **Atividades** — Registro de ligações, e-mails, reuniões, notas e tarefas

### Dashboard
- Contadores em tempo real: empresas, contatos, negócios abertos, atividades da semana
- Breakdown do pipeline por estágio
- Timeline das últimas atividades

### Autenticação & Controle de Acesso
- Login com e-mail e senha (BCrypt)
- Papéis de usuário: `admin` e `member`
- Primeiro cadastro automaticamente vira administrador

### API REST v1
- Endpoints completos para Companies, Contacts, Deals e Activities
- Autenticação via **Bearer Token** (`CRM_API_TOKEN`)
- Validação em tempo constante (proteção contra timing attacks)
- Filtros por relacionamento (`company_id`, `contact_id`, `deal_id`)
- Suporte a CORS configurável

### Integração N8N
- Broadcasting automático de eventos via **Webhooks** em `create`, `update` e `destroy`
- Payload padronizado: `source`, `action`, `resource`, `id`, `attributes`, `changed_keys`, `sent_at`
- Assinatura **HMAC-SHA256** opcional (`N8N_WEBHOOK_SECRET`) para verificação de autenticidade
- Entrega assíncrona via **ActiveJob** (não bloqueia a requisição)

### CLI & Rake Tasks
```bash
rake crm:stats      # JSON com contadores do pipeline
rake crm:ping_n8n   # Testa o webhook N8N
rake crm:api_token  # Gera um token seguro para CRM_API_TOKEN
```

---

## Stack Tecnológica

| Camada | Tecnologia |
|--------|-----------|
| Linguagem | Ruby 3.4.8 |
| Framework | Ruby on Rails 7.1.6 |
| Banco de dados | SQLite3 |
| Frontend | Hotwire (Turbo + Stimulus) |
| Estilização | Tailwind CSS v4 |
| Autenticação | BCrypt (`has_secure_password`) |
| API | ActionController::API + Token Auth |
| Jobs | ActiveJob (async em dev, configurável em prod) |
| CORS | Rack CORS |
| Containerização | Docker (multi-stage build) |
| Variáveis de ambiente | dotenv-rails |
| Servidor web | Puma |

---

## Arquitetura

```
aiox_crm/
├── app/
│   ├── controllers/
│   │   ├── api/v1/          # API REST com Bearer Token
│   │   ├── application_controller.rb
│   │   ├── dashboard_controller.rb
│   │   ├── sessions_controller.rb
│   │   ├── companies_controller.rb
│   │   ├── contacts_controller.rb
│   │   ├── deals_controller.rb
│   │   └── activities_controller.rb
│   ├── models/
│   │   ├── concerns/
│   │   │   └── n8n_broadcastable.rb   # Concern de integração N8N
│   │   ├── user.rb
│   │   ├── company.rb
│   │   ├── contact.rb
│   │   ├── deal.rb
│   │   └── activity.rb
│   ├── jobs/
│   │   └── integrations/
│   │       └── n8n_notify_job.rb      # Job assíncrono para N8N
│   └── services/
│       └── integrations/
│           └── n8n_notifier.rb        # Serviço de entrega de webhooks
├── config/
│   ├── routes.rb
│   ├── initializers/cors.rb
│   └── locales/pt-BR.yml
├── db/
│   ├── schema.rb
│   ├── migrate/
│   └── seeds.rb
├── lib/tasks/crm.rake
├── docs/stories/                      # Histórias AIOX
├── Dockerfile
└── .env.example
```

---

## Modelo de Dados

```
User ──────────────────────────────────────────────┐
                                                   │
Company ──── Contact ──── Deal ──── Activity ◄─────┘
    │              │          │
    └──────────────┘          │
          has_many             └── belongs_to (optional)
```

| Entidade | Campos principais |
|----------|-----------------|
| `User` | email, password_digest, role (admin/member) |
| `Company` | name, sector, website, notes |
| `Contact` | first_name, last_name, email, phone, title, lifecycle_stage |
| `Deal` | name, amount_cents, currency, stage, probability, expected_close_on |
| `Activity` | kind (call/email/meeting/note/task), subject, body, occurred_at |

---

## Configuração e Instalação

### Pré-requisitos

- Ruby 3.4.8
- Bundler
- Node.js (para Tailwind)
- SQLite3

### Instalação

```bash
# Clone o repositório
git clone https://github.com/Lucasdfg07/CRM-Projeto-IA.git
cd CRM-Projeto-IA

# Instale as dependências
bundle install

# Configure as variáveis de ambiente
cp .env.example .env
# Edite o .env com seus valores

# Configure o banco de dados
bin/rails db:create db:migrate db:seed

# Inicie o servidor de desenvolvimento
bin/foreman start -f Procfile.dev
```

Acesse em: `http://localhost:3000`

**Login padrão (seeds):**
- Email: `admin@aiox.local`
- Senha: definida em `SEED_ADMIN_PASSWORD` (default: `troque-esta-senha`)

### Com Docker

```bash
docker build -t aiox-crm .
docker run -p 3000:3000 --env-file .env aiox-crm
```

---

## Variáveis de Ambiente

Copie `.env.example` para `.env` e preencha:

```env
# API REST — token de autenticação Bearer
CRM_API_TOKEN=seu-token-seguro-aqui  # gere com: rake crm:api_token

# N8N — integração de webhooks (opcional)
N8N_WEBHOOK_URL=https://sua-instancia-n8n.com/webhook/crm
N8N_WEBHOOK_SECRET=seu-hmac-secret  # opcional, para verificação HMAC

# CORS — origens permitidas para a API
CORS_ORIGINS=*

# Seeds
SEED_ADMIN_PASSWORD=senha-forte-aqui
```

---

## API REST

Base URL: `/api/v1`

Autenticação: `Authorization: Bearer <CRM_API_TOKEN>`

### Endpoints

| Método | Rota | Descrição |
|--------|------|-----------|
| `GET` | `/api/v1/companies` | Listar empresas |
| `POST` | `/api/v1/companies` | Criar empresa |
| `GET` | `/api/v1/companies/:id` | Detalhes da empresa |
| `PATCH` | `/api/v1/companies/:id` | Atualizar empresa |
| `DELETE` | `/api/v1/companies/:id` | Remover empresa |
| `GET` | `/api/v1/contacts?company_id=X` | Listar contatos (filtro opcional) |
| `GET` | `/api/v1/deals?company_id=X` | Listar negócios (filtro opcional) |
| `GET` | `/api/v1/activities?contact_id=X&deal_id=Y` | Listar atividades (filtros opcionais) |

### Exemplo de requisição

```bash
curl -H "Authorization: Bearer seu-token" \
     https://seu-dominio.com/api/v1/companies
```

---

## Integração N8N

O CRM envia automaticamente eventos para o N8N sempre que um registro é criado, atualizado ou removido.

### Payload enviado

```json
{
  "source": "aiox_crm",
  "action": "create",
  "resource": "contact",
  "id": 42,
  "attributes": { "first_name": "Lucas", "lifecycle_stage": "lead" },
  "changed_keys": [],
  "sent_at": "2026-03-24T12:00:00Z"
}
```

### Verificação HMAC

Se `N8N_WEBHOOK_SECRET` estiver configurado, o CRM envia o header:
```
X-CRM-Signature: sha256=<hmac-hex>
```

---

## Testes

```bash
# Rodar todos os testes
bin/rails test

# Rodar testes de sistema
bin/rails test:system
```

---

## Método AIOX

Este projeto é governado pelo **AIOX** — framework de desenvolvimento orientado a histórias com agentes especializados de IA:

- `@architect` — Decisões de arquitetura e stack
- `@dev` — Implementação de features
- `@qa` — Qualidade e testes
- `@data-engineer` — Schema e otimização de dados
- `@devops` — CI/CD e infraestrutura

As histórias de desenvolvimento ficam em `docs/stories/`.

---

## Roadmap

- [ ] Autorização granular por role (admin vs member)
- [ ] Testes unitários e de integração completos
- [ ] GitHub Actions (CI/CD)
- [ ] Paginação e busca
- [ ] Exportação CSV/PDF
- [ ] Notificações por e-mail (Action Mailer)
- [ ] Troca de SQLite por PostgreSQL em produção

---

## Licença

Distribuído sob a licença MIT. Veja `LICENSE` para mais informações.

---

<p align="center">
  Construído com o método <strong>AIOX</strong> · Synkra
</p>
