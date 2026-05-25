# Especificação: `MyPlugins.Telemetry`

Objetivo: unidade leve para gerenciar consentimento, geração de `client_id` e envio de eventos JSON para um endpoint configurável.

## API proposta (pseudocódigo / assinaturas)

- `function TelemetryEnabled: Boolean;` — retorna true se o usuário optou-in.
- `procedure SetTelemetryEnabled(const AEnabled: Boolean);` — salva preferência de consentimento.
- `procedure InitializeTelemetry(const AEndpoint: string; const APluginVersion: string);` — inicializa, lê `telemetry.json` ou cria `client_id`.
- `procedure SendEvent(const AEvent: string; const AEventName: string = ''; const AMeta: string = '');` — enfileira e envia evento (assíncrono).
- `procedure FlushTelemetry(ATimeoutMs: Integer = 5000);` — força envio de eventos pendentes (sincronamente) — útil para finalization.

## Implementação técnica (resumo)
- Linguagem: Object Pascal (Delphi).
- Rede: WinHTTP (Winapi.WinHTTP) ou WinInet; preferir WinHTTP para controle de TLS.
- Serialização JSON: `System.JSON` (TJSONObject) disponível em Delphi 10.1.
- Threads: `TThread` simples para envio sem bloquear a UI.
- Armazenamento local: escrever `telemetry.json` em `%APPDATA%\delphi-ota` usando `TFile`.

## Fluxos
- Inicialização:
  - `InitializeTelemetry` lê `telemetry.json`.
  - Se não existir, gera `client_id` (GUID) e salva com `consent=false`.
  - Não enviar nada até `consent=true`.

- Mudança de consentimento:
  - `SetTelemetryEnabled(true)` ativa envio e dispara evento `install` (ou `activate` se já instalado).
  - `SetTelemetryEnabled(false)` limpa filas e para envios.

- Envio de evento:
  - `SendEvent` cria payload JSON, adiciona à fila local, dispara worker thread se necessário.

## Telemetria e ciclo de vida do package
- Chamar `InitializeTelemetry` na seção `initialization` do package.
- Em `finalization`, chamar `FlushTelemetry(2000)` para tentar enviar eventos pendentes.

## Considerações legais
- Incluir README/PRIVACY com instruções de como desabilitar e remover dados locais.

## Placeholder de endpoint
- `https://telemetry.example.com/collect` (substituir antes do envio real).

---

Coloquei este arquivo em `src/MyPlugins.Telemetry.spec.md` para orientar a implementação real.
