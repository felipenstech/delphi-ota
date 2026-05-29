unit MyPlugins.RegisterPlugin;

interface

uses
  System.SysUtils,
  ToolsAPI,
  DesignIntf;

procedure Register; forward;

implementation

uses
  MyPlugins.MainMenuItems,
  MyPlugins.Telemetry,
  CodeSiteLogging;

procedure Register;
begin
  CodeSite.Send(csmLevel3, 'MyPlugins.RegisterPlugin', 'Register');
  ForceDemandLoadState(dlDisable);
  TTelemetryService.InitializeTelemetry('https://telemetry.example.com/collect', '0.1.0');
  RegisterPackageWizard(TOtimizyWizard.Create());
end;

end.
