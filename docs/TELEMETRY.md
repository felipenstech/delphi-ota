# Telemetria do Plugin delphi-ota

Este documento descreve o design proposto para a telemetria do plugin `delphi-ota`.

## Objetivos
- Coletar estatísticas de instalação e uso para orientar melhorias.
- Respeitar privacidade: somente dados não sensíveis e anonimizados.
- Telemetria opt-in (desligada por padrão) com opção clara de opt-out.

## Dados coletados (esquema mínimo)
- `client_id` (string): UUID v4 anônimo gerado no primeiro uso.
- `plugin_version` (string): versão do pacote (ex: `0.1.0`).
- `event` (string): tipo de evento — `install`, `activate`, `command`, `uninstall`, `error`.
- `event_name` (string|null): nome do comando/ação (ex: `traduzir`, `open_docs`).
- `delphi_version` (string): versão do Delphi (obtida via OTA quando possível).
- `os` (string): sistema operacional (ex: `Windows 10`).
- `timestamp` (string): ISO-8601 UTC.
- `meta` (object|null): campo livre para métricas pequenas (ex: duration_ms).

Exemplo JSON:

```json
{
  "client_id": "00000000-0000-0000-0000-000000000000",
  "plugin_version": "0.1.0",
  "event": "install",
  "event_name": null,
  "delphi_version": "10.1 Berlin",
  "os": "Windows 10",
  "timestamp": "2026-05-25T12:00:00Z",
  "meta": { "sample": 1 }
}
```

## Endpoint
- Placeholder para revisão: `https://telemetry.example.com/collect`
- O endpoint deve aceitar POST JSON com `Content-Type: application/json`.
- Recomendado: usar HTTPS e validar certificados; o servidor deve rejeitar payloads grandes.

## Persistência local e consentimento
- Armazenar `client_id` e `consent` em `%APPDATA%\delphi-ota\telemetry.json`.
- Estrutura do arquivo:

```json
{
  "client_id": "...",
  "consent": true,
  "last_sent": "2026-05-25T12:00:00Z"
}
```

- Padrão: `consent` = `false` (telemetria desligada). Mostrar prompt ao usuário na primeira execução com opção clara.

## Política de Privacidade e Dados
- Não coletar nomes de arquivos, conteúdo do editor, identificadores de usuário, ou qualquer PII.
- Guardar somente o mínimo necessário para métricas agregadas.
- Permitir exportar/remover o `client_id` e desabilitar telemetria via menu do plugin.

## Envio e Resiliência
- Enviar eventos de forma assíncrona em thread separada para não bloquear o IDE.
- Buffer local (fila) para eventos quando offline; tentar reenvio com backoff exponencial.
- Log local para debug (modo `debug`), sem enviar logs ao servidor por padrão.

## Segurança
- Usar WinHTTP/WinInet com validação TLS; não aceitar certificados inválidos.
- Não incluir tokens sensíveis no payload.

## Telemetria mínima inicial (MVP)
1. `install` — ao detectar primeiro run com `consent=true`.
2. `activate` — ao carregar o package/registrar ações.
3. `command` — quando usuário executar ações principais (ex: `traduzir`).

---

Referência: manter este documento sob `docs/TELEMETRY.md` e atualizar conforme política de privacidade e requisitos legais.
