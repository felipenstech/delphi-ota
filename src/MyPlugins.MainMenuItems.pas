unit MyPlugins.MainMenuItems;

interface

uses
  ToolsAPI,
  DesignIntf,
  Vcl.Menus,
  Vcl.ActnList;

type
  TOtimizyWizard = class(TNotifierObject, IOTAWizard)
  private
    FMainMenu: TMenuItem;
    FRunProgAction: TAction;
    FImageIndexSite: Integer;
    FImageIndexExec: Integer;
  private
    procedure LoadIcons(ANTAService: INTAServices);
    procedure EvMenuSiteClick(Sender: TObject);
    procedure EvMenuExecutarClick(Sender: TObject);
    procedure EvMenuTraduzirClick(ASender: TObject);
    procedure RegisterMenus(ANTAService: INTAServices);
  public
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
    procedure Execute;

    constructor Create;
    destructor Destroy; override;
  end;

procedure Register; forward;

implementation

uses
  System.SysUtils,
  Winapi.ShellApi,
  Winapi.Windows,
  Vcl.Dialogs,
  Vcl.Controls,
  Vcl.Graphics,
  CodeSiteLogging;

{ TOtimizyWizard }

constructor TOtimizyWizard.Create;
var
  lNTAServices: INTAServices;
begin
  inherited Create();
  if not(Supports(BorlandIDEServices, INTAServices, lNTAServices)) then
    Exit;

  FImageIndexSite := -1;
  FImageIndexSite := -1;

  LoadIcons(lNTAServices);
  RegisterMenus(lNTAServices);
end;

destructor TOtimizyWizard.Destroy;
begin
  FMainMenu.Free;
  FRunProgAction.OnExecute := nil;
  FRunProgAction.Free;
  inherited;
end;

procedure TOtimizyWizard.Execute;
begin
  // Teste
end;

function TOtimizyWizard.GetIDString: string;
begin
  Result := 'Otimizy.Plugin.Menu';
end;

function TOtimizyWizard.GetName: string;
begin
  Result := 'Otimizy Wizard';
end;

function TOtimizyWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

procedure TOtimizyWizard.LoadIcons(ANTAService: INTAServices);
var
  lIcons: TImageList; // Convenção do desenvolvedor
  lBmp: TBitmap;
begin
  CodeSite.EnterMethod('LoadIcons');
  lIcons := TImageList.Create(nil);
  lIcons.Width := 16;
  lIcons.Height := 16;

  lBmp := TBitmap.Create();
  try

    // Exemplo de carregamento de recurso do pacote [6]
    if FindResource(HInstance, 'ID_SITE', RT_BITMAP) <> 0 then begin
      lBmp.LoadFromResourceName(HInstance, 'ID_SITE');
      CodeSite.Send( csmLevel1, 'ID_SITE', 'ID_SITE' );
      lIcons.Add(lBmp, nil);
    end;

    if FindResource(HInstance, 'ID_EXEC', RT_BITMAP) <> 0 then begin
      lBmp.LoadFromResourceName(HInstance, 'ID_EXEC');
      CodeSite.Send( csmLevel2, 'ID_EXEC', 'ID_EXEC' );
      lIcons.Add(lBmp, nil);
    end;

    // Adiciona à ImageList global da IDE [7]
    FImageIndexSite := ANTAService.AddImages(lIcons, 'Otimizy.Menu.Icons');
    FImageIndexExec := FImageIndexSite + 1;
    CodeSite.Send( csmLevel3, 'FImageIndexSite', FImageIndexSite );
    CodeSite.Send( csmLevel3, 'FImageIndexSite', FImageIndexExec );
  finally
    CodeSite.ExitMethod('LoadIcons');
    lBmp.Free;
    lIcons.Free;
  end;
end;

procedure TOtimizyWizard.RegisterMenus(ANTAService: INTAServices);
var
  lMenuItemSite: TMenuItem;
  lMenuItemExecProg: TMenuItem;
begin
  FMainMenu := TMenuItem.Create(nil);
  FMainMenu.Caption := 'Otimizy';

  // Subitem 1: Abrir Site
  lMenuItemSite := TMenuItem.Create(FMainMenu);
  lMenuItemSite.Caption := 'Abrir Site Otimizy';
  lMenuItemSite.OnClick := EvMenuSiteClick;
  lMenuItemSite.ImageIndex := FImageIndexSite;
  FMainMenu.Add(lMenuItemSite);

  // Subitem 2: Chamar Diálogo/Executável
  lMenuItemExecProg := TMenuItem.Create(FMainMenu);
  lMenuItemExecProg.Caption := 'Executar Externo...';
  lMenuItemExecProg.OnClick := EvMenuExecutarClick;
  lMenuItemExecProg.ImageIndex := FImageIndexExec;
  FMainMenu.Add(lMenuItemExecProg);


  // Subitem 3: Traduzir Texto Selecionado
  lMenuItemExecProg := TMenuItem.Create(FMainMenu);
  lMenuItemExecProg.Caption := 'Traduzir Texto';
  lMenuItemExecProg.OnClick := EvMenuTraduzirClick;
  lMenuItemExecProg.ImageIndex := FImageIndexExec;
  FMainMenu.Add(lMenuItemExecProg);


  // Adiciona o menu ao MainMenu da IDE (ex: antes do menu Help)
  ANTAService.MainMenu.Items.Add(FMainMenu);

  FRunProgAction := TAction.Create(nil);
  FRunProgAction.Caption := 'Run Prog';
  FRunProgAction.OnExecute := EvMenuExecutarClick;

//  ANTAService.AddToolButton(sViewToolBar, 'btnRunProg', FRunProgAction);
end;

procedure TOtimizyWizard.EvMenuExecutarClick(Sender: TObject);
var
  lOpenDialog: TOpenDialog;
begin
  lOpenDialog := TOpenDialog.Create(nil);
  try
    lOpenDialog.Filter := 'Executáveis (*.exe)|*.exe';
    if lOpenDialog.Execute then
      ShellExecute(0, 'open', PChar(lOpenDialog.FileName), nil, nil, SW_SHOWNORMAL);
  finally
    lOpenDialog.Free;
  end;
end;

procedure TOtimizyWizard.EvMenuSiteClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('https://www.otimizy.com.br'), nil, nil, SW_SHOWNORMAL);
end;

procedure TOtimizyWizard.EvMenuTraduzirClick(ASender: TObject);
var
  lEditorServices: IOTAEditorServices;
  lSelectedText: string;
begin
  lSelectedText := EmptyStr;
  if Supports(BorlandIDEServices, IOTAEditorServices, lEditorServices) then begin
    lSelectedText := lEditorServices.TopView.Block.Text;
  end;

  if lSelectedText.Trim.IsEmpty then
    Exit;

  //Montar chamada para API de tradução




end;

procedure Register;
begin
  ForceDemandLoadState(dlDisable);

  RegisterPackageWizard(TOtimizyWizard.Create());
end;

end.
