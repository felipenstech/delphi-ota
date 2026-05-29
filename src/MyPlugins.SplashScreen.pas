unit MyPlugins.SplashScreen;

interface

implementation

uses
  CodeSiteLogging,
  Winapi.Windows,
  System.SysUtils,
  ToolsAPI,
  DesignIntf,
  MyPlugins.Strings;

const
  RES_SPLASH_ICON = 'ID_SPLASH';
  RES_ABOUT_ICON = 'ID_ABOUT';

var
  gAboutBoxServices: IOTAAboutBoxServices;
  gAboutBoxIndex: Integer = 0;

procedure RegisterSplashScreen;
var
  lBitmap: HBITMAP;
begin
  lBitmap := LoadBitmap(HInstance, RES_SPLASH_ICON);
  if lBitmap <> 0 then
    SplashScreenServices.AddPluginBitmap(rsPackageName,
      lBitmap,
      False,
      rsLicenseText
      );
end;

procedure RegisterAboutBox;
var
  lBitmap: HBITMAP;
begin
  if Supports(BorlandIDEServices, IOTAAboutBoxServices, gAboutBoxServices) then begin
    lBitmap := LoadBitmap(HInstance, RES_ABOUT_ICON);
    gAboutBoxIndex := gAboutBoxServices.AddPluginInfo(rsAboutTitle,
      rsAboutCopyright + #13#10 + #13#10 + rsAboutDescription,
      lBitmap,
      False,
      rsLicenseText
      );
  end;
end;

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
  CodeSite.Send(csmLevel3, 'MyPlugins.SplashScreen', 'initialization');
  LibraryWizardProc := EvRegisterWizard;
end;

procedure UnregisterWizardEvent;
begin
  LibraryWizardProc := nil;
end;

initialization

RegisterWizardEvent();
RegisterSplashScreen();
RegisterAboutBox();

finalization

UnregisterAboutBox();
UnregisterWizardEvent();

end.
