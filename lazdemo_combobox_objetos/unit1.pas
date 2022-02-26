unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

  { TFruta }
  type TFruta=class(TObject)
  private
    FNome: string;
    FPesoGrama: Integer;
    FCodigo: Integer;
  public
    constructor Create(ANome:String; APesoGrama:Integer; ACodigo:Integer);
    destructor Destroy; override;
  published
    property Nome: string read FNome write FNome;
    property PesoGrama: Integer read FPesoGrama write FPesoGrama;
    property Codigo:Integer read FCodigo write FCodigo;
  end;

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

{ TFruta }

constructor TFruta.Create(ANome: String; APesoGrama: Integer; ACodigo: Integer);
begin
  Nome := ANome;
  PesoGrama:=APesoGrama;
  Codigo:=ACodigo;
end;

destructor TFruta.Destroy;
begin
  inherited Destroy;
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
  cbLista.Clear;
  cbLista.Items.AddObject(Maracuja, TFruta.Create(Maracuja,550,5));
  cbLista.Items.AddObject(Acai, TFruta.Create(Acai,300,10));
  cbLista.Items.AddObject(Avela, TFruta.Create(Avela,15,15));
  cbLista.Items.AddObject(Melao, TFruta.Create(Melao,500,20));
  cbLista.Items.AddObject(Maca, TFruta.Create(Maca,55,25));
  cbLista.Items.AddObject(Mamao, TFruta.Create(Mamao,700,30));
  cbLista.ItemIndex:=-1;
  Memo1.Clear;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Fruta_Escolhida:TFruta;
begin
  if cbLista.ItemIndex>=0 then
  begin
    Fruta_Escolhida := TFruta(cbLista.Items.Objects[cbLista.ItemIndex]);
    Memo1.Lines.Add('Fruta escolhida: '+Fruta_Escolhida.Nome);
    Memo1.Lines.Add('  Codigo: '+IntToStr(Fruta_Escolhida.Codigo));
    Memo1.Lines.Add('  Peso aproximado gramas: '+IntToStr(Fruta_Escolhida.PesoGrama));
  end;
end;

end.

