# AGENTS.md — AIOX CRM (Rails)

## Constitution

Siga `.aiox-core/constitution.md` como fonte de verdade (CLI First, Story-Driven, Quality First, No Invention).

## Workflow obrigatório

1. Trabalhe a partir de stories em `docs/stories/`.
2. Implemente somente acceptance criteria acordados.
3. Atualize checklists e **File List** na story ao concluir tarefas.
4. Funcionalidade comercial crítica deve permanecer acessível via CLI (`bin/rails crm:*`).

## Quality gates (Rails)

```bash
bin/rails test
bin/rubocop # se configurado
```

## Estrutura

- AIOX: `.aiox-core/`, `.cursor/`, `.claude/` (gerados pelo instalador)
- App: `app/`
- Integrações N8N: `app/services/integrations/`, `app/jobs/integrations/`, API `app/controllers/api/v1/`

## IDE

Cursor: use regras sincronizadas pelo AIOX; validadores multi-IDE são opcionais neste app Ruby.
