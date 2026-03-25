---
template_id: story
template_name: User Story
version: 2.0
---

# STORY CRM-002: Formulários (Typeform-like) + Leads segmentados + Campanhas

**ID:** CRM-002 | **Epic:** EPIC-CRM-N8N
**Sprint:** 1 | **Points:** 8 | **Priority:** High
**Created:** 2026-03-25
**Status:** In Progress

---

## User Story

**Como** operador comercial,
**Quero** criar formulários modernos (estilo Typeform) para captura de leads,
**Para que** eu consiga segmentar automaticamente esses contatos e disparar campanhas direcionadas no CRM.

---

## Acceptance Criteria

- [ ] CRUD de **Formulários** acessível via UI (autenticado)
- [ ] Cada Formulário tem **link público** para respostas (sem login)
- [ ] Builder permite **criar e estilizar** um formulário com aparência moderna/futurista (layout AIOX)
- [ ] Resposta do formulário cria/atualiza um **Contato** e adiciona ao **Segmento** configurado (segmentação automática)
- [ ] Respostas ficam registradas (auditoria) e associadas ao contato criado
- [ ] CLI-first: tarefas `bin/rails crm:forms:*` para operar sem UI
- [ ] Integração com Campanhas: contatos oriundos de formulários entram em segmentos e podem ser usados em `Campaigns`

---

## Scope

Rails 7.1 + Hotwire + Tailwind. Builder com campos simples (texto, email, select) e página pública responsiva.

---

## Tasks

### T1
- [ ] Modelagem + migrations (`Form`, `FormField`, `FormResponse`, `FormAnswer`)
- [ ] Controllers/rotas (admin + público)
- [ ] UI builder futurista (tailwind + stimulus para adicionar/remover campos)
- [ ] Segmentação automática ao submeter
- [ ] CLI tasks (`crm:forms:list`, `crm:forms:export`, `crm:forms:dispatch_segment`)
- [ ] QA (migrate, boot, smoke)
- [ ] Atualizar sidebar/locales (se necessário)

---

## Definition of Done

- [ ] Acceptance criteria atendidos
- [ ] `bin/rails crm:forms:list` funciona
- [ ] File list revisada

---

## Dev Agent Record

### Completion Notes

_Pendente implementação_

### File List

- `config/routes.rb`
- `app/models/form.rb`, `app/models/form_field.rb`, `app/models/form_response.rb`, `app/models/form_answer.rb`
- `app/controllers/forms_controller.rb`, `app/controllers/form_responses_controller.rb`
- `app/views/forms/**`, `app/views/form_responses/**`
- `app/javascript/controllers/form_builder_controller.js` (se aplicável)
- `lib/tasks/crm_forms.rake`
- `db/migrate/*create_forms*`

