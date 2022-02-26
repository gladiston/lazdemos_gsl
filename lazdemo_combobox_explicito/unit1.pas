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
  cbLista.Items.Add(Maracuja);
  cbLista.Items.Add(Acai);
  cbLista.Items.Add(Avela);
  cbLista.Items.Add(Melao);
  cbLista.Items.Add(Maca);
  cbLista.Items.Add(Mamao);
  cbLista.ItemIndex:=-1;
  Memo1.Clear;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  sFrutaEscolhida:String;
begin
  if cbLista.ItemIndex>=0 then
  begin
    sFrutaEscolhida:=cbLista.Items[cbLista.ItemIndex];
    Memo1.Lines.Add('escolheu: '+sFrutaEscolhida);
  end;
end;

end.

