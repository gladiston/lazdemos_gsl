unit fprincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ExtCtrls;

type

  { TfmPrincipal }

  TfmPrincipal = class(TForm)
    BtnDesligar: TBitBtn;
    BtnGray: TBitBtn;
    BtnLigar: TBitBtn;
    BtnStateChecked: TBitBtn;
    BtnStateUnChecked: TBitBtn;
    CheckBox1: TCheckBox;
    gb_nome: TGroupBox;
    Memo1: TMemo;
    pnlClient: TPanel;
    pnlDir: TPanel;
    pnlHeader: TPanel;
    procedure BtnCheckLadoClick(Sender: TObject);
    procedure BtnLigarClick(Sender: TObject);
    procedure BtnDesligarClick(Sender: TObject);
    procedure BtnGrayClick(Sender: TObject);
    procedure BtnStateCheckedClick(Sender: TObject);
    procedure BtnStateUnCheckedClick(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox1ChangeBounds(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FBtnCheckLado: TBitBtn;
  public

  end;

var
  fmPrincipal: TfmPrincipal;

implementation
uses
  typinfo;

{$R *.lfm}

{ TfmPrincipal }

procedure TfmPrincipal.BtnLigarClick(Sender: TObject);
begin
  CheckBox1.Checked:=true;
end;

procedure TfmPrincipal.BtnCheckLadoClick(Sender: TObject);
begin
  if (CheckBox1.Alignment=taRightJustify) then
  begin
    CheckBox1.Alignment:=taLeftJustify;
  end
  else
  begin
     CheckBox1.Alignment:=taRightJustify;
  end;
  //CheckBox1ChangeBounds(Sender);
end;

procedure TfmPrincipal.BtnDesligarClick(Sender: TObject);
begin
  CheckBox1.Checked:=false;
end;

procedure TfmPrincipal.BtnGrayClick(Sender: TObject);
begin
  // Esse estado não dispara os eventos OnChange ou OnClick porque
  //   o estado será mudado para cbGrayed, mas se fosse o cbGrayed para
  //   outro estado, certamente dispararia os eventos mencionados
  if not CheckBox1.AllowGrayed then
    CheckBox1.AllowGrayed:=true;
  CheckBox1.State:=cbGrayed;

end;

procedure TfmPrincipal.BtnStateCheckedClick(Sender: TObject);
begin
  // mudando o estado para checked
  CheckBox1.State:=cbChecked;
end;

procedure TfmPrincipal.BtnStateUnCheckedClick(Sender: TObject);
begin
  // mudando o estado para unchecked
  CheckBox1.State:=cbUnChecked;
end;

procedure TfmPrincipal.CheckBox1Change(Sender: TObject);
var
  S:String;
begin
  // O evento onChange e onClick não são iguais,
  // onClick é chamado sempre que clicar ou quando o estado do checkbox
  //   tiver uma intervenção, mesmo que mude para o mesmo estado que
  //   estava antes.
  // onChange por outro lado requer que o estado seja alterado
  //   se o Checkbox estiver falso e eu repertir 3 vezes CheckBox1.Checked:=true;
  //   então o onChange será disparado apenas 1 vez porque nas vezes seguintes
  //   seu estado seria o mesmo.

  // TCheckBoxState para String (requer unit typinfo)
  S:=GetEnumName(TypeInfo(TCheckBoxState),Ord(checkbox1.State));
  memo1.Lines.add('Evento "OnChange" disparado. Checkbox agora é '+S);
end;

procedure TfmPrincipal.CheckBox1ChangeBounds(Sender: TObject);
var
  S:String;
begin
  // O evento "ChangeBounds" é disparado quando as dimensões do checkbox
  //   são alterados. Use esta opção quando deseja que um objeto visual
  //   siga as coordenadas do checkbox.
  S:=GetEnumName(TypeInfo(TCheckBoxState),Ord(checkbox1.State));
  memo1.Lines.add('Evento "ChangeBounds" disparado. Checkbox agora é '+S);

  // inserindo um botão no painel, se fosse no checkbox, o texto do
  // do checkbox o cobriria.
  if not pnlHeader.ContainsControl(FBtnCheckLado) then
    pnlHeader.InsertControl(FBtnCheckLado);

  // botão perseguirá a posição do checkbox
  FBtnCheckLado.Top:=FBtnCheckLado.Height+2;
  FBtnCheckLado.Left:=pnlHeader.width-(FBtnCheckLado.width+5);
  FBtnCheckLado.BringToFront;


end;

procedure TfmPrincipal.CheckBox1Click(Sender: TObject);
var
  S:String;
begin
  // TCheckBoxState para String (requer unit typinfo)
  S:=GetEnumName(TypeInfo(TCheckBoxState),Ord(checkbox1.State));
  memo1.Lines.add('Evento "OnClick" disparado. Checkbox agora é '+S);

end;

procedure TfmPrincipal.FormCreate(Sender: TObject);
begin
  FBtnCheckLado:=TBitBtn.Create(nil);
  FBtnCheckLado.Caption:='Mudar de lado';
  FBtnCheckLado.Width:=120;
  FBtnCheckLado.OnClick:=@BtnCheckLadoClick;
  memo1.clear;
end;

procedure TfmPrincipal.FormShow(Sender: TObject);
begin
  CheckBox1.SetFocus;

end;

end.

