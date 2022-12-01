unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Panel1: TPanel;
    Shape1: TShape;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  // o que fizemos visualmente, podemos fazer de maneira programatica:
  // panel sem bordas e com espaçamento interno de 4
  panel1.BevelInner:=bvNone;
  panel1.BevelOuter:=bvNone;
  panel1.BorderStyle:=bsNone;
  panel1.BorderSpacing.InnerBorder:=4;
  // escolhendo o desenho do shape
  shape1.shape:=stRoundRect;
  // o edit1 momentaneamente não pode ter um parent porque usarei o insertcontrol
  edit1.parent:=nil;
  panel1.InsertControl(edit1);
  // o edit1 precisa ter um espaço externo para não encostar no shape
  edit1.BorderSpacing.Around:=4;
  // vamos fazer o edit1 ocupar todo o panel
  edit1.align:=alClient;
  // por um acaso é um edit, mas poderia ter sido um memo ou outro componente qualquer.
end;

end.

