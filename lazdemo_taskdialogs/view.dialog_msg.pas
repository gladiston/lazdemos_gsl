unit view.dialog_msg;

{$mode ObjFPC}{$H+}

interface

uses
  Classes,
  SysUtils,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  ExtCtrls,
  StdCtrls,
  Buttons,
  LCLType,
  LCLIntf,
  HtmlView;

type

  { TfmDialog_msg }

  TfmDialog_msg = class(TForm)
    BtnCopyToClipBoard: TSpeedButton;
    BtnSaveScreens: TSpeedButton;
    BtnReposta_Sim: TSpeedButton;
    cbox_Nao_Mostrar_Novamente: TCheckBox;
    MyInfo: THtmlViewer;
    pnl_Aceite: TPanel;
    BtnReposta_Nao: TSpeedButton;
    pnlTitulo: TPanel;
    procedure BtnSaveScreensClick(Sender: TObject);
    procedure BtnCopyToClipBoardClick(Sender: TObject);
    procedure BtnReposta_NaoClick(Sender: TObject);
    procedure BtnReposta_SimClick(Sender: TObject);
    procedure Desfocar_Caption(Sender: TObject);
    procedure Focar_Caption(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure pnlTituloMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnlTituloMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    FMouseX:Integer;
    FMouseY:Integer;
    procedure CantosArredondados(const AWinControl: TWinControl);

  public

  end;

var
  fmDialog_msg: TfmDialog_msg;

procedure Dialog_Msg(
  ATitulo:String;
  ATexto:String;
  ABtn_Ok:String='Prosseguir';
  AForcarExibicao:Boolean=true);

function Dialog_Confirma(
  ATitulo:String;
  ATexto:String;
  ABtn_Sim:String='';
  ABtn_Nao:String='Prosseguir';
  AForcarExibicao:Boolean=true;
  AReq_DuplaConfirmacao:String=''):Boolean;


implementation
uses
  Math,
  model.dmprincipal,
  control.functions,
  control.conexao;


procedure Dialog_Msg(
  ATitulo:String;
  ATexto:String;
  ABtn_Ok:String='Prosseguir';
  AForcarExibicao:Boolean=true);
begin
  Dialog_Confirma(
    ATitulo,       // ATitulo
    ATexto,        // ATexto
    '',            //ABtn_Sim:String='';
    ABtn_Ok,       // ABtn_Nao
    AForcarExibicao,  // AForcarExibicao
    '');   // AReq_DuplaConfirmacao
end;

// Dialog_Confirma: Exibe uma mensagem ou pergunta na tela, para que seja apenas uma
// mensagem basta deixar uma das opções: ABtn_Sim ou ABtn_Nao como vazio.
// se as duas opções tiverem um label então o sistema assumirá que é uma janela
// do tipo de pergunta e retornará verdadeiro caso a opção 'Sim' seja a escolhida
function Dialog_Confirma(
  ATitulo:String;
  ATexto:String;
  ABtn_Sim:String='';
  ABtn_Nao:String='Prosseguir';
  AForcarExibicao:Boolean=true;
  AReq_DuplaConfirmacao:String=''):Boolean;
const
  _Chars = ['0'..'9', 'a'..'z', 'A'..'Z'];
var
  bhasTags:Boolean;
  bNao_Mostrar_Novamente:Boolean;
  sRefName:String;
  i:Integer;
  iMore_Width:Integer;
begin
  Result:=false;
  iMore_Width:=0;
  bNao_Mostrar_Novamente:=false;
  sRefName:=emptyStr;
  ATitulo:=Trim(ATitulo);
  if ATitulo=emptyStr then
  begin
    if (ABtn_Sim<>emptyStr) and (ABtn_Nao<>emptyStr) then
      ATitulo:='Confirmação:'
    else
      ATitulo:='Importante:';
  end;
  if (ABtn_Sim<>emptyStr) and (ABtn_Nao<>emptyStr) then
  begin
    AForcarExibicao:=true;
    iMore_Width:=80;
  end
  else
  begin
    AReq_DuplaConfirmacao:=emptystr;
  end;

  if (ABtn_Sim=emptyStr) or (ABtn_Nao=emptyStr) then
  begin
    if Assigned(Screen.ActiveForm) then
    begin
      if Screen.ActiveForm.HasParent then
        sRefName:=Screen.ActiveForm.Parent.Name+'.'+Screen.ActiveForm.Name
      else
        sRefName:=Screen.ActiveForm.Name;
      sRefName:=LeftStr(sRefName+'.'+Trim(ATitulo),254);
      for i:=1 to Length(ATitulo) do
      begin
        if (Copy(ATitulo, i, 1)[1] in _Chars) then
          sRefName:=sRefName+Copy(ATitulo, i, 1)[1];
      end;
    end;
    bNao_Mostrar_Novamente:=(ReadIniBool(sRefName, false));
  end;
  ATexto:=Trim(ATexto);
  if ATexto='' then
    ATexto:='Programador desatento esqueceu de colocar uma mensagem aqui. '+
      'Talvez ele esteja tomando muito café ;-)';
  bhasTags:=false;
  i:=Pos('<', ATexto);
  if i>0 then
  begin
    i:=Pos('>', ATexto, i+1);
    if i>0 then
      bhasTags:=true;
  end;
  if not bhasTags then
  begin
    ATexto:='<p>'+StringReplace(ATexto, sLineBreak, '</p><p>', [rfReplaceAll]);
    ATexto:=ATexto+'</p>';
    ATexto:=StringReplace(ATexto,'<p></p>','',[rfIgnoreCase, rfReplaceAll]);
  end;
  if (not bNao_Mostrar_Novamente) then
  begin
    try
      fmDialog_msg:=TfmDialog_msg.Create(nil);
      fmDialog_msg.pnlTitulo.Caption:=ATitulo;
      //fmDialog_msg.MemoInfo.Text:=ATexto;
      fmDialog_msg.MyInfo.Clear;
      fmDialog_msg.MyInfo.LoadFromString(ATexto);
      fmDialog_msg.BtnReposta_Sim.Caption:=ABtn_Sim;
      if ABtn_Sim=emptyStr then
        fmDialog_msg.BtnReposta_Sim.Visible:=false;
      fmDialog_msg.BtnReposta_Nao.Caption:=ABtn_Nao;
      if ABtn_Nao=emptyStr then
        fmDialog_msg.BtnReposta_Nao.Visible:=false;
      // Não posso permitir os dois botões invisiveis, neste caso
      //   deixo o 'Não como única possibilidade
      if (not fmDialog_msg.BtnReposta_Sim.Visible)
          and (not fmDialog_msg.BtnReposta_Nao.Visible) then
        fmDialog_msg.BtnReposta_Nao.Visible:=true;
      //fmDialog_msg.ActiveControl:=fmDialog_msg.BtnReposta_Nao;
      fmDialog_msg.cbox_Nao_Mostrar_Novamente.Checked:=false;
      fmDialog_msg.cbox_Nao_Mostrar_Novamente.Enabled:=(not AForcarExibicao);
      fmDialog_msg.Width:=fmDialog_msg.Width+iMore_Width;
      fmDialog_msg.Position:=poMainFormCenter;
      fmDialog_msg.ShowModal;
      if fmDialog_msg.ModalResult=mrYes then
        Result:=true;
      if not AForcarExibicao then
      begin
        WriteIniBool(sRefName, fmDialog_msg.cbox_Nao_Mostrar_Novamente.Checked);
      end;
    finally
      if Assigned(fmDialog_msg) then
        FreeAndNil(fmDialog_msg);
    end;
  end;
end;

{$R *.lfm}

{ TfmDialog_msg }

procedure TfmDialog_msg.CantosArredondados(const AWinControl: TWinControl);
var
  aBitmap:TBitmap;
begin
  try
    aBitmap:=TBitmap.Create;
    aBitmap.Monochrome:=true;
    aBitmap.Width:=AWinControl.Width;
    aBitmap.Height:=AWinControl.Height;
    aBitmap.Canvas.Brush.Color:=clBlack;
    aBitmap.Canvas.FillRect(0,0, AWinControl.Width, AWinControl.Height);
    aBitmap.Canvas.Brush.Color:=clWhite;
    aBitmap.Canvas.RoundRect(0,0, AWinControl.Width, AWinControl.Height, 20, 20);
    AWinControl.SetShape(aBitmap);
  finally
    aBitmap.Free;
  end;
end;


procedure TfmDialog_msg.FormCreate(Sender: TObject);
begin
  Caption:='Importante:';
  pnlTitulo.Caption:=Self.Caption;
  MyInfo.Clear;
  BorderStyle:=bsNone;
  BorderIcons:=[];
  Position:=poScreenCenter;
end;

procedure TfmDialog_msg.FormShow(Sender: TObject);
var
  iMaxWidth:Integer;
begin
  CantosArredondados(Self);
  CantosArredondados(pnlTitulo);
  //CantosArredondados(MyInfo);
  BtnReposta_Nao.AutoSize:=false;
  BtnReposta_Nao.Width:=BtnReposta_Nao.Width+64;
  BtnReposta_Sim.AutoSize:=false;
  BtnReposta_Sim.Width:=BtnReposta_Sim.Width+64;
  iMaxWidth:=Max(BtnReposta_Nao.Width, BtnReposta_Sim.Width);
  BtnReposta_Nao.Width:=iMaxWidth;
  BtnReposta_Sim.Width:=iMaxWidth;
end;

procedure TfmDialog_msg.pnlTituloMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FMouseX := X + pnlTitulo.Left;
  FMouseY := Y + pnlTitulo.Top;
end;

procedure TfmDialog_msg.pnlTituloMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if ssLeft in Shift then
  begin
    Self.Left:=Mouse.CursorPos.x - FMouseX;
    Self.Top:=Mouse.CursorPos.y - FMouseY;
  end;
end;

procedure TfmDialog_msg.BtnReposta_NaoClick(Sender: TObject);
begin
  Close;
  ModalResult:=mrClose;
end;

procedure TfmDialog_msg.BtnCopyToClipBoardClick(Sender: TObject);
begin
  try
    MyInfo.SelectAll;
    MyInfo.CopyToClipboard;
  finally
  end;
end;

procedure TfmDialog_msg.BtnSaveScreensClick(Sender: TObject);
var
  sDir:String;
begin
  // Salva todas as telas visiveis do programa
  // requer as units Graphics, LCLIntf, LCLType;
  sDir:=RootDir+pathDelim+'logs';
  sDir:=ReadIniString(_ini_pic_dir+'_snapshots', sDir);
  if SelectDirectory('Selecione uma pasta onde guardar a cópia das telas', sDir, sDir) then
  begin
    WriteIniString(_ini_pic_dir+'_snapshots', sDir);
    SaveScreenShots(sDir);
  end;
end;

procedure TfmDialog_msg.BtnReposta_SimClick(Sender: TObject);
begin
  Close;
  ModalResult:=mrYes;
end;

procedure TfmDialog_msg.Desfocar_Caption(Sender: TObject);
begin
  if (Sender is TSpeedButton) then
  begin
    TSpeedButton(Sender).Font.Style:=TPanel(Sender).Font.Style-[fsBold, fsUnderline];
    TSpeedButton(Sender).Font.Size:=12;
    TSpeedButton(Sender).Font.Color:=clWhite;
  end;
end;

procedure TfmDialog_msg.Focar_Caption(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if (Sender is TSpeedButton) then
  begin
    TSpeedButton(Sender).Font.Style:=TPanel(Sender).Font.Style+[fsBold, fsUnderline];
    TSpeedButton(Sender).Font.Size:=14;
    TSpeedButton(Sender).Font.Color:=clBlack;
  end;
end;

end.

