object frmTelemetryConfig: TfrmTelemetryConfig
  Left = 0
  Top = 0
  Caption = 'Telemetry Configuration'
  ClientHeight = 271
  ClientWidth = 380
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object dlcRoot: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 380
    Height = 271
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 8
    object drgMainContent: TdxLayoutGroup
      AlignHorz = ahLeft
      AlignVert = avTop
      ButtonOptions.Buttons = <>
      Hidden = True
      ShowBorder = False
      Index = -1
    end
    object dxLayoutGroup1: TdxLayoutGroup
      Parent = drgMainContent
      AlignHorz = ahClient
      AlignVert = avTop
      CaptionOptions.Text = 'New Group'
      ButtonOptions.Buttons = <>
      Index = 0
    end
  end
end
