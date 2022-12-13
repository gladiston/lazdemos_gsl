unit view.principal;

{$mode objfpc}{$H+}

interface

uses
  //ShareMem,
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, StdCtrls,
  ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnDebug: TButton;
    btnMetodo: TBitBtn;
    btnWhoAmI: TBitBtn;
    Memo1: TMemo;
    pnlFuncoes: TPanel;
    procedure btnDebugClick(Sender: TObject);
    procedure btnWhoAmIClick(Sender: TObject);
    procedure btnMetodoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

  function DLL_Proc(
    ADLL_Filename:String;
    ADLL_Param1:String;
    out ADLL_ResultAsString:String):String;

  function DLL_WhoAmI(
    ADLL_Filename:String;
    ADLL_Param1:String;
    out ADLL_ResultAsString:String):String;

  function DLL_Debug(
    ADLL_Filename:String;
    ADLL_Param1:String;
    out ADLL_ResultAsString:String):String;

implementation

{$R *.lfm}

function DLL_Proc(
  ADLL_Filename:String;
  ADLL_Param1:String;
  out ADLL_ResultAsString:String):String;
type
  TDLL_Proc= function (var pParamList:pChar): pChar; CdEcl;
var
  myDLL_Proc: TDLL_Proc;
  myLibHandle : THandle;
  ADLL_Param1_AsPchar:pChar;
  ADLL_Result_AsPchar:pChar;
begin
  Result:=emptyStr;
  ADLL_ResultAsString:='';
  ADLL_Filename:=Trim(ADLL_Filename);
  ADLL_Param1_AsPchar:=pChar(ADLL_Param1);
  if not FileExists(ADLL_Filename) then
    Result:='Arquivo não existe: '+ADLL_Filename;

  if Result=emptyStr then
  begin
    myLibHandle := LoadLibrary(PChar(ADLL_Filename));
    // Verifica se o carregamento da DLL foi bem-sucedido
    if myLibHandle <> 0 then
    begin
      // Atribui o endereço da chamada da sub-rotina à variável myDLL_Proc
      // 'myDLL_Proc' da DLL DLL_Servidor.dll
      try
        Pointer(myDLL_Proc) := GetProcAddress(myLibHandle, 'DLL_Proc');

        // Verifica se um endereço válido foi retornado
        if @myDLL_Proc <> nil then
        begin
          ADLL_Result_AsPchar := myDLL_Proc(ADLL_Param1_AsPchar);   // bug
          // retornando como string
          ADLL_ResultAsString:=String(ADLL_Result_AsPchar);
        end;

      except
        on e:exception do Result:=e.message;
      end;
    end;

    // liberar memoria
    myDLL_Proc := nil;
    if myLibHandle <> 0 then
      FreeLibrary(myLibHandle);  //always A/V
  end;
end;

function DLL_WhoAmI(
  ADLL_Filename:String;
  ADLL_Param1:String;
  out ADLL_ResultAsString:String):String;
type
  TDLL_WhoAmI= function (var pParamList:pChar): pChar; CdEcl;
var
  myDLL_WhoAmI: TDLL_WhoAmI;
  myLibHandle : THandle;
  ADLL_Param1_AsPchar:pChar;
  ADLL_Result_AsPchar:pChar;
begin
  Result:=emptyStr;
  ADLL_ResultAsString:='';
  ADLL_Filename:=Trim(ADLL_Filename);
  ADLL_Param1_AsPchar:=pChar(ADLL_Param1);
  if not FileExists(ADLL_Filename) then
    Result:='Arquivo não existe: '+ADLL_Filename;

  if Result=emptyStr then
  begin
    myLibHandle := LoadLibrary(PChar(ADLL_Filename));
    // Verifica se o carregamento da DLL foi bem-sucedido
    if myLibHandle <> 0 then
    begin
      // Atribui o endereço da chamada da sub-rotina à variável myDLL_WhoAmI
      // 'myDLL_WhoAmI' da DLL DLL_Servidor.dll
      try
        Pointer(myDLL_WhoAmI) := GetProcAddress(myLibHandle, 'DLL_WhoAmI');

        // Verifica se um endereço válido foi retornado
        if @myDLL_WhoAmI <> nil then
        begin
          ADLL_Result_AsPchar := myDLL_WhoAmI(ADLL_Param1_AsPchar);   // bug
          // retornando como string
          ADLL_ResultAsString:=String(ADLL_Result_AsPchar);
        end;

      except
        on e:exception do Result:=e.message;
      end;
    end;

    // liberar memoria
    myDLL_WhoAmI := nil;
    if myLibHandle <> 0 then
      FreeLibrary(myLibHandle);  //always A/V
  end;
end;

function DLL_Debug(
  ADLL_Filename:String;
  ADLL_Param1:String;
  out ADLL_ResultAsString:String):String;
type
  TDLL_Debug= function (var pParamList:pChar): pChar; CdEcl;
var
  myDLL_Debug: TDLL_Debug;
  myLibHandle : TLibHandle;
  ADLL_Param1_AsPchar:pChar;
  ADLL_Result_AsPchar:pChar;
begin
  Result:=emptyStr;
  ADLL_ResultAsString:=emptyStr;
  ADLL_Filename:=Trim(ADLL_Filename);
  ADLL_Param1_AsPchar:=pChar(ADLL_Param1);

  if not FileExists(ADLL_Filename) then
    Result:='Arquivo não existe: '+ADLL_Filename;

  if Result=emptyStr then
  begin
    myLibHandle := LoadLibrary(PChar(ADLL_Filename));
    // Verifica se o carregamento da DLL foi bem-sucedido
    if myLibHandle <> 0 then
    begin
      // Atribui o endereço da chamada da sub-rotina à variável myDLL_Debug
      // 'myDLL_Debug' da DLL DLL_Servidor.dll
      try
        Pointer(myDLL_Debug) := GetProcAddress(myLibHandle, 'DLL_Debug');

        // Verifica se um endereço válido foi retornado
        //if @myDLL_Debug <> nil then
        if Assigned(myDLL_Debug) then
        begin
          ADLL_Result_AsPchar := myDLL_Debug(ADLL_Param1_AsPchar);
          // retornando como string
          ADLL_ResultAsString:=String(ADLL_Result_AsPchar);

        end;

      except
        on e:exception do Result:=e.message;
      end;
    end;

    // liberar memoria
    myDLL_Debug := nil;
    if myLibHandle <> 0 then
      FreeLibrary(myLibHandle);  //always A/V
  end;
end;

{ TForm1 }


procedure TForm1.btnDebugClick(Sender: TObject);
var
  sResultado:String;
  sMsg_Err:String;
  L:TStringList;
begin
  L:=TStringList.Create;
  L.Values['CODREPRESENTANTE']:='ELIZABETH';
  L.Values['DT_FILTRO_VENCIMENTO']:='true';
  L.Values['DT_INICIAL']:='01/12/2022';
  L.Values['DT_FINAL']:='31/12/2022';
  L.Values['SOMENTE_COMISSOES_PENDENTES']:='true';
  L.Values['EXPORT_DIR']:='D:\DONWLOADS';
  L.Values['HostName']:='localhost';
  L.Values['Database']:='banco.fdb';
  L.Values['Username']:='SYSDBA';
  L.Values['Password']:='masterkey';
  L.Values['Port']:='3040';

  sMsg_Err:=DLL_Debug(
    'lazdemo_dll_servidor.dll',
    L.Text,
    sResultado);
  if sMsg_Err<>'' then
    memo1.lines.Add(sMsg_Err)
  else
    memo1.lines.Add(sResultado);
  L.Free;

end;

procedure TForm1.btnWhoAmIClick(Sender: TObject);
var
  sResultado:String;
  sMsg_Err:String;
  L:TStringList;
begin
  L:=TStringList.Create;
  L.Values['CODREPRESENTANTE']:='ELIZABETH';
  L.Values['DT_FILTRO_VENCIMENTO']:='true';
  L.Values['DT_INICIAL']:='01/12/2022';
  L.Values['DT_FINAL']:='31/12/2022';
  L.Values['SOMENTE_COMISSOES_PENDENTES']:='true';
  L.Values['EXPORT_DIR']:='D:\DONWLOADS';
  L.Values['HostName']:='localhost';
  L.Values['Database']:='banco.fdb';
  L.Values['Username']:='SYSDBA';
  L.Values['Password']:='masterkey';
  L.Values['Port']:='3040';
  memo1.clear;
  sMsg_Err:=DLL_WhoAmI(
    'lazdemo_dll_servidor.dll',
    L.Text,
    sResultado);
  if sMsg_Err<>'' then
    memo1.lines.Add(sMsg_Err)
  else
    memo1.lines.Add(sResultado);
  L.Free;

end;

procedure TForm1.btnMetodoClick(Sender: TObject);
var
  sResultado:String;
  sMsg_Err:String;
  L:TStringList;
begin
  L:=TStringList.Create;
  L.Values['CODREPRESENTANTE']:='ELIZABETH';
  L.Values['DT_FILTRO_VENCIMENTO']:='true';
  L.Values['DT_INICIAL']:='01/12/2022';
  L.Values['DT_FINAL']:='31/12/2022';
  L.Values['SOMENTE_COMISSOES_PENDENTES']:='true';
  L.Values['EXPORT_DIR']:='D:\DONWLOADS';
  L.Values['HostName']:='localhost';
  L.Values['Database']:='banco.fdb';
  L.Values['Username']:='SYSDBA';
  L.Values['Password']:='masterkey';
  L.Values['Port']:='3040';
  memo1.clear;
  sMsg_Err:=DLL_Proc(
    'lazdemo_dll_servidor.dll',
    L.Text,
    sResultado);
  if sMsg_Err<>'' then
    memo1.lines.Add(sMsg_Err)
  else
    memo1.lines.Add(sResultado);
  L.Free;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  memo1.clear;
end;

end.

