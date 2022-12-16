unit view.main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    btnEcho: TBitBtn;
    btnMetodo: TBitBtn;
    btnWhoAmI: TBitBtn;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure btnMetodoClick(Sender: TObject);
    procedure btnWhoAmIClick(Sender: TObject);
    procedure btnEchoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
uses utils_dll;
{$R *.dfm}


{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  Caption:='Delphi DLL Sample Server and Consumer';
  memo1.Clear;
end;

procedure TForm1.btnEchoClick(Sender: TObject);
var
  sResultado:String;
  sMsg_Err:String;
begin
  if Memo1.Lines.Count=0 then
  begin
    // Exemplo (sample)
    Memo1.Lines.Values['HostName']:='localhost';
    Memo1.Lines.Values['Database']:='banco.fdb';
    Memo1.Lines.Values['Username']:='SYSDBA';
    Memo1.Lines.Values['Password']:='masterkey';
    Memo1.Lines.Values['Port']:='3050';
  end;

  sMsg_Err:=DLL_Echo(
    'lazdemo_dll_server.dll',
    Memo1.Lines.Text,
    sResultado);
  if sMsg_Err<>'' then
    memo1.lines.Add(sMsg_Err)
  else
    memo1.lines.Add('Returning:'+sLineBreak+sResultado);

end;

procedure TForm1.btnMetodoClick(Sender: TObject);
var
  sResultado:String;
  sMsg_Err:String;
  L:TStringList;
begin
  L:=TStringList.Create;
  L.Values['HostName']:='localhost';
  L.Values['Database']:='banco.fdb';
  L.Values['Username']:='SYSDBA';
  L.Values['Password']:='masterkey';
  L.Values['Port']:='3050';

  sMsg_Err:=DLL_Proc(
    'lazdemo_dll_server.dll',
    L.Text,
    sResultado);
  if sMsg_Err<>'' then
    memo1.lines.Add(sMsg_Err)
  else
    memo1.lines.Add('Returning:'+sLineBreak+sResultado);
  L.Free;
end;

procedure TForm1.btnWhoAmIClick(Sender: TObject);
var
  sResultado:String;
  sMsg_Err:String;
begin
  sMsg_Err:=DLL_WhoAmI(
    'lazdemo_dll_server.dll',
    '### Fim da função WhoAmI ###',
    sResultado);
  if sMsg_Err<>'' then
    memo1.lines.Add(sMsg_Err)
  else
    memo1.lines.Add('Returning:'+sLineBreak+sResultado);

end;

end.
