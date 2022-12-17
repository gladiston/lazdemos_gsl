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
    memo1.lines.Add('DLL_Echo Returning:'+sLineBreak+sResultado);
end;

procedure TForm1.btnWhoAmIClick(Sender: TObject);
var
  LSendParams:TStringList;
  sResultado:String;
  sMsg_Err:String;
begin
  LSendParams:=TStringList.Create;
  LSendparams.Values['param1']:='var1';
  LSendparams.Values['param2']:='var2';
  LSendparams.Values['param3']:='var3';
  sMsg_Err:=DLL_WhoAmI(
    'lazdemo_dll_server.dll',
    LSendparams.Text,
    sResultado);
  if sMsg_Err<>'' then
    memo1.lines.Add(sMsg_Err)
  else
    memo1.lines.Add('DLL_WhoAmI Returning:'+sLineBreak+sResultado);
  LSendparams.Free;
end;

procedure TForm1.btnMetodoClick(Sender: TObject);
var
  sResultado:String;
  sMsg_Err:String;
  LSendParams:TStringList;
begin
  LSendParams:=TStringList.Create;
  LSendParams.Values['HostName']:='localhost';
  LSendParams.Values['Database']:='banco.fdb';
  LSendParams.Values['Username']:='SYSDBA';
  LSendParams.Values['Password']:='masterkey';
  LSendParams.Values['Port']:='3050';

  sMsg_Err:=DLL_Proc(
    'lazdemo_dll_server.dll',
    LSendParams.Text,
    sResultado);
  if sMsg_Err<>'' then
    memo1.lines.Add(sMsg_Err)
  else
    memo1.lines.Add('DLL_Proc Returning:'+sLineBreak+sResultado);
  LSendParams.Free;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Caption:='Lazarus DLL Sample - Consumer DLL made in Lazarus';
  memo1.clear;
end;

end.

