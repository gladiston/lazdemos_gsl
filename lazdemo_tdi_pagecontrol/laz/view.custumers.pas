unit view.custumers;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons;

type

  { TfmCustumers }

  TfmCustumers = class(TForm)
    BtnClose: TBitBtn;
    Memo1: TMemo;
    Panel1: TPanel;
    procedure BtnCloseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  fmCustumers: TfmCustumers;

implementation

{$R *.lfm}

{ TfmCustumers }

procedure TfmCustumers.FormCreate(Sender: TObject);
begin
  // only to be different of others forms, will change the color form
  memo1.ParentColor:=true;
  Randomize;
  Self.Color:=Random($FFFFFF);
  // diffrent text in memo to show form name and create timestamp
  memo1.text:='Formulario '+Self.Name+' criado em '+FormatDateTime('dd/mm/yyyy hh:nn:ss', now);
  // necessary to permit this form be dokackable in another form site
  Self.DragKind:=dkDock;
  Self.DragMode:=dmAUtomatic;
end;

procedure TfmCustumers.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  CloseAction:=caFree;
end;

procedure TfmCustumers.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

end.

