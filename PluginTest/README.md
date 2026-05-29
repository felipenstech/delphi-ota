# Projeto de Testes - PluginTest

## 📌 Resumo Rápido

Projeto completo de testes unitários para o plugin `delphi-ota` usando **DUnitX Framework** (Delphi Berlin 10.1).

## 🗂️ Arquivos Principais

| Arquivo | Descrição |
|---------|-----------|
| `PluginTests.dpr` | Programa executável principal |
| `PluginTests.dproj` | Arquivo de projeto Delphi |
| `PluginTests.groupproj` | Grupo de projetos |
| `TestMyPluginsTelemetry.pas` | Unit com 13 casos de teste |
| `INSTRUÇÕES_SETUP.md` | Guia completo de setup e uso |

## ⚡ Quick Start

### 1. Instalar DUnitX
```
Delphi IDE → Tools → GetIt Package Manager → DUnitX → Install
```

### 2. Abrir o Projeto
```
File → Open Project → PluginTests.groupproj
```

### 3. Compilar e Executar
```
Run → Run (ou F9)
```

## ✅ Cobertura de Testes

- **13 casos de teste** total
- **4 categorias**: Inicialização, Estado, Eventos, Casos Extremos
- **Atributos DUnitX**: `[TestFixture]`, `[Setup]`, `[TearDown]`, `[Test]`
- **Assertions**: `IsTrue`, `IsFalse`, `WillRaise`, `WillNotRaise`

## 🧪 Testes Implementados

### Inicialização (3 testes)
- ✅ Com endpoint válido
- ✅ Com valores vazios (usa defaults)
- ✅ Segunda inicialização é ignorada

### Estado (3 testes)
- ✅ Telemetria desabilitada por padrão
- ✅ Habilitar telemetria
- ✅ Desabilitar telemetria

### Envio de Eventos (4 testes)
- ✅ Evento simples
- ✅ Evento com nome
- ✅ Evento com metadados JSON
- ✅ Evento com valores vazios

### Casos Extremos (3 testes)
- ✅ Evento vazio não é enviado
- ✅ SetTelemetryEnabled sem init prévia
- ✅ Flush com/sem timeout

## 📂 Estrutura de Pastas

```
c:\workspace\Lab\delphi-ota\
├── dclMenus.dproj (projeto principal)
├── src/ (unidades do plugin)
│   └── MyPlugins.Telemetry.pas
└── PluginTest/ (este projeto de testes)
    ├── PluginTests.dpr
    ├── PluginTests.dproj
    ├── PluginTests.groupproj
    ├── TestMyPluginsTelemetry.pas
    ├── INSTRUÇÕES_SETUP.md
    ├── README.md
    └── Win32/Debug/ (compilado)
```

## 🔨 Compilação via Linha de Comando

```batch
cd c:\workspace\Lab\delphi-ota\PluginTest
call rsvars.bat
msbuild PluginTests.dproj /t:Build /p:Config=Debug /p:Platform=Win32
.\Win32\Debug\PluginTests.exe
```

## 📖 Para Mais Informações

Consulte **INSTRUÇÕES_SETUP.md** para:
- Instalação detalhada do DUnitX
- Configuração completa do projeto
- Como adicionar novos testes
- Troubleshooting
- Integração com TestInsight

## 🎯 Funcionalidades da Unit Testada

A unit `MyPlugins.Telemetry.pas` implementa:
- **Inicialização de telemetria** com endpoint customizado
- **Controle de consentimento** do usuário
- **Envio de eventos** com metadados
- **Gerenciamento de threads** para envio assíncrono
- **Persistência de configuração** em arquivo JSON

## 💾 Configuração de Telemetria

Os testes verificam a classe `TTelemetryService`:
```pascal
class procedure InitializeTelemetry(const AEndpoint, APluginVersion: string);
class function TelemetryEnabled: Boolean;
class procedure SetTelemetryEnabled(const AEnabled: Boolean);
class procedure SendTelemetryEvent(const AEvent, AEventName, AMeta: string);
class procedure FlushTelemetry(ATimeoutMs: Integer = 5000);
```

## ✨ Destaques

- ✅ DUnitX moderno (não DUnit antigo)
- ✅ Compatível com Delphi Berlin 10.1
- ✅ Bem comentado e organizado
- ✅ Segue padrões Delphi clássicos
- ✅ Pronto para CI/CD
- ✅ Fácil de estender com novos testes

---

**Versão**: 1.0.0
**Data**: Maio 2026
**Autor**: Especialista em Delphi & Testes Unitários
