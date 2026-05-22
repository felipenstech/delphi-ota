unit uSplashScreen;

{ ============================================================================
  uSplashScreen.pas
  Responsável por registrar uma imagem (bitmap) na Splash Screen do Delphi
  e na caixa de diálogo "About" via Open Tools API (OTA).

  Como usar:
    1. Adicione este arquivo ao seu pacote (.dpk).
    2. Crie um arquivo de recursos (.rc) com as entradas:
         SPLASHICON  BITMAP  "splash_24x24.bmp"
         ABOUTICON   BITMAP  "about_48x48.bmp"
       Compile o .rc para gerar o .res e vincule-o usando a diretiva $R.
       O nome do .res deve ser "uSplashScreen.res" (mesmo nome desta unit).
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
  Windows,       // LoadBitmap, HInstance
  ToolsAPI,      // SplashScreenServices, IOTAAboutBoxServices, BorlandIDEServices
  SysUtils,      // Supports
  DesignIntf;    // (incluso indiretamente; necessário em alguns Delphis)

// ---------------------------------------------------------------------------
// Constantes: nomes dos recursos de bitmap no arquivo .res
// ---------------------------------------------------------------------------
const
  RES_SPLASH_ICON = 'ID_SPLASH';   // Bitmap 24 x 24 px — Splash Screen
  RES_ABOUT_ICON  = 'ID_ABOUT';    // Bitmap 48 x 48 px — About Dialog

// ---------------------------------------------------------------------------
// Variáveis de controle do About Box
// ---------------------------------------------------------------------------
var
  GAboutBoxServices : IOTAAboutBoxServices;
  GAboutBoxIndex    : Integer = 0;

// ---------------------------------------------------------------------------
// Resource Strings — armazenadas no binário (.bpl), editáveis sem recompilação
// ---------------------------------------------------------------------------
resourcestring
  { Nome exibido na Splash Screen ao lado do ícone }
  rsPackageName = 'Meu Pacote de Componentes';

  { Texto de licença exibido logo abaixo do nome na Splash Screen }
  rsLicenseText = 'Licença: Open Source / Freeware';

  { Título exibido na aba do About Box }
  rsAboutTitle = 'Meu Pacote de Componentes';

  { Linha(s) de copyright exibidas no About Box }
  rsAboutCopyright = 'Copyright © 2024 – Seu Nome / Sua Empresa Ltda.';

  { Descrição completa exibida na área de texto do About Box }
  rsAboutDescription =
    'Meu Pacote de Componentes é uma coleção de controles e utilitários ' +
    'desenvolvidos para agilizar o desenvolvimento de aplicações Delphi. ' +
    'Visite https://github.com/felipenstech/delphi-ota para mais informações.';

// ---------------------------------------------------------------------------
// Procedimentos públicos (podem ser chamados externamente se necessário)
// ---------------------------------------------------------------------------

{ Registra o ícone na Splash Screen do Delphi.
  Chamado automaticamente na seção initialization. }
procedure RegisterSplashScreen;
var
  LBitmap: HBITMAP;
begin

  LBitmap := LoadBitmap(HInstance, RES_SPLASH_ICON);
  if LBitmap <> 0 then
    SplashScreenServices.AddPluginBitmap(
      rsPackageName,   // Nome do plugin exibido na splash
      LBitmap,         // Handle do bitmap 24 x 24
      False,           // IsUnregistered — False = pacote registrado
      rsLicenseText    // Texto de licença
    );
end;

{ Registra o ícone e as informações na caixa "About" do Delphi.
  Chamado automaticamente na seção initialization. }
procedure RegisterAboutBox;
var
  LBitmap: HBITMAP;
begin
  if Supports(BorlandIDEServices, IOTAAboutBoxServices, GAboutBoxServices) then
  begin
    LBitmap := LoadBitmap(HInstance, RES_ABOUT_ICON);
    GAboutBoxIndex := GAboutBoxServices.AddPluginInfo(
      rsAboutTitle,                                            // Título
      rsAboutCopyright + #13#10 + #13#10 + rsAboutDescription, // Texto completo
      LBitmap,                                                 // Handle do bitmap 48 x 48
      False,                                                   // IsUnregistered
      rsLicenseText                                            // Licença
    );
  end;
end;

{ Remove o registro do About Box ao descarregar o pacote.
  Chamado automaticamente na seção finalization. }
procedure UnregisterAboutBox;
begin
  if (GAboutBoxIndex <> 0) and Assigned(GAboutBoxServices) then
  begin
    GAboutBoxServices.RemovePluginInfo(GAboutBoxIndex);
    GAboutBoxIndex    := 0;
    GAboutBoxServices := nil;
  end;
end;

// ---------------------------------------------------------------------------
// Inicialização / Finalização automáticas
// ---------------------------------------------------------------------------

initialization
  RegisterSplashScreen;
  RegisterAboutBox;

finalization
  UnregisterAboutBox;

end.
