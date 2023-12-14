unit fprincipal;

{$mode objfpc}{$H+}

interface

{ Demo Drag and Drop de TEdit para TEdit }

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  RTTICtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnLigarDragAndDrop_MemoTexto: TSpeedButton;
    btnLigarDragAndDrop_Origem: TSpeedButton;
    edtDestino: TEdit;
    edtOrigem: TEdit;
    gb_MemoTexto: TGroupBox;
    gb_Origem: TGroupBox;
    lblDestino: TLabel;
    MemoTexto: TMemo;
    procedure btnLigarDragAndDrop_MemoTextoClick(Sender: TObject);
    procedure btnLigarDragAndDrop_OrigemClick(Sender: TObject);
    procedure edtDestinoDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure edtDestinoDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
  private

  public

  end;

var
  Form1: TForm1;

implementation
uses
  StrUtils;
{$R *.lfm}

{ TForm1 }

procedure TForm1.btnLigarDragAndDrop_OrigemClick(Sender: TObject);
begin
  if edtOrigem.DragMode=dmAutomatic then
    edtOrigem.DragMode:=dmManual
  else
    edtOrigem.DragMode:=dmAutomatic;
  btnLigarDragAndDrop_Origem.Down:=(edtOrigem.DragMode=dmAutomatic);
end;

procedure TForm1.edtDestinoDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  sTexto:String;
begin
  // Sender refere-se a quem está sendo recebendo, neste exemplo é sempre
  //   edtDestino, mas você pode usá-lo para identificá-lo quando compartilhar
  //   o mesmo evento com mais componentes.
  // Source é o objeto de origem.
  // X e Y são as coordenadas de tela onde o mouse está, na prática você só usará
  //   para calcular/capturar o que está naquela posição usando métodos como
  //   ItemAtPos, exemplo:
  //   DropPosition := TListBox(Sender).ItemAtPos(Point(X, Y), True);
  //   No exemplo acima eu consegui pegar qual o itemindex de um TListBox antes
  //     mesmo de soltá-lo.
  // Alerta: Evite usar nomes literais de componentes, prefira sempre
  //   referenciá-los com Sender ou Source, para isso você vai precisar quase
  //   sempre usar tyecasting como no exemplo abaixo.
  if (Source is TEdit) then
  begin
    sTexto:=TEdit(Source).Text;
    TEdit(Sender).Text:=sTexto;
  end;

end;

procedure TForm1.edtDestinoDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  sTexto:String;
begin
  // O evento OnDragOver é disparado quando um objeto está sendo arrastado  e o
  //   cursor do mouse passa por cima deste componente, se o Accept resultar em
  //   'true' então o cursor do mouse muda para indicar que soltar nele é
  //   aceitável para o programa e se isso de fato acontecer, então o
  //   evento OnDragDrop será disparado.
  // Sender refere-se a quem está sendo recebendo, neste exemplo é sempre
  //   edtDestino, mas você pode usá-lo para identificá-lo quando compartilhar
  //   o mesmo evento com mais componentes.
  // Source é o objeto de origem, você precisará utilizá-lo quase sempre
  //   para validar o que esta vindo do componente de origem e então o Accept
  //   seja ‘true’ para prosseguir ou ‘falso’ para negar a ação.
  // X e Y são as coordenadas de tela onde o mouse está, na prática você só usará
  //   para calcular/capturar o que está naquela posição usando métodos como
  //   ItemAtPos, exemplo:
  //   DropPosition := TListBox(Sender).ItemAtPos(Point(X, Y), True);
  //   No exemplo acima eu consegui pegar qual o itemindex de um TListBox antes
  //     mesmo de soltá-lo.
  Accept:=false;
  if (Source is TEdit) then
  begin
    sTexto:=TEdit(Source).Text;
    Accept:=(Pos('*', sTexto)>0); // só aceita se tiver um asterisco no texto
  end;
  lblDestino.caption:='Destino: ('+IfThen(Accept,'aceitou', 'negou')+' a oferta)';
end;

procedure TForm1.btnLigarDragAndDrop_MemoTextoClick(Sender: TObject);
begin
  if memoTexto.DragMode=dmAutomatic then
    memoTexto.DragMode:=dmManual
  else
    memoTexto.DragMode:=dmAutomatic;
  btnLigarDragAndDrop_MemoTexto.Down:=(memoTexto.DragMode=dmAutomatic);
end;

end.

