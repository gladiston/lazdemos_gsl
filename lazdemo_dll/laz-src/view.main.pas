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

  function DLL_Proc(
    ADLL_Filename:String;
    ADLL_Param1:String;
    out ADLL_ResultAsString:String):String;

  function DLL_WhoAmI(
    ADLL_Filename:String;
    ADLL_Param1:String;
    out ADLL_ResultAsString:String):String;

  function DLL_Echo(
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
  TDLL_Proc= function (pParamList:PChar): PChar; cdecl;
  TDLL_FreeProc= procedure (pParamList:pChar); cdecl;
var
  myDLL_Proc: TDLL_Proc;
  myDLL_FreeProc: TDLL_FreeProc;
  myLibHandle : TLibHandle;
  ADLL_Param1_AsPChar:PChar;
  ADLL_Result_AsPChar:PChar;
begin
  Result:=emptyStr;
  ADLL_ResultAsString:='';
  ADLL_Filename:=Trim(ADLL_Filename);
  ADLL_Param1_AsPChar:=PChar(ADLL_Param1);
  if not FileExists(ADLL_Filename) then
    Result:='File not found: '+ADLL_Filename;

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
          ADLL_Result_AsPChar := myDLL_Proc(ADLL_Param1_AsPChar);
          // retornando como string
          ADLL_ResultAsString:=String(ADLL_Result_AsPChar);
          // Liberando memória que esta na DLL, neste caso, passo o ponteiro
          //   a se eliminado com StrDispose(dentro da DLL). Se não fizer isso
          //   haverá vazamento de memória
          try
            Pointer(myDLL_FreeProc) := GetProcAddress(myLibHandle, 'DLL_FreeProc');
            if @myDLL_FreeProc <> nil then
            begin
              if ADLL_Result_AsPChar<>nil then
                 myDLL_FreeProc(ADLL_Result_AsPChar); // --> StrDispose(ADLL_Result_AsPChar);
            end;
          except
            on e:exception do Result:=e.message;
          end;
        end;

      except
        on e:exception do Result:=e.message;
      end;
    end;

    // liberar memoria
    myDLL_Proc := nil;
    if myLibHandle <> 0 then
      FreeLibrary(myLibHandle);
  end;
end;

function DLL_WhoAmI(
  ADLL_Filename:String;
  ADLL_Param1:String;
  out ADLL_ResultAsString:String):String;
type
  TDLL_WhoAmI= function (pParamList:PChar): PChar; cdecl;
  TDLL_FreeProc= procedure (pParamList:pChar); cdecl;
var
  myDLL_WhoAmI: TDLL_WhoAmI;
  myDLL_FreeProc: TDLL_FreeProc;
  myLibHandle : TLibHandle;
  ADLL_Param1_AsPChar:PChar;
  ADLL_Result_AsPChar:PChar;
begin
  Result:=emptyStr;
  ADLL_ResultAsString:='';
  ADLL_Filename:=Trim(ADLL_Filename);
  ADLL_Param1_AsPChar:=PChar(ADLL_Param1);
  if not FileExists(ADLL_Filename) then
    Result:='File not found: '+ADLL_Filename;

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
          ADLL_Result_AsPChar := myDLL_WhoAmI(ADLL_Param1_AsPChar);
          // retornando como string
          ADLL_ResultAsString:=String(ADLL_Result_AsPChar);
          // Liberando memória que esta na DLL, neste caso, passo o ponteiro
          //   a se eliminado com StrDispose(dentro da DLL). Se não fizer isso
          //   haverá vazamento de memória
          try
            Pointer(myDLL_FreeProc) := GetProcAddress(myLibHandle, 'DLL_FreeProc');
            if @myDLL_FreeProc <> nil then
            begin
              if ADLL_Result_AsPChar<>nil then
                myDLL_FreeProc(ADLL_Result_AsPChar); // --> StrDispose(ADLL_Result_AsPChar);
            end;
          except
            on e:exception do Result:=e.message;
          end;
        end;

      except
        on e:exception do Result:=e.message;
      end;
    end;

    // liberar memoria
    myDLL_WhoAmI := nil;
    if myLibHandle <> 0 then
      FreeLibrary(myLibHandle);
  end;
end;

function DLL_Echo(
  ADLL_Filename:String;
  ADLL_Param1:String;
  out ADLL_ResultAsString:String):String;
type
  TDLL_Echo= function (pParamList:PChar): PChar; cdecl;
  TDLL_FreeProc= procedure (pParamList:pChar); cdecl;
var
  myDLL_Echo: TDLL_Echo;
  myDLL_FreeProc: TDLL_FreeProc;
  myLibHandle : TLibHandle;
  ADLL_Param1_AsPChar:PChar;
  ADLL_Result_AsPChar:PChar;
begin
  Result:=emptyStr;
  ADLL_ResultAsString:=emptyStr;
  ADLL_Filename:=Trim(ADLL_Filename);
  ADLL_Param1_AsPChar:=PChar(ADLL_Param1);

  if not FileExists(ADLL_Filename) then
    Result:='File not found: '+ADLL_Filename;

  if Result=emptyStr then
  begin
    myLibHandle := LoadLibrary(PChar(ADLL_Filename));
    // Verifica se o carregamento da DLL foi bem-sucedido
    if myLibHandle <> 0 then
    begin
      // Atribui o endereço da chamada da sub-rotina à variável myDLL_Echo
      // 'myDLL_Echo' da DLL DLL_Servidor.dll
      try
        Pointer(myDLL_Echo) := GetProcAddress(myLibHandle, 'DLL_Echo');

        // Verifica se um endereço válido foi retornado
        if Assigned(myDLL_Echo) then
        begin
          ADLL_Result_AsPChar := myDLL_Echo(ADLL_Param1_AsPChar);
          // retornando como string
          ADLL_ResultAsString:=String(ADLL_Result_AsPChar);
          // Liberando memória que esta na DLL, neste caso, passo o ponteiro
          //   a se eliminado com StrDispose(dentro da DLL). Se não fizer isso
          //   haverá vazamento de memória
          try
            Pointer(myDLL_FreeProc) := GetProcAddress(myLibHandle, 'DLL_FreeProc');
            if @myDLL_FreeProc <> nil then
            begin
              if ADLL_Result_AsPChar<>nil then
                 myDLL_FreeProc(ADLL_Result_AsPChar); // --> StrDispose(ADLL_Result_AsPChar);
            end;
          except
            on e:exception do Result:=e.message;
          end;
        end;

      except
        on e:exception do Result:=e.message;
      end;
    end;

    // liberar memoria
    myDLL_echo := nil;
    if myLibHandle <> 0 then
      FreeLibrary(myLibHandle);
  end;
end;

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
  Caption:='Lazarus DLL Sample Server and Consumer';
  memo1.clear;
end;

end.
