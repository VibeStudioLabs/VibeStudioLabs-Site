-- REVORA HML ADMIN — MIGRATION CANDIDATA, NÃO APLICAR SEM REVISÃO
-- Administradores são designados somente por processo manual de confiança;
-- nunca por cadastro no site ou por metadata controlada pelo usuário.
create schema if not exists private;

create table if not exists private.revora_admin_members (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('owner','support_readonly','billing')),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  added_by uuid references auth.users(id)
);
alter table private.revora_admin_members enable row level security;
revoke all on private.revora_admin_members from anon, authenticated, public;

create table if not exists private.revora_admin_audit (
  id bigint generated always as identity primary key,
  actor_user_id uuid not null references auth.users(id),
  account_id uuid references public.accounts(id),
  action text not null,
  reason text not null check (length(btrim(reason)) >= 8),
  old_state jsonb not null default '{}'::jsonb,
  new_state jsonb not null default '{}'::jsonb,
  request_id uuid not null unique,
  occurred_at timestamptz not null default now()
);
alter table private.revora_admin_audit enable row level security;
revoke all on private.revora_admin_audit from anon, authenticated, public;

-- O RPC/Edge Function administrativo deverá:
-- 1. Validar Auth JWT + AAL2/MFA obrigatória + role ativa.
-- 2. Autorizar cada operação específica, nunca só a rota /admin.
-- 3. Executar mutação e auditoria na MESMA transação.
-- 4. Aplicar idempotência por request_id e concorrência otimista.
-- 5. Nunca conceder acesso direto às tabelas private.
-- 6. Confirmar antes de reduzir limite abaixo de propriedades já existentes.
-- 7. Desativar propriedades preservando dados e vínculos para eventual restauração.
-- 8. Não modificar ligações Turso arbitrariamente.
-- 9. Tratar pagamento apenas após eventos verificados do provedor.
-- 10. Nunca permitir ao cliente atribuir seu próprio papel admin.
