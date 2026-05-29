unit MyPlugins.TelemetryConfig;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  cxGraphics,
  cxControls,
  cxLookAndFeels,
  cxLookAndFeelPainters,
  cxContainer,
  cxEdit,
  cxCheckBox,
  cxButtons,
  dxLayoutControl,
  dxLayoutContainer,
  dxLayoutControlAdapters,
  cxClasses;

type
  TfrmTelemetryConfig = class(TForm)
    drgMainContent: TdxLayoutGroup;
    dlcRoot: TdxLayoutControl;
    dxLayoutGroup1: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
  private
//    procedure LoadSettings;
//    procedure SaveSettings;
  public
    class procedure ShowTelemetryConfig;
  end;

implementation

uses
  MyPlugins.Telemetry;

{$R *.dfm}
{ TfrmTelemetryConfig }

class procedure TfrmTelemetryConfig.ShowTelemetryConfig;
var
  frm: TfrmTelemetryConfig;
begin
  frm := TfrmTelemetryConfig.Create(nil);
  try
    frm.ShowModal;
  finally
    frm.Free;
  end;
end;

procedure TfrmTelemetryConfig.FormCreate(Sender: TObject);
begin
//  LoadSettings;
end;

end.
