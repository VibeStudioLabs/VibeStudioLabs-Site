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

Admin separado com UMA única identidade autorizada, fixada manualmente no servidor (UUID verificado), MFA obrigatório e auditoria. Sem criação, convite, troca ou promoção de administrador pelo site. Listar clientes, pesquisar, abrir detalhes, editar plano/limites/validade/permissões, autorizar propriedades, suspender ou reativar, consultar pagamentos, cobranças e dispositivos. Justificativa e histórico obrigatórios.

Remover propriedade significa desativação/retirada de acesso com retenção de dados, nunca exclusão abrupta. Ajustar limite não deve automaticamente criar banco. Pagamentos somente quando integração com provedor e webhooks estiver validada.

## Publicação

Não publicar protótipo administrativo até backend/autorização real. Não ativar cadastro até passar verificações e teste E2E. Não modificar produção.

## Configuração financeira

Asaas inicia em sandbox. Painel exibe provedor, ambiente, status e conta recebedora verificada/mascarada, sem expor segredos. O único administrador pode solicitar troca de recebedor para novas cobranças apenas após validação forte da titularidade, reautenticação/MFA, confirmação reforçada e auditoria. Trocar provedor exige adaptador específico, teste de API/webhooks, migração de assinaturas, conciliação e rollback. Cobranças antigas continuam ligadas ao provedor original; jamais trocar destino retroativamente. Credenciais apenas em cofre de segredos do servidor, nunca em GitHub, JavaScript ou banco exposto. Nenhuma cobrança real autorizada nesta fase.
