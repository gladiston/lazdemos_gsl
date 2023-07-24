unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Types, LCLType;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    cbLista: TComboBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure cbListaDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

const
  Maracuja='Maracujá';
  Acai='Açaí';
  Avela='Avelã';
  Melao='Melão';
  Maca='Maçã';
  Mamao='Mamão';

procedure TForm1.FormCreate(Sender: TObject);
begin
  cbLista.Clear;
  cbLista.Items.AddPair(Maracuja, 'cod_maracuja');
  cbLista.Items.AddPair(Acai,  'cod_acai');
  cbLista.Items.AddPair(Avela,  'cod_avela');
  cbLista.Items.AddPair(Melao,  'cod_melao');
  cbLista.Items.AddPair(Maca,  'cod_maca');
  cbLista.Items.AddPair(Mamao,  'cod_mamao');
  cbLista.ItemIndex:=-1;
  Memo1.Clear;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Fruta_Escolhida_Par_Nome:String;
  Fruta_Escolhida_Par_Valor:String;
begin
  if cbLista.ItemIndex>=0 then
  begin
    Fruta_Escolhida_Par_Nome := cbLista.Items.Names[cbLista.ItemIndex];
    Fruta_Escolhida_Par_Valor:= cbLista.items.Values[Fruta_Escolhida_Par_Nome];
    Memo1.Lines.Add('Fruta escolhida: ');
    Memo1.Lines.Add('  Nome: '+Fruta_Escolhida_Par_Nome);
    Memo1.Lines.Add('  Valor: '+Fruta_Escolhida_Par_Valor);
  end;
end;

procedure TForm1.cbListaDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
begin
  with (Control as TComboBox) do
  begin
    if odSelected in State then       // requer unit LCLType
    begin
      Brush.Color := clWhite;
      Font.Color := clBlack;
    end;
    Canvas.FillRect(ARect);
    Canvas.TextOut(ARect.Left, ARect.Top, Items.Names[Index]);
  end;
end;

end.

