---
template_id: story
template_name: User Story
version: 2.0
---

# STORY CRM-001: CRM profissional AIOX + integração N8N

**ID:** CRM-001 | **Epic:** EPIC-CRM-N8N
**Sprint:** 1 | **Points:** 8 | **Priority:** High
**Created:** 2026-03-24
**Status:** In Progress

---

## User Story

**Como** operador comercial,
**Quero** um CRM com API e webhooks compatível com N8N,
**Para que** possamos orquestrar follow-ups e automações com governança AIOX (CLI primeiro).

---

## Acceptance Criteria

- [x] AIOX instalado no repositório com constitution e fluxo story-driven
- [x] Modelagem: empresas, contatos, negócios, atividades, usuários
- [x] API REST JSON `/api/v1` com autenticação Bearer (`CRM_API_TOKEN`)
- [x] Eventos de persistência enviam POST opcional para `N8N_WEBHOOK_URL` (com assinatura HMAC opcional)
- [x] Tarefas `rake crm:stats`, `crm:ping_n8n`, `crm:api_token` para operação sem UI
- [x] Interface web responsiva com visual futurista (tailwind), pronta para uso profissional
- [x] Documentação de variáveis em `.env.example`

---

## Scope

Rails 7.1 + SQLite (dev) + Hotwire + Tailwind v4 via tailwindcss-rails. CORS liberado configurável para consumidores HTTP externos.

---

## Tasks

### T1 (8h)
- [x] Bootstrap Rails + AIOX + domínio CRM
- [x] API + autenticação + CORS
- [x] Jobs de webhook + concern `N8nBroadcastable`
- [x] UI cockpit + seeds demonstrativos

---

## Dev Notes

- **CLI First:** qualquer recurso novo deve expor rake task ou endpoint API antes de dependências exclusivas de UI.
- **N8N inbound:** usar `HTTP Request` com `Authorization: Bearer <CRM_API_TOKEN>` e corpo JSON aninhado (`company`, `contact`, `deal`, `activity`).
- **N8N outbound:** workflow Webhook recebe `source: aiox_crm` e campos `action`, `resource`, `id`, `attributes`.

### Testing

| Test ID | Name | Type | Priority |
|---------|------|------|----------|
| T-CRM-001 | Model validations | Unit | P1 |

---

## Definition of Done

- [x] Acceptance criteria atendidos
- [ ] Testes automatizados mínimos (opcional próxima iteração)
- [x] Documentação `.env.example` atualizada
- [x] File list revisada

---

## Dev Agent Record

### Completion Notes

Stack Rails funcional com psych 4.x pin no Windows; dotenv carrega secrets locais.

### File List

- `Gemfile`, `config/routes.rb`, `config/application.rb`, `config/initializers/cors.rb`, `config/locales/pt-BR.yml`
- `app/models/*`, `app/models/concerns/n8n_broadcastable.rb`
- `app/controllers/application_controller.rb`, `app/controllers/{dashboard,sessions,users,companies,contacts,deals,activities}_controller.rb`
- `app/controllers/api/v1/*`
- `app/services/integrations/n8n_notifier.rb`, `app/jobs/integrations/n8n_notify_job.rb`
- `app/views/**`, `app/assets/tailwind/application.css`, `app/helpers/application_helper.rb`
- `lib/tasks/crm.rake`, `db/migrate/*`, `db/seeds.rb`, `AGENTS.md`

---

## Change Log

| Date | Version | Description | Author |
|------|---------|-------------|--------|
| 2026-03-24 | 1.0 | Story criada / implementação inicial | AIOX |

---

## QA Results

_Pendente revisão formal @qa_
