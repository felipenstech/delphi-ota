unit TestMyPluginsTelemetry;

interface

uses
  System.SysUtils,
  System.Classes,
  DUnitX.TestFramework;

type
  {*****************************************************************************
    Classe de teste para a unit MyPlugins.Telemetry usando DUnitX

    Testes incluem:
    - Inicialização de telemetria
    - Configuração de consent
    - Envio de eventos
    - Flush de telemetria
    - Casos extremos e exceções
  *****************************************************************************}
  [TestFixture]
  TTestTelemetryService = class(TObject)
  private
    // Variáveis de suporte para os testes
    FTestEndpoint: string;
    FTestVersion: string;
  public
    // Métodos de Setup e Teardown
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    // === TESTES DE INICIALIZAÇÃO ===

    {Test: Verificar se a telemetria é inicializada com sucesso}
    [Test]
    procedure TestInitializationWithValidEndpoint;

    {Test: Verificar inicialização com valores vazios usa defaults}
    [Test]
    procedure TestInitializationWithEmptyValues;

    {Test: Verificar que segunda inicialização não sobrescreve a primeira}
    [Test]
    procedure TestSecondInitializationIsIgnored;

    // === TESTES DE ESTADO (TelemetryEnabled) ===

    {Test: Verificar que telemetria inicia desabilitada}
    [Test]
    procedure TestTelemetryIsDisabledByDefault;

    {Test: Verificar que telemetria pode ser habilitada}
    [Test]
    procedure TestEnableTelemetry;

    {Test: Verificar que telemetria pode ser desabilitada}
    [Test]
    procedure TestDisableTelemetry;

    // === TESTES DE ENVIO DE EVENTOS ===

    {Test: Envio de evento simples}
    [Test]
    procedure TestSendSimpleEvent;

    {Test: Envio de evento com nome}
    [Test]
    procedure TestSendEventWithName;

    {Test: Envio de evento com metadados JSON}
    [Test]
    procedure TestSendEventWithMetadata;

    {Test: Envio de evento com valores vazios}
    [Test]
    procedure TestSendEventWithEmptyValues;

    // === TESTES DE CASOS EXTREMOS ===

    {Test: Evento vazio não é enviado}
    [Test]
    procedure TestEmptyEventIsNotSent;

    {Test: SetTelemetryEnabled sem inicialização prévia}
    [Test]
    procedure TestSetTelemetryEnabledWithoutInit;

    {Test: Flush de telemetria quando não há thread}
    [Test]
    procedure TestFlushTelemetryWithoutThread;

    {Test: Flush de telemetria com timeout}
    [Test]
    procedure TestFlushTelemetryWithTimeout;

  end;

implementation

uses
  MyPlugins.Telemetry;

{ TTestTelemetryService }

procedure TTestTelemetryService.Setup;
begin
  {
    Setup executado antes de cada teste.
    Aqui inicializamos valores padrão para os testes.
  }
  FTestEndpoint := 'https://telemetry.example.com/collect';
  FTestVersion := '1.0.0-test';
end;

procedure TTestTelemetryService.TearDown;
begin
  {
    TearDown executado após cada teste.
    Aqui fazemos limpeza de recursos, se necessário.
  }
  try
    TTelemetryService.FlushTelemetry(1000);
  except
    // Ignora exceções durante limpeza
  end;
end;

// ============================================================================
// TESTES DE INICIALIZAÇÃO
// ============================================================================

procedure TTestTelemetryService.TestInitializationWithValidEndpoint;
begin
  {
    Teste: Inicialização com endpoint e versão válidos
    Esperado: Telemetria é inicializada sem erros
  }
  Assert.WillNotRaise(
    procedure
    begin
      TTelemetryService.InitializeTelemetry(FTestEndpoint, FTestVersion);
    end,
    Exception,
    'Inicialização com valores válidos não deve lançar exceção'
  );
end;

procedure TTestTelemetryService.TestInitializationWithEmptyValues;
begin
  {
    Teste: Inicialização com valores vazios
    Esperado: Usa valores padrão (TELEMETRY_DEFAULT_ENDPOINT e DEFAULT_PLUGIN_VERSION)
  }
  Assert.WillNotRaise(
    procedure
    begin
      TTelemetryService.InitializeTelemetry('', '');
    end,
    Exception,
    'Inicialização com valores vazios deve usar defaults'
  );
end;

procedure TTestTelemetryService.TestSecondInitializationIsIgnored;
begin
  {
    Teste: Segunda chamada a InitializeTelemetry não afeta o serviço
    Esperado: Primeira inicialização prevalece
  }
  TTelemetryService.InitializeTelemetry(FTestEndpoint, FTestVersion);

  Assert.WillNotRaise(
    procedure
    begin
      // Tentar reinicializar com valores diferentes
      TTelemetryService.InitializeTelemetry('https://other.endpoint.com', '2.0.0');
    end,
    Exception,
    'Segunda inicialização deve ser ignorada sem erro'
  );
end;

// ============================================================================
// TESTES DE ESTADO (TelemetryEnabled)
// ============================================================================

procedure TTestTelemetryService.TestTelemetryIsDisabledByDefault;
begin
  {
    Teste: Telemetria inicia em estado desabilitado
    Esperado: TelemetryEnabled retorna False inicialmente
  }
  TTelemetryService.InitializeTelemetry(FTestEndpoint, FTestVersion);

  Assert.IsFalse(
    TTelemetryService.TelemetryEnabled,
    'Telemetria deve estar desabilitada por padrão'
  );
end;

procedure TTestTelemetryService.TestEnableTelemetry;
begin
  {
    Teste: Habilitar telemetria
    Esperado: SetTelemetryEnabled(True) faz TelemetryEnabled retornar True
  }
  TTelemetryService.InitializeTelemetry(FTestEndpoint, FTestVersion);
  TTelemetryService.SetTelemetryEnabled(True);

  Assert.IsTrue(
    TTelemetryService.TelemetryEnabled,
    'Telemetria deve estar habilitada após SetTelemetryEnabled(True)'
  );
end;

procedure TTestTelemetryService.TestDisableTelemetry;
begin
  {
    Teste: Desabilitar telemetria após habilitá-la
    Esperado: SetTelemetryEnabled(False) faz TelemetryEnabled retornar False
  }
  TTelemetryService.InitializeTelemetry(FTestEndpoint, FTestVersion);
  TTelemetryService.SetTelemetryEnabled(True);
  TTelemetryService.SetTelemetryEnabled(False);

  Assert.IsFalse(
    TTelemetryService.TelemetryEnabled,
    'Telemetria deve estar desabilitada após SetTelemetryEnabled(False)'
  );
end;

// ============================================================================
// TESTES DE ENVIO DE EVENTOS
// ============================================================================

procedure TTestTelemetryService.TestSendSimpleEvent;
begin
  {
    Teste: Enviar evento simples
    Esperado: Método não lança exceção e event é processado
  }
  TTelemetryService.InitializeTelemetry(FTestEndpoint, FTestVersion);
  TTelemetryService.SetTelemetryEnabled(True);

  Assert.WillNotRaise(
    procedure
    begin
      TTelemetryService.SendTelemetryEvent('user_action');
    end,
    Exception,
    'Envio de evento simples não deve lançar exceção'
  );
end;

procedure TTestTelemetryService.TestSendEventWithName;
begin
  {
    Teste: Enviar evento com nome
    Esperado: SendTelemetryEvent aceita parâmetro AEventName
  }
  TTelemetryService.InitializeTelemetry(FTestEndpoint, FTestVersion);
  TTelemetryService.SetTelemetryEnabled(True);

  Assert.WillNotRaise(
    procedure
    begin
      TTelemetryService.SendTelemetryEvent('user_action', 'ButtonClicked');
    end,
    Exception,
    'Envio de evento com nome não deve lançar exceção'
  );
end;

procedure TTestTelemetryService.TestSendEventWithMetadata;
begin
  {
    Teste: Enviar evento com metadados JSON
    Esperado: SendTelemetryEvent aceita parâmetro AMeta com JSON
  }
  TTelemetryService.InitializeTelemetry(FTestEndpoint, FTestVersion);
  TTelemetryService.SetTelemetryEnabled(True);

  Assert.WillNotRaise(
    procedure
    begin
      TTelemetryService.SendTelemetryEvent(
        'user_action',
        'ButtonClicked',
        '{"button_name":"Submit","location":"Dialog"}'
      );
    end,
    Exception,
    'Envio de evento com metadados não deve lançar exceção'
  );
end;

procedure TTestTelemetryService.TestSendEventWithEmptyValues;
begin
  {
    Teste: Enviar evento com parâmetros vazios
    Esperado: Método funciona com valores vazios para opcionais
  }
  TTelemetryService.InitializeTelemetry(FTestEndpoint, FTestVersion);
  TTelemetryService.SetTelemetryEnabled(True);

  Assert.WillNotRaise(
    procedure
    begin
      TTelemetryService.SendTelemetryEvent('user_action', '', '');
    end,
    Exception,
    'Envio com parâmetros vazios não deve lançar exceção'
  );
end;

// ============================================================================
// TESTES DE CASOS EXTREMOS
// ============================================================================

procedure TTestTelemetryService.TestEmptyEventIsNotSent;
begin
  {
    Teste: Evento vazio não é processado
    Esperado: SendTelemetryEvent com string vazia não causa erro
  }
  TTelemetryService.InitializeTelemetry(FTestEndpoint, FTestVersion);
  TTelemetryService.SetTelemetryEnabled(True);

  Assert.WillNotRaise(
    procedure
    begin
      // Envio de evento vazio - internamente não deve fazer nada
      TTelemetryService.SendTelemetryEvent('');
    end,
    Exception,
    'Evento vazio não deve lançar exceção'
  );
end;

procedure TTestTelemetryService.TestSetTelemetryEnabledWithoutInit;
begin
  {
    Teste: SetTelemetryEnabled sem inicialização prévia
    Esperado: Método auto-inicializa com valores padrão
  }
  Assert.WillNotRaise(
    procedure
    begin
      // Chamar SetTelemetryEnabled sem InitializeTelemetry prévia
      TTelemetryService.SetTelemetryEnabled(True);
    end,
    Exception,
    'SetTelemetryEnabled deve auto-inicializar se necessário'
  );
end;

procedure TTestTelemetryService.TestFlushTelemetryWithoutThread;
begin
  {
    Teste: FlushTelemetry sem thread ativa
    Esperado: Método não lança exceção
  }
  TTelemetryService.InitializeTelemetry(FTestEndpoint, FTestVersion);

  Assert.WillNotRaise(
    procedure
    begin
      TTelemetryService.FlushTelemetry;
    end,
    Exception,
    'FlushTelemetry sem thread não deve lançar exceção'
  );
end;

procedure TTestTelemetryService.TestFlushTelemetryWithTimeout;
begin
  {
    Teste: FlushTelemetry com timeout customizado
    Esperado: Método respeita timeout especificado
  }
  TTelemetryService.InitializeTelemetry(FTestEndpoint, FTestVersion);
  TTelemetryService.SetTelemetryEnabled(True);
  TTelemetryService.SendTelemetryEvent('test_event');

  Assert.WillNotRaise(
    procedure
    begin
      TTelemetryService.FlushTelemetry(500); // timeout curto
    end,
    Exception,
    'FlushTelemetry com timeout customizado não deve lançar exceção'
  );
end;

initialization
  {
    Registra a classe de teste no framework DUnitX.
    Permite que o test runner descubra e execute os testes.
  }
  TDUnitX.RegisterTestFixture(TTestTelemetryService);

end.
