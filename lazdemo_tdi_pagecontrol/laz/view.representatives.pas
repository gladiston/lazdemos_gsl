unit view.representatives;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons;

type

  { TfmRepresentatives }

  TfmRepresentatives = class(TForm)
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
  fmRepresentatives: TfmRepresentatives;

implementation

{$R *.lfm}

{ TfmRepresentatives }

procedure TfmRepresentatives.FormCreate(Sender: TObject);
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

procedure TfmRepresentatives.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
   CloseAction:=caFree;
end;

procedure TfmRepresentatives.BtnCloseClick(Sender: TObject);
begin
  close;
end;

end.

