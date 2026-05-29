# Instruções de Setup - Projeto de Testes DUnitX

## 📋 Visão Geral

Este é um **projeto completo de testes unitários** para a unit `MyPlugins.Telemetry.pas` usando o framework **DUnitX**, compatível com **Delphi Berlin 10.1**.

### Estrutura do Projeto

```
PluginTest/
├── PluginTests.dpr              # Programa principal de testes
├── PluginTests.dproj            # Arquivo de projeto Delphi
├── PluginTests.groupproj        # Grupo de projetos (para gerenciamento)
├── TestMyPluginsTelemetry.pas   # Unit com os casos de teste
└── INSTRUÇÕES_SETUP.md          # Este arquivo
```

---

## 🔧 Pré-requisitos

- **Delphi Berlin 10.1** ou superior
- **DUnitX Framework** instalado no Delphi
- Acesso à pasta do projeto principal (`c:\workspace\Lab\delphi-ota\src`)

---

## 📦 Instalação do DUnitX

### Opção 1: Via GetIt (Recomendado)

1. Abra o **Delphi IDE**
2. Vá para **Tools → GetIt Package Manager**
3. Procure por **"DUnitX"**
4. Clique em **Install**
5. Aguarde a instalação completar e reinicie o Delphi

### Opção 2: Instalação Manual

1. Clone ou baixe o DUnitX de: https://github.com/VSoftTechnologies/DUnitX
2. Extraia para uma pasta (ex: `C:\DUnitX`)
3. No Delphi, vá para **Tools → Options → Language → Delphi → Library**
4. Adicione o caminho `C:\DUnitX\Source` à lista de **Library Path**
5. Reinicie o Delphi

---

## 🚀 Configuração do Projeto

### Passo 1: Abrir o Projeto no Delphi

1. Abra o **Delphi IDE**
2. Vá para **File → Open Project**
3. Navegue até `c:\workspace\Lab\delphi-ota\PluginTest\`
4. Selecione **PluginTests.groupproj**
5. Clique em **Open**

### Passo 2: Configurar as Paths de Busca

1. No **Project Manager** (lado esquerdo), clique com botão direito em **PluginTests**
2. Selecione **Options**
3. Vá para **Compiler → Search Path**
4. Adicione as seguintes paths:
   - `c:\workspace\Lab\delphi-ota\src` (unidades do projeto principal)
   - `c:\DUnitX\Source` (se instalado manualmente)

### Passo 3: Verificar Dependências

1. Certifique-se de que a unit `MyPlugins.Telemetry.pas` está acessível
2. Se houver erro de compilação, adicione a path do projeto principal ao **DCC_UnitSearchPath** no arquivo `.dproj`

---

## 🧪 Estrutura dos Testes

### Classe de Teste Principal

```pascal
[TestFixture]
TTestTelemetryService = class(TObject)
```

### Atributos Utilizados

- **`[TestFixture]`** - Marca a classe como fixture de teste
- **`[Setup]`** - Executado antes de cada teste
- **`[TearDown]`** - Executado após cada teste
- **`[Test]`** - Marca um método como um caso de teste

### Casos de Teste Implementados

#### 1. **Testes de Inicialização**
- ✅ `TestInitializationWithValidEndpoint` - Inicializa com endpoint válido
- ✅ `TestInitializationWithEmptyValues` - Usa valores padrão quando vazios
- ✅ `TestSecondInitializationIsIgnored` - Segunda inicialização é ignorada

#### 2. **Testes de Estado**
- ✅ `TestTelemetryIsDisabledByDefault` - Telemetria inicia desabilitada
- ✅ `TestEnableTelemetry` - Habilita telemetria com sucesso
- ✅ `TestDisableTelemetry` - Desabilita telemetria com sucesso

#### 3. **Testes de Envio de Eventos**
- ✅ `TestSendSimpleEvent` - Envia evento simples
- ✅ `TestSendEventWithName` - Envia evento com nome
- ✅ `TestSendEventWithMetadata` - Envia evento com metadados JSON
- ✅ `TestSendEventWithEmptyValues` - Envia evento com parâmetros vazios

#### 4. **Testes de Casos Extremos**
- ✅ `TestEmptyEventIsNotSent` - Evento vazio não é processado
- ✅ `TestSetTelemetryEnabledWithoutInit` - Auto-inicializa se necessário
- ✅ `TestFlushTelemetryWithoutThread` - Flush sem thread ativa
- ✅ `TestFlushTelemetryWithTimeout` - Flush com timeout customizado

---

## 🏃 Executando os Testes

### Método 1: Compilar e Executar (Console)

#### No Prompt de Comando (CMD)

```batch
cd c:\workspace\Lab\delphi-ota\PluginTest
call rsvars.bat
msbuild PluginTests.dproj /t:Build /p:Config=Debug /p:Platform=Win32
PluginTests.exe
```

#### No PowerShell

```powershell
cd 'c:\workspace\Lab\delphi-ota\PluginTest'
& 'c:\path\to\rsvars.bat'  # Se necessário
msbuild PluginTests.dproj /t:Build /p:Config=Debug /p:Platform=Win32
.\Win32\Debug\PluginTests.exe
```

### Método 2: Compilar no Delphi IDE

1. Abra o projeto em `PluginTests.groupproj`
2. Clique com botão direito em **PluginTests** no Project Manager
3. Selecione **Build** ou **Rebuild All**
4. Vá para **Run → Run** (ou pressione **F9**)

### Método 3: Usar TestInsight (Recomendado para Desenvolvimento)

1. Instale o **TestInsight** via **GetIt**
2. Configure o project para usar TestInsight logger
3. Execute os testes com visualização gráfica

---

## 📊 Entender os Resultados dos Testes

### Saída de Sucesso

```
*** TESTES EXECUTADOS COM SUCESSO ***
Total de testes: 13
```

### Saída de Falha

```
*** ALGUNS TESTES FALHARAM ***
Total de testes: 13
Testes falhados: 2
Testes com erro: 1
```

---

## 🔍 Adicionar Novos Testes

### Padrão para Novos Testes

```pascal
{Test: Descrição clara do teste}
[Test]
procedure TestNomeDoTeste;
begin
  {
    Comentário explicativo do que está sendo testado
    e do resultado esperado.
  }
  // Setup
  TTelemetryService.InitializeTelemetry(FTestEndpoint, FTestVersion);

  // Ação
  TTelemetryService.SetTelemetryEnabled(True);

  // Verificação (Assert)
  Assert.IsTrue(
    TTelemetryService.TelemetryEnabled,
    'Mensagem de erro descritiva'
  );
end;
```

### Métodos Assert Disponíveis (DUnitX)

- `Assert.IsTrue(Condition, Message)`
- `Assert.IsFalse(Condition, Message)`
- `Assert.AreEqual(Expected, Actual, Message)`
- `Assert.IsNull(Value, Message)`
- `Assert.IsNotNull(Value, Message)`
- `Assert.WillRaise(Proc, ExceptionClass, Message)`
- `Assert.WillNotRaise(Proc, ExceptionClass, Message)`

---

## 🐛 Troubleshooting

### Problema 1: "Unit 'MyPlugins.Telemetry' not found"

**Solução:**
1. Verifique se o arquivo `MyPlugins.Telemetry.pas` existe em `c:\workspace\Lab\delphi-ota\src`
2. Adicione a path ao projeto:
   - Project → Options → Compiler → Search Path
   - Adicione: `c:\workspace\Lab\delphi-ota\src`

### Problema 2: "DUnitX not installed"

**Solução:**
1. Instale DUnitX via GetIt (recomendado)
2. Ou adicione manualmente o caminho do DUnitX ao Library Path:
   - Tools → Options → Language → Delphi → Library
   - Procure por um caminho contendo `DUnitX\Source`

### Problema 3: Erro ao compilar "Package not found"

**Solução:**
1. Abra `PluginTests.dproj` em um editor de texto
2. Localize a linha `<DCC_UsePackage>`
3. Remova pacotes desnecessários se não estiver usando DevExpress ou bibliotecas específicas
4. Salve e tente compilar novamente

### Problema 4: "rsvars.bat not found"

**Solução:**
1. Se estiver compilando via msbuild na linha de comando, localize `rsvars.bat`:
   - Geralmente está em: `c:\workspace\Lab\delphi-ota\rsvars.bat`
   - Ou no diretório de instalação do Delphi
2. Execute o arquivo antes de chamar `msbuild`

---

## 📝 Boas Práticas Implementadas

✅ **Nomenclatura de Classes**: Prefixo `T` (ex: `TTestTelemetryService`)
✅ **Separação de Responsabilidades**: Setup/TearDown isolados
✅ **Documentação**: Cada teste tem comentário explicativo
✅ **Mensagens de Erro**: Descritivas e úteis para debugging
✅ **Uso de Atributos**: Segue padrão DUnitX corretamente
✅ **Registro Automático**: `TDUnitX.RegisterTestFixture` na initialization
✅ **Compatibilidade**: Delphi Berlin 10.1+

---

## 🎯 Próximos Passos

1. **Adicionar mais testes** conforme novas funcionalidades forem desenvolvidas
2. **Integrar com CI/CD** (GitHub Actions, GitLab CI, etc.)
3. **Aumentar cobertura de testes** para atingir > 80%
4. **Usar TestInsight** para visualização gráfica dos testes
5. **Parametrizar testes** com `[TestCase]` para múltiplas entradas

---

## 📚 Referências

- **DUnitX GitHub**: https://github.com/VSoftTechnologies/DUnitX
- **Delphi Documentation**: https://docwiki.embarcadero.com
- **Unit Testing in Delphi**: https://www.youtube.com/results?search_query=dunitx+delphi

---

## 💡 Suporte

Para dúvidas ou problemas:
1. Verifique o arquivo `CONTEXT.md` do projeto principal
2. Consulte a documentação do DUnitX
3. Execute os testes em Debug para ver mais detalhes
4. Adicione `{$DEFINE DEBUG}` no `.dpr` para ativar pause antes de fechar

---

**Última atualização**: Maio de 2026
**Versão do Projeto**: 1.0.0
**Compatibilidade**: Delphi Berlin 10.1+
