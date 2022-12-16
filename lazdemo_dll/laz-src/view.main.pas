unit view.main;
{
  This sample will be consume this functions in 'lazdemo_dll_server.dll':
  DLL_Proc, DLL_WhoAmI and DLL_Echo
  In this sample, DLL_Proc send and receive StringList content.
  I can use theses values to perform many values with an unique parameter.
  Be free to use this sample in your projects.
}

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  Buttons,
  StdCtrls,
  ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnEcho: TButton;
    btnMetodo: TBitBtn;
    btnWhoAmI: TBitBtn;
    Memo1: TMemo;
    pnlFuncoes: TPanel;
    procedure btnEchoClick(Sender: TObject);
    procedure btnWhoAmIClick(Sender: TObject);
    procedure btnMetodoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation
uses
  utils_dll;

{$R *.lfm}

{ TForm1 }


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

procedure TForm1.FormCreate(Sender: TObject);
begin
  Caption:='Lazarus DLL Sample - Consumer DLL made in Lazarus';
  memo1.clear;
end;

end.

