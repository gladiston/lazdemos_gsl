unit view.main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnChangeButton: TButton;
    btnLoginNameClear: TSpeedButton;
    edtLoginName: TEdit;
    lblLoginName: TLabel;
    procedure btnChangeButtonClick(Sender: TObject);
    procedure btnLoginNameClearClick(Sender: TObject);
    procedure edtLoginNameChange(Sender: TObject);
    procedure edtLoginNameMouseLeave(Sender: TObject);

      procedure edtLoginNameMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btnChangeButtonClick(Sender: TObject);
begin
  // antes de embutir com o TEdit, o botão não pode ter parent
  btnLoginNameClear.Parent:=nil;
  // inserindo o botão no controle do tedit
  edtLoginName.InsertControl(btnLoginNameClear);
  // alinhando a direita, flat e cursor handpoint
  btnLoginNameClear.Align:=alRight;
  btnLoginNameClear.Flat:=true;
  btnLoginNameClear.Cursor:=crHandPoint;
  // as vezes um controle como o tedit quer jogar algo
  // por cima do nosso botão, então forçamos o repaint
  btnLoginNameClear.RePaint;

end;

procedure TForm1.btnLoginNameClearClick(Sender: TObject);
begin
  edtLoginName.Clear;
end;

procedure TForm1.edtLoginNameChange(Sender: TObject);
begin
  btnLoginNameClear.RePaint;
end;

procedure TForm1.edtLoginNameMouseLeave(Sender: TObject);
begin
    btnLoginNameClear.RePaint;
end;

procedure TForm1.edtLoginNameMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
    btnLoginNameClear.RePaint;
end;

end.

