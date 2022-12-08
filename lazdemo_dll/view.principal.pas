unit view.principal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnConsumir: TButton;
    Memo1: TMemo;
    procedure btnConsumirClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

function CarregarDLL_ParamUnico(
  ADLL_Arquivo:String;
  ADLL_Param1:String;
  out AStrResultado:String):String;

implementation

{$R *.lfm}

{ TForm1 }

function CarregarDLL_ParamUnico(
  ADLL_Arquivo:String;
  ADLL_Param1:String;
  out AStrResultado:String):String;
type
  TDLL_Processar= function (pParamList:pChar): pChar; stdcall;
var
  DLL_Processar: TDLL_Processar;
  LibHandle : THandle;
  ADLL_Param1_AsPchar:pChar;
  ADLL_Result_AsPchar:pChar;
begin
  Result:=emptyStr;
  AStrResultado:='';
  ADLL_Arquivo:=Trim(ADLL_Arquivo);
  ADLL_Param1_AsPchar:=pChar(ADLL_Param1);
  if not FileExists(ADLL_Arquivo) then
    Result:='Arquivo não existe: '+ADLL_Arquivo;

  if Result=emptyStr then
  begin
    LibHandle := LoadLibrary(PChar(ADLL_Arquivo));
    // Verifica se o carregamento da DLL foi bem-sucedido
    if LibHandle <> 0 then
    begin
      // Atribui o endereço da chamada da sub-rotina à variável DLL_Processar
      // 'DLL_Processar' da DLL DLL_Servidor.dll
      try
        Pointer(DLL_Processar) := GetProcAddress(LibHandle, 'DLL_Processar');

        // Verifica se um endereço válido foi retornado
        if @DLL_Processar <> nil then
        begin
          ADLL_Result_AsPchar := DLL_Processar(ADLL_Param1_AsPchar);   // bug
          // retornando como string
          AStrResultado:=String(ADLL_Result_AsPchar);
        end;

      except
        on e:exception do Result:=e.message;
      end;
    end;

    // liberar memoria
    DLL_Processar := nil;
    FreeLibrary(LibHandle);
  end;
end;


procedure TForm1.btnConsumirClick(Sender: TObject);
var
  sResultado:String;
  sMsg_Err:String;
  L:TStringList;
begin
  L:=TStringList.Create;
  L.Values['Param1']:='parametro #1';
  L.Values['Param2']:='parametro #2';
  L.Values['Param3']:='parametro #3';
  L.Values['Param4']:='parametro #4';
  L.Values['Param5']:='parametro #5';
  memo1.clear;
  sMsg_Err:=CarregarDLL_ParamUnico(
    'lazdemo_dll_servidor.dll',
    L.Text,
    sResultado);
  if sMsg_Err<>'' then
    memo1.lines.Add(sMsg_Err)
  else
    memo1.lines.Add(sResultado);
  L.Free;

end;

end.

