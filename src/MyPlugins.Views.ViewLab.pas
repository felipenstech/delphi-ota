unit MyPlugins.Views.ViewLab;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  System.Actions,
  Vcl.ActnList,
  System.ImageList,
  Vcl.ImgList;

type
  TViewLab = class(TForm)
    ImageList1: TImageList;
    ActionList1: TActionList;
    Action1: TAction;
  private

  public

  end;

implementation


{$R *.dfm}

end.
