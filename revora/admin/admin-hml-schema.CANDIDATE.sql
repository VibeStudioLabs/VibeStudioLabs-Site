-- PROPOSTA NÃO EXECUTADA. Revisar antes de aplicar em REVORA-HML.
-- Identidade única de administrador. Nunca criar admin por formulário, invite ou metadata.
create schema if not exists private;
create table if not exists private.revora_admin_singleton (
  singleton_key boolean primary key default true check (singleton_key is true),
  user_id uuid not null unique references auth.users(id),
  active boolean not null default true,
  created_at timestamptz not null default now()
);
alter table private.revora_admin_singleton enable row level security;
revoke all on private.revora_admin_singleton from public,anon,authenticated;
-- Inserção inicial somente por manutenção segura, identificando UUID já verificado.
-- Nunca aceitar user_id vindo do frontend. MFA/AAL2 obrigatório para operações sensíveis.

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
revoke all on private.revora_admin_audit from public,anon,authenticated;

-- Não armazenar chave API, token de webhook, credenciais bancárias ou PIX no banco exposto.
-- Alias seguro para o secret manager e conta recebedora previamente verificada.
create table if not exists private.revora_billing_config (
  singleton_key boolean primary key default true check (singleton_key is true),
  provider text not null check (provider in ('asaas','disabled')),
  environment text not null check (environment in ('sandbox','production')),
  secret_alias text,
  receiver_alias text,
  configuration_version bigint not null default 1,
  status text not null default 'inactive' check (status in ('inactive','validated','active','pending_change')),
  updated_at timestamptz not null default now()
);
alter table private.revora_billing_config enable row level security;
revoke all on private.revora_billing_config from public,anon,authenticated;

create table if not exists private.revora_billing_change_requests (
  id uuid primary key default gen_random_uuid(),
  requested_by uuid not null references auth.users(id),
  old_provider text,
  new_provider text not null,
  old_receiver_alias text,
  new_receiver_alias text,
  status text not null check (status in ('draft','verified','committed','rejected','rolled_back')),
  reason text not null,
  validation_receipt jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  committed_at timestamptz
);
alter table private.revora_billing_change_requests enable row level security;
revoke all on private.revora_billing_change_requests from public,anon,authenticated;

-- Backend privado deve validar exatamente o único user_id ativo + MFA AAL2
-- + reautenticação/step-up para mudar recebedor ou provedor.
-- Validar controle real da nova conta financeira por canal confiável; proibir troca por alias digitado.
-- Mudanças só afetam cobranças FUTURAS, preservando trilha das cobranças já emitidas.
-- Evitar alterar destino por split/transferência sem contrato e verificação explícitos.
-- Migração de provedor requer adaptação API, assinaturas e webhooks;
-- não é apenas trocar uma opção do frontend.
-- Auditar alteração e confirmar idempotência em transação.
