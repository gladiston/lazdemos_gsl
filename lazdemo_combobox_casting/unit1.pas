unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    cbLista: TComboBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

const
  Maracuja='Maracujá';
  Acai='Açaí';
  Avela='Avelã';
  Melao='Melão';
  Maca='Maçã';
  Mamao='Mamão';

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  cbLista.Clear;
  cbLista.Items.AddObject(Maracuja, TObject(5));
  cbLista.Items.AddObject(Acai, TObject(10));
  cbLista.Items.AddObject(Avela, TObject(15));
  cbLista.Items.AddObject(Melao, TObject(20));
  cbLista.Items.AddObject(Maca, TObject(25));
  cbLista.Items.AddObject(Mamao, TObject(30));
  cbLista.ItemIndex:=-1;
  Memo1.Clear;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  FrutaCodigoEscolhida:Integer;
begin
  if cbLista.ItemIndex>=0 then
  begin
    FrutaCodigoEscolhida:=PtrUInt(cbLista.Items.Objects[cbLista.ItemIndex]);
    Memo1.Lines.Add('codigo escolhido: '+IntToStr(FrutaCodigoEscolhida));
  end;
end;

end.

