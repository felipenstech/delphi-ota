program PluginTests;
{*******************************************************************************
  Projeto de Testes DUnitX para MyPlugins - Delphi Berlin 10.1

  Este programa executa os testes unitários do projeto delphi-ota usando o
  framework DUnitX.

  Compatibilidade: Delphi 10.1 Berlin ou superior
  Framework: DUnitX
*******************************************************************************}

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  DUnitX.TestFramework,
  DUnitX.Loggers.Console,
  TestMyPluginsTelemetry in 'TestMyPluginsTelemetry.pas',
  MyPlugins.Telemetry in '..\src\MyPlugins.Telemetry.pas';

var
  LRunner: ITestRunner;
  LResults: ITestResults;
  LLogger: ITestLogger;
  LNOfFailures: Integer;

begin
  try
    //
    // Cria a instância do test runner
    //
    LRunner := TDUnitX.CreateRunner;
    LRunner.UseRTTEDiscovery := True;

    //
    // Cria um logger de console
    //
    LLogger := TDUnitXConsoleLogger.Create(True);

    //
    // Executa os testes
    //
    LResults := LRunner.Execute;

    //
    // Log dos resultados
    //
    if LResults.AllPassed then
    begin
      WriteLn('');
      WriteLn('*** TESTES EXECUTADOS COM SUCESSO ***');
      WriteLn(Format('Total de testes: %d', [LResults.TestCount]));
    end
    else
    begin
      WriteLn('');
      WriteLn('*** ALGUNS TESTES FALHARAM ***');
      WriteLn(Format('Total de testes: %d', [LResults.TestCount]));
      WriteLn(Format('Testes falhados: %d', [LResults.FailureCount]));
      WriteLn(Format('Testes com erro: %d', [LResults.ErrorCount]));
      LNOfFailures := LResults.FailureCount + LResults.ErrorCount;
    end;

    //
    // Pausa antes de fechar (somente em modo console)
    //
    {$IFDEF DEBUG}
    WriteLn('');
    WriteLn('Pressione ENTER para continuar...');
    ReadLn;
    {$ENDIF}

    //
    // Retorna código de saída apropriado
    //
    if not LResults.AllPassed then
      ExitCode := LNOfFailures;

  except
    on E: Exception do
    begin
      WriteLn('Erro ao executar testes: ', E.ClassName, ' - ', E.Message);
      ExitCode := 1;
    end;
  end;
end.
