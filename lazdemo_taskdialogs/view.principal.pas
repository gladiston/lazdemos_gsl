unit view.principal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnMessageDlg_Alt: TButton;
    BtnMessageDlg_Alt2: TButton;
    BtnShowMessage: TButton;
    BtnMessageDlg: TButton;
    BtnShowMessage_Alt: TButton;
    TaskDialog1: TTaskDialog;
    procedure BtnMessageDlg_Alt2Click(Sender: TObject);
    procedure BtnMessageDlg_AltClick(Sender: TObject);
    procedure BtnMessageDlgClick(Sender: TObject);
    procedure BtnShowMessageClick(Sender: TObject);
    procedure BtnShowMessage_AltClick(Sender: TObject);
  private
    procedure ShowMessage2(ATexto:String; ATitle:String='Informação:'; ACaption:String='');
  public

  end;

var
  Form1: TForm1;

const
   DEMO_TITLE='Esse é um exemplo de titulo';
   DEMO_CAPTION='Este é o cabecalho';
   DEMO_TEXT='Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed at risus neque. '+
     'Cras sit amet ligula ut justo commodo porta id ut enim. Nulla est lectus, '+
     'mollis sit amet vehicula id, volutpat eget mauris.';

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.BtnShowMessageClick(Sender: TObject);
begin
  ShowMessage('Não há quem goste de dor, que a procure e a queira ter, simplesmente porque é dor...');
end;

procedure TForm1.BtnMessageDlgClick(Sender: TObject);
begin
  case MessageDlg('Confirmação:', 'Posso remover o item selecionado?', mtConfirmation, [mbYes, mbNo], 0) of
  mrYes:
    begin
      ShowMessage2('Sim!');
    end;
  mrNo:
    begin
      ShowMessage2('Não!');
    end;
  end;
end;

procedure TForm1.BtnMessageDlg_AltClick(Sender: TObject);
begin
  with TTaskDialog.Create(self) do
  try
    Caption := 'Confirmação:';
    Title := 'Posso remover o item?';
    Text := 'Posso remover o item selecionado?';
    // CommonButtons é para mostrar os botões padrões que podem ser exibidos:
    // tcbOk, tcbYes, tcbNo, tcbCancel, tcbRetry, tcbClose e retornam ModalResult:
    // mrOK, mrYes, mrNo, mrCancel, mrRetry, mrClose
    CommonButtons := [tcbYes, tcbNo];
    // MainIcon é para exibir um ícone padrão que pode ser:
    // tdiNone, tdiWarning, tdiError, tdiInformation, tdiShield, tdiQuestion
    MainIcon := tdiQuestion;
    if Execute then
    begin
      // aqui analisamos a opção selecionada com o ModalResult
      if ModalResult = mrYes then
      begin
    	  // Clicou em Sim
     	  ShowMessage2('Sim!');
      end;
      if ModalResult = mrNo then
      begin
    	  // Clicou em Não
     	  ShowMessage2('Não!');
      end
    end;
  finally
    Free;
  end;
end;

procedure TForm1.BtnMessageDlg_Alt2Click(Sender: TObject);
begin
  with TTaskDialog.Create(self) do
  try
    Caption := 'Confirmação:';
    Title := 'Posso remover o item?';
    Text := 'Posso remover o item selecionado?';
    // CommonButtons deve estar vazio porque irei constituir meus próprios botões
    CommonButtons := [];
    // Note que cada botão acrescentado devo ter um ModalResult atribuído para ele
    with TTaskDialogButtonItem(Buttons.Add) do
    begin
  	  Caption := 'Remover';
      ModalResult := mrYes;
    end;
    with TTaskDialogButtonItem(Buttons.Add) do
    begin
      Caption := 'Manter';
  	  ModalResult := mrNo;
    end;
    MainIcon := tdiQuestion;
    if Execute then
    begin
      // como cada botão tem seu próprio ModalResult então fica fácil
      // detectar o botão que foi clicado.
      if ModalResult = mrYes then
      begin
     	  ShowMessage2('Item removido!');
      end;
      if ModalResult = mrNo then
      begin
     	  ShowMessage2('Item mantido!');
      end;
    end;
  finally
    Free;
  end;
end;

procedure TForm1.BtnShowMessage_AltClick(Sender: TObject);
begin
  with TTaskDialog.Create(self) do
  try
    Caption := 'Titulo da janela';
    Title := 'Titulo do texto';
    Text := 'Não há quem goste de dor, que a procure e a queira ter, simplesmente porque é dor...';
    CommonButtons := [tcbOk];   // (tcbOk, tcbYes, tcbNo, tcbCancel, tcbRetry, tcbClose);
    MainIcon := tdiInformation;    // (tdiNone, tdiWarning, tdiError, tdiInformation, tdiShield, tdiQuestion);
    Execute;
  finally
    Free;
  end

end;

procedure TForm1.ShowMessage2(ATexto: String; ATitle: String='Informação:'; ACaption: String='');
begin
  if ACaption=emptyStr
    then ACaption:=ExtractFileName(Application.ExeName);
  if ATitle=emptyStr
    then ATitle:='Informação:';
  with TTaskDialog.Create(self) do
  try
    Caption := ACaption;
    Title := ATitle;
    Text := ATexto;
    CommonButtons := [tcbOk];   // (tcbOk, tcbYes, tcbNo, tcbCancel, tcbRetry, tcbClose);
    MainIcon := tdiInformation;    // (tdiNone, tdiWarning, tdiError, tdiInformation, tdiShield, tdiQuestion);
    Execute;
  finally
    Free;
  end
end;



end.

