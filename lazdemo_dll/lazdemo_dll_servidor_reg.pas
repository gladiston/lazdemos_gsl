unit lazdemo_dll_servidor_reg;

{$mode ObjFPC}{$H+}

interface

uses
  Classes,
  SysUtils,
  Forms,
  Dialogs;

function DLL_Processar(pParamList:pChar): pChar; stdcall;

implementation
//uses

function DLL_Processar(pParamList:pChar): pChar; stdcall;
var
  sParamList: String;
  sResultado:String;
begin
  sResultado:='RESULTADO=FAIL'+sLineBreak+'TESTE=SIM'+sLineBreak;
  sResultado:=String(pParamList);   // pchar para string
  Application.MessageBox( pParamList,'DLL Recebeu nativamente:');
  // convertendo para String;
  sParamList:=pParamList;
  ShowMessage(sParamList);

  //Result:=Pchar(UnicodeString(sResultado)); // correto
  Result:=pParamList; // retornar a entrada apenas para ver se chegou certo
end;


end.

