unit view.main;

{
  This sample will be consume this functions in '[laz/dxe]demo_dll_server.dll':
  DLL_Proc, DLL_WhoAmI and DLL_Echo
  In this sample, DLL_Proc send and receive StringList content.
  I can use theses values to perform many values with an unique parameter.
  Be free to use this sample in your projects.
}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfmPrincipal = class(TForm)
    Panel1: TPanel;
    Memo1: TMemo;
    btnEcho: TButton;
    btnDLL_Proc: TButton;
    btnWhoAmI: TButton;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnDLL_ProcClick(Sender: TObject);
    procedure btnWhoAmIClick(Sender: TObject);
    procedure btnEchoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmPrincipal: TfmPrincipal;

const
  // lazdemo_dll_server or dxedemo_dll_server, testing both in cross consumer.exe
  //DLL_NAME='lazdemo_dll_server.dll';
  DLL_NAME='dxedemo_dll_server.dll';

implementation
uses
  utils_dll;

{$R *.dfm}

procedure TfmPrincipal.btnDLL_ProcClick(Sender: TObject);
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
    DLL_NAME,
    LSendParams.Text,
    sResultado);
  if sMsg_Err<>'' then
    memo1.lines.Add(sMsg_Err)
  else
    memo1.lines.Add('DLL_Proc Returning:'+sLineBreak+sResultado);
  LSendParams.Free;
end;

procedure TfmPrincipal.btnEchoClick(Sender: TObject);
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
    DLL_NAME,
    Memo1.Lines.Text,
    sResultado);
  if sMsg_Err<>'' then
    memo1.lines.Add(sMsg_Err)
  else
    memo1.lines.Add('DLL_Echo Returning:'+sLineBreak+sResultado);

end;

procedure TfmPrincipal.btnWhoAmIClick(Sender: TObject);
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
    DLL_NAME,
    LSendparams.Text,
    sResultado);
  if sMsg_Err<>'' then
    memo1.lines.Add(sMsg_Err)
  else
    memo1.lines.Add('DLL_WhoAmI Returning:'+sLineBreak+sResultado);
  LSendparams.Free;
end;

procedure TfmPrincipal.FormCreate(Sender: TObject);
begin
  Caption:='Delphi/Lazarus DLL Sample - Consumer DLL made in Delphi';
  memo1.clear;
end;

end.
