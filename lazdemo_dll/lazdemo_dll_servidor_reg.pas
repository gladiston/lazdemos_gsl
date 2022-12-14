unit lazdemo_dll_servidor_reg;

{$mode ObjFPC}{$H+}

interface

uses
  Classes,
  SysUtils,
  Forms,
  Dialogs;

function DLL_Proc(pParamList:pChar): pChar; cdecl;
function DLL_WhoAmI(pParamList:pChar): pChar; cdecl;
function DLL_Echo(pParamList:pChar): pChar; cdecl;

implementation
//uses

function DLL_Proc(pParamList:pChar): pChar; cdecl;
var
  sParamList: String;
  LResult:TStringList;
begin
  LResult:=TStringList.Create;
  LResult.Values['HostName']:='localhost';
  LResult.Values['Database']:='banco.fdb';
  LResult.Values['Username']:='SYSDBA';
  LResult.Values['Password']:='masterkey';
  LResult.Values['Port']:='3050';
  // Bug:Esse jeito tá errado porque o Result ficará preso ao LResult
  //   funcionando como uma ancora entre esta DLL e o projeto que a consume.
  //   LResult "morre" quando dá o .Free e então o Result "morre" com ele
  //   então retornando algo inexperado na posição do ponteiro.
  //Result:=pChar(LResult.Text);

  // Possivel correção: O jeito mais adequado seria transferir byte a byte
  // para que nosso Result não funcione ancorado ao LResult
  Result := StrAlloc(Length(LResult.Text)+1);
  StrPCopy(Result, LResult.Text);
  //LResult.Free;
end;

function DLL_WhoAmI(pParamList:pChar): pChar; cdecl;
begin
  Result:=PChar(
    'descricao=Relatório de extrato de comissionados|'+sLineBreak+
    'categoria=financeiro|'+sLineBreak+
    'tags=comissão,comissões,comissao,comissoes|'+sLineBreak+
    'grupos=Financeiro|'+sLineBreak+
    'se_supervisor=N|'+sLineBreak+
    'parametros=DT_INICIAL(Data inicial);DT_FINAL(Data Final);COMISSIONADOS(Comissionados);|'+sLineBreak+
    'explicacao=Este relatório exibe comissionados e suas comissões devidas. '+
      'Também é capaz de enviá-las por email ou imprimi-las.|'+sLineBreak+
    'tabelas=PROC_COMISSAO|'+sLineBreak+
    'last_update=2017-07-10 00:00|'+sLineBreak+
    'last_owner=Gladiston|'+sLineBreak);

end;

function DLL_Echo(pParamList:pChar): pChar; cdecl;
begin
  Result:=pParamList;
  //Result := StrAlloc(Length(pParamList)+1);
  //StrPCopy(Result, pParamList);
end;

end.
