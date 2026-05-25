unit MyPlugins.Telemetry;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.IOUtils;

function TelemetryEnabled: Boolean;
procedure InitializeTelemetry(const AEndpoint, APluginVersion: string);
procedure SetTelemetryEnabled(const AEnabled: Boolean);
procedure SendTelemetryEvent(const AEvent: string; const AEventName: string = ''; const AMeta: string = '');
procedure FlushTelemetry(ATimeoutMs: Integer = 5000);

implementation

uses
  Winapi.Windows,
  Winapi.WinHttp,
  System.DateUtils,
  System.Threading;

const
  TELEMETRY_APP_FOLDER = 'delphi-ota';
  TELEMETRY_CONFIG_FILE = 'telemetry.json';
  TELEMETRY_DEFAULT_ENDPOINT = 'https://telemetry.example.com/collect';
  DEFAULT_PLUGIN_VERSION = '0.1.0';

var
  FEndpoint: string;
  FPluginVersion: string;
  FClientId: string;
  FConsent: Boolean;
  FConfigPath: string;
  FInitialized: Boolean;
  FCurrentSendThread: TThread;

function GetTelemetryFolder: string;
begin
  Result := GetEnvironmentVariable('APPDATA');
  if Result.IsEmpty then
    Result := TPath.GetHomePath;
  Result := TPath.Combine(Result, TELEMETRY_APP_FOLDER);
end;

function GetTelemetryConfigPath: string;
begin
  Result := TPath.Combine(GetTelemetryFolder, TELEMETRY_CONFIG_FILE);
end;

function CreateNewClientId: string;
var
  lGuid: TGUID;
begin
  if CreateGUID(lGuid) = S_OK then
    Result := GUIDToString(lGuid)
  else
    Result := '00000000-0000-0000-0000-000000000000';
end;

function GetIsoUtcTimestamp: string;
begin
  Result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', Now);
end;

function GetOsName: string;
begin
  Result := TOSVersion.Name;
end;

function GetDelphiVersion: string;
begin
  Result := TPath.GetFileName(ParamStr(0));
end;

procedure SaveTelemetryConfig;
var
  lJson: TJSONObject;
  lConfigDir: string;
begin
  lConfigDir := GetTelemetryFolder;
  if not TDirectory.Exists(lConfigDir) then
    TDirectory.CreateDirectory(lConfigDir);

  lJson := TJSONObject.Create;
  try
    lJson.AddPair('client_id', FClientId);
    lJson.AddPair('consent', TJSONBool.Create(FConsent));
    lJson.AddPair('last_saved', TJSONString.Create(GetIsoUtcTimestamp));
    TFile.WriteAllText(FConfigPath, lJson.ToJSON, TEncoding.UTF8);
  finally
    lJson.Free;
  end;
end;

procedure LoadTelemetryConfig;
var
  lJson: TJSONObject;
  lValue: TJSONValue;
  lText: string;
begin
  FClientId := CreateNewClientId;
  FConsent := False;
  if not TFile.Exists(FConfigPath) then
  begin
    SaveTelemetryConfig;
    Exit;
  end;

  try
    lText := TFile.ReadAllText(FConfigPath, TEncoding.UTF8);
    lJson := TJSONObject.ParseJSONValue(lText) as TJSONObject;
    if Assigned(lJson) then
    try
      lValue := lJson.GetValue('client_id');
      if Assigned(lValue) and (lValue is TJSONString) and not TJSONString(lValue).Value.IsEmpty then
        FClientId := TJSONString(lValue).Value;

      lValue := lJson.GetValue('consent');
      if Assigned(lValue) and (lValue is TJSONBool) then
        FConsent := TJSONBool(lValue).AsBoolean;
    finally
      lJson.Free;
    end;
  except
    FConsent := False;
  end;
end;

function ParseUrl(const AUrl: string; out AScheme, AHost, APath: string; out APort: Integer): Boolean;
var
  lUrl: string;
  lPos, lPortPos: Integer;
begin
  Result := False;
  lUrl := AUrl.Trim;
  AScheme := '';
  AHost := '';
  APath := '';
  APort := 0;

  if lUrl.StartsWith('https://') then
  begin
    AScheme := 'https';
    Delete(lUrl, 1, Length('https://'));
    APort := INTERNET_DEFAULT_HTTPS_PORT;
  end
  else if lUrl.StartsWith('http://') then
  begin
    AScheme := 'http';
    Delete(lUrl, 1, Length('http://'));
    APort := INTERNET_DEFAULT_HTTP_PORT;
  end
  else
    Exit;

  lPos := lUrl.IndexOf('/');
  if lPos > 0 then
  begin
    AHost := lUrl.Substring(0, lPos);
    APath := lUrl.Substring(lPos);
  end
  else
  begin
    AHost := lUrl;
    APath := '/';
  end;

  lPortPos := AHost.IndexOf(':');
  if lPortPos > 0 then
  begin
    APort := StrToIntDef(AHost.Substring(lPortPos + 1), APort);
    AHost := AHost.Substring(0, lPortPos);
  end;

  Result := AHost <> '';
end;

procedure PostTelemetryPayload(const APayload: string);
var
  lSession, lConnect, lRequest: HINTERNET;
  lScheme, lHost, lPath: string;
  lPort: Integer;
  lHeaders: string;
  lBuffer: TBytes;
  lStatusCode: DWORD;
  lStatusLen: DWORD;
  lFlags: DWORD;
begin
  if not ParseUrl(FEndpoint, lScheme, lHost, lPath, lPort) then
    Exit;

  lFlags := 0;
  if SameText(lScheme, 'https') then
    lFlags := WINHTTP_FLAG_SECURE;

  lSession := WinHttpOpen(PWideChar('delphi-ota telemetry'), WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,
    WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);
  if lSession = nil then
    Exit;
  try
    lConnect := WinHttpConnect(lSession, PWideChar(lHost), lPort, 0);
    if lConnect = nil then
      Exit;
    try
      lRequest := WinHttpOpenRequest(lConnect, 'POST', PWideChar(lPath), nil,
        WINHTTP_NO_REFERER, WINHTTP_DEFAULT_ACCEPT_TYPES, lFlags);
      if lRequest = nil then
        Exit;
      try
        lHeaders := 'Content-Type: application/json'#13#10;
        lBuffer := TEncoding.UTF8.GetBytes(APayload);
        if not WinHttpSendRequest(lRequest, PWideChar(lHeaders), Length(lHeaders),
          @lBuffer[0], Length(lBuffer), Length(lBuffer), 0) then
          Exit;
        if not WinHttpReceiveResponse(lRequest, nil) then
          Exit;
        lStatusLen := SizeOf(lStatusCode);
        if WinHttpQueryHeaders(lRequest,
          WINHTTP_QUERY_STATUS_CODE or WINHTTP_QUERY_FLAG_NUMBER,
          WINHTTP_HEADER_NAME_BY_INDEX, @lStatusCode, lStatusLen,
          WINHTTP_NO_HEADER_INDEX) then
        begin
          if (lStatusCode >= 200) and (lStatusCode < 300) then
            Exit;
        end;
      finally
        WinHttpCloseHandle(lRequest);
      end;
    finally
      WinHttpCloseHandle(lConnect);
    end;
  finally
    WinHttpCloseHandle(lSession);
  end;
end;

procedure DoSendTelemetryEvent(const AEvent, AEventName, AMeta: string);
var
  lPayload: TJSONObject;
  lMetaValue: TJSONValue;
begin
  if not FInitialized or not FConsent then
    Exit;
  if AEvent.Trim.IsEmpty then
    Exit;

  lPayload := TJSONObject.Create;
  try
    lPayload.AddPair('client_id', FClientId);
    lPayload.AddPair('plugin_version', FPluginVersion);
    lPayload.AddPair('event', AEvent);
    if not AEventName.Trim.IsEmpty then
      lPayload.AddPair('event_name', AEventName)
    else
      lPayload.AddPair('event_name', TJSONNull.Create);
    lPayload.AddPair('delphi_version', GetDelphiVersion);
    lPayload.AddPair('os', GetOsName);
    lPayload.AddPair('timestamp', GetIsoUtcTimestamp);

    if not AMeta.Trim.IsEmpty then
    begin
      lMetaValue := TJSONObject.ParseJSONValue(AMeta);
      if Assigned(lMetaValue) then
      try
        lPayload.AddPair('meta', lMetaValue);
      except
        lMetaValue.Free;
        lPayload.AddPair('meta', TJSONNull.Create);
      end
      else
        lPayload.AddPair('meta', TJSONNull.Create);
    end
    else
      lPayload.AddPair('meta', TJSONNull.Create);

    if Assigned(FCurrentSendThread) then
    begin
      try
        FCurrentSendThread.WaitFor;
      except
      end;
      FreeAndNil(FCurrentSendThread);
    end;

    FCurrentSendThread := TThread.CreateAnonymousThread(
      procedure
      begin
        try
          PostTelemetryPayload(lPayload.ToJSON);
        except
          // ignore telemetry errors
        end;
      end);
    FCurrentSendThread.Start;
  finally
    lPayload.Free;
  end;
end;

function TelemetryEnabled: Boolean;
begin
  Result := FConsent;
end;

procedure InitializeTelemetry(const AEndpoint, APluginVersion: string);
begin
  if FInitialized then
    Exit;

  FEndpoint := AEndpoint;
  if FEndpoint.IsEmpty then
    FEndpoint := TELEMETRY_DEFAULT_ENDPOINT;

  FPluginVersion := APluginVersion;
  if FPluginVersion.IsEmpty then
    FPluginVersion := DEFAULT_PLUGIN_VERSION;

  FConfigPath := GetTelemetryConfigPath;
  LoadTelemetryConfig;
  FInitialized := True;
end;

procedure SetTelemetryEnabled(const AEnabled: Boolean);
begin
  if not FInitialized then
    InitializeTelemetry(TELEMETRY_DEFAULT_ENDPOINT, DEFAULT_PLUGIN_VERSION);

  if FConsent = AEnabled then
    Exit;

  FConsent := AEnabled;
  SaveTelemetryConfig;

  if FConsent then
    DoSendTelemetryEvent('install', '', '')
  else
    DoSendTelemetryEvent('user_opt_out', '', '');
end;

procedure SendTelemetryEvent(const AEvent: string; const AEventName: string = ''; const AMeta: string = '');
begin
  DoSendTelemetryEvent(AEvent, AEventName, AMeta);
end;

procedure FlushTelemetry(ATimeoutMs: Integer = 5000);
begin
  if Assigned(FCurrentSendThread) then
  try
    FCurrentSendThread.WaitFor;
  except
  end;
  FreeAndNil(FCurrentSendThread);
end;

initialization
  InitializeTelemetry(TELEMETRY_DEFAULT_ENDPOINT, DEFAULT_PLUGIN_VERSION);

finalization
  FlushTelemetry(2000);

end.
