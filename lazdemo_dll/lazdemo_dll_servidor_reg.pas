unit lazdemo_dll_servidor_reg;

{$mode ObjFPC}{$H+}

interface

uses
  Classes,
  SysUtils,
  Forms,
  Dialogs;

function DLL_Proc(var pParamList:pChar): pChar; CdEcl;
function DLL_WhoAmI(var pParamList:pChar): pChar; CdEcl;
function DLL_Debug(var pParamList:pChar): pChar; CdEcl;

implementation
//uses

function DLL_Proc(var pParamList:pChar): pChar; CdEcl;
var
  sParamList: String;
  sResultado:String;
begin
  //sResultado:='RESULTADO=FAIL'+sLineBreak+'TESTE=SIM'+sLineBreak;
  //sResultado:=String(pParamList);   // pchar para string
  //Application.MessageBox( pParamList,'DLL Recebeu nativamente:');
  // convertendo para String;
  //sParamList:=pParamList;
  //ShowMessage(sParamList);

  //Result:=Pchar(UnicodeString(sResultado)); // correto
  Result:=pParamList; // retornar a entrada apenas para ver se chegou certo
end;

function DLL_WhoAmI(var pParamList:pChar): pChar; CdEcl;
begin
  Result:=PChar(
    'descricao=Relatório de extrato de comissionados|'+sLineBreak+
    'categoria=financeiro|'+sLineBreak+
    'tags=comissão,comissões,comissao,comissoes|'+sLineBreak+
    'grupos=Financeiro|'+sLineBreak+
    'se_supervisor=N|'+sLineBreak+
    'parametros=DT_INICIAL(Data inicial);DT_FINAL(Data Final);COMISSIONADOS(Comissionados);|'+sLineBreak+
    'explicacao=Este relatório exibe comissionados e suas comissões deviudas. '+
      'Também é capaz de enviá-las por email ou imprimi-las.|'+sLineBreak+
    'tabelas=PROC_COMISSAO|'+sLineBreak+
    'last_update=2017-07-10 00:00|'+sLineBreak+
    'last_owner=Gladiston|'+sLineBreak);

end;

function DLL_Debug(var pParamList:pChar): pChar; CdEcl;
begin
  Result:=pParamList;
end;

end.

