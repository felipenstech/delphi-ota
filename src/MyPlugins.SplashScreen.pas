unit MyPlugins.SplashScreen;

{ ============================================================================
  MyPlugins.SplashScreen.pas
  Responsável por registrar uma imagem (bitmap) na Splash Screen do Delphi
  e na caixa de diálogo "About" via Open Tools API (OTA).

  Como usar:
  1. Adicione este arquivo ao seu pacote (.dpk).
  2. Crie um arquivo de recursos (.rc) com as entradas:
  SPLASHICON  BITMAP  "splash_24x24.bmp"
  ABOUTICON   BITMAP  "about_48x48.bmp"
  Compile o .rc para gerar o .res e vincule-o usando a diretiva $R.
  O nome do .res deve ser "MyPlugins.SplashScreen.res" (mesmo nome desta unit).
  3. Chame RegisterSplashScreen a partir do seu Register (opcional —
  a seção initialization já faz isso automaticamente).
  4. Adicione a unit ao "requires" do .dpk junto com DesignIDE e rtl.

  Observações:
  - SPLASHICON : bitmap 24 x 24 px
  - ABOUTICON  : bitmap 48 x 48 px
  - ForceDemandLoadState(dlDisable) é necessário para que os ícones
  apareçam na Splash Screen (veja uRegister.pas).
  ============================================================================ }

interface

implementation

uses
  CodeSiteLogging,
  Winapi.Windows, // LoadBitmap, HInstance
  System.SysUtils, // Supports
  ToolsAPI, // SplashScreenServices, IOTAAboutBoxServices, BorlandIDEServices
  DesignIntf, // (incluso indiretamente; necessário em alguns Delphis)
  MyPlugins.Strings;

// ---------------------------------------------------------------------------
// Constantes: nomes dos recursos de bitmap no arquivo .res
// ---------------------------------------------------------------------------
const
  RES_SPLASH_ICON = 'ID_SPLASH'; // Bitmap 24 x 24 px — Splash Screen
  RES_ABOUT_ICON = 'ID_ABOUT'; // Bitmap 48 x 48 px — About Dialog

  // ---------------------------------------------------------------------------
  // Variáveis de controle do About Box
  // ---------------------------------------------------------------------------
var
  gAboutBoxServices: IOTAAboutBoxServices;
  gAboutBoxIndex: Integer = 0;

// ---------------------------------------------------------------------------
// Procedimentos públicos (podem ser chamados externamente se necessário)
  // ---------------------------------------------------------------------------

  { Registra o ícone na Splash Screen do Delphi.
    Chamado automaticamente na seção initialization. }
procedure RegisterSplashScreen;
var
  lBitmap: HBITMAP;
begin

  lBitmap := LoadBitmap(HInstance, RES_SPLASH_ICON);
  if lBitmap <> 0 then
    SplashScreenServices.AddPluginBitmap(rsPackageName, // Nome do plugin exibido na splash
      lBitmap, // Handle do bitmap 24 x 24
      False, // IsUnregistered — False = pacote registrado
      rsLicenseText // Texto de licença
      );
end;

{ Registra o ícone e as informações na caixa "About" do Delphi.
  Chamado automaticamente na seção initialization. }
procedure RegisterAboutBox;
var
  lBitmap: HBITMAP;
begin
  if Supports(BorlandIDEServices, IOTAAboutBoxServices, gAboutBoxServices) then begin
    lBitmap := LoadBitmap(HInstance, RES_ABOUT_ICON);
    gAboutBoxIndex := gAboutBoxServices.AddPluginInfo(rsAboutTitle, // Título
      rsAboutCopyright + #13#10 + #13#10 + rsAboutDescription, // Texto completo
      lBitmap, // Handle do bitmap 48 x 48
      False, // IsUnregistered
      rsLicenseText // Licença
      );
  end;
end;

{ Remove o registro do About Box ao descarregar o pacote.
  Chamado automaticamente na seção finalization. }
procedure UnregisterAboutBox;
begin
  if (gAboutBoxIndex <> 0) and Assigned(gAboutBoxServices) then begin
    gAboutBoxServices.RemovePluginInfo(gAboutBoxIndex);
    gAboutBoxIndex := 0;
    gAboutBoxServices := nil;
  end;
end;

function EvRegisterWizard(const AWizard: IOTAWizard): Boolean;
begin
  CodeSite.Send(csmLevel1, 'LibraryWizardProc', AWizard.GetName);
  Result := True;
end;

procedure RegisterWizardEvent;
begin
  CodeSite.Send( csmLevel3, 'MyPlugins.SplashScreen', 'initialization' );
  LibraryWizardProc := EvRegisterWizard;
end;

procedure UnregisterWizardEvent;
begin
  LibraryWizardProc := nil;
end;

// ---------------------------------------------------------------------------
// Inicialização / Finalização automáticas
// ---------------------------------------------------------------------------

initialization

RegisterWizardEvent();
RegisterSplashScreen();
RegisterAboutBox();

finalization

UnregisterAboutBox();
UnregisterWizardEvent();

end.
