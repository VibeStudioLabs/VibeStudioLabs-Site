# REVORA HML — Critérios para liberar cadastro e painel administrativo

Cadastro público permanece bloqueado. O trigger de ativação automática HML está suspenso. O painel é protótipo não operacional.

## Confirmação de e-mail

Verificar obrigatoriedade no Supabase, SMTP, templates e redirects. Testar conta nova, repetida, link vencido, reenvio, recuperação, login sem confirmação. Sem licença ativa antes de confirmar.

## Segurança e abuso

Implementar CAPTCHA, limites de tentativas, proteção contra senhas vazadas, logs seguros e convite/controle para licença gratuita HML. Nenhum segredo service_role ou Turso no navegador. Revisar RPCs SECURITY DEFINER e respectivos controles de acesso.

## Provisionamento

Após confirmação, backend idempotente cria conta comercial, assinatura trialing e entitlements. Erros parciais recuperáveis. Turso exclusivo apenas ao cadastrar primeira propriedade, nunca reutilizar bancos A/B.

## E2E Windows

Cadastrar e-mail novo no site, confirmar, validar conta e licença via backend, entrar no próximo REVORA HML, cadastrar propriedade e verificar persistência remota. Testar expiração, suspensão, troca de contas e isolamento.

## Administração

Admin separado com login, role server-side, MFA e auditoria. Listar clientes, pesquisar, abrir detalhes, editar plano/limites/validade/permissões, autorizar propriedades, suspender ou reativar, consultar pagamentos, cobranças e dispositivos. Justificativa e histórico obrigatórios.

Remover propriedade significa desativação/retirada de acesso com retenção de dados, nunca exclusão abrupta. Ajustar limite não deve automaticamente criar banco. Pagamentos somente quando integração com provedor e webhooks estiver validada.

## Publicação

Não publicar protótipo administrativo até backend/autorização real. Não ativar cadastro até passar verificações e teste E2E. Não modificar produção.