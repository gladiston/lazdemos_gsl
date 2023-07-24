library __ProjName__;

{$mode objfpc}{$H+}

uses
  Classes,
  SysUtils
  { you can add units after this };

function F_TestLogin(pParamList:pChar): pChar; stdcall;
var
  sLoginName, sLoginPassword, sRole, sConfigFile:String;
  ListaIN:TStringList;
  ListaOUT:TStringList;
  function FakeLogin(ALoginName, APassword, ARole:String):String;
  begin
    Result:=emptyStr;
  end;
begin
  ListaIN:=TStringLIST.Create;
  ListaOUT:=TStringLIST.Create;
  ListaOUT.Values['RESULT']:='FAIL';
  // garantindo que qualquer exit antes do tempo retorne FAIL
  Result:=pChar(ListaOUT.Text);
  try
    // A estrutura de minha string é compativel com TStrings então posso
    // importá-la como se fosse uma StringList
    ListaIN.Text:=String(pParamList);   // pChar para string
    sConfigFile:=Trim(ListaIN.Values['CONFIG_FILE']);
    sLoginName:=Trim(ListaIN.Values['User_Name']);
    sLoginPassword:=Trim(ListaIN.Values['Password']);
    sRole:=UPPERCASE(Trim(ListaIN.Values['Role']));
    // apenas um exemplo de teste de autenticação
    if FakeLogin(sLoginName, sLoginPassword, sRole)=emptyStr then
    begin
      // Prosseguindo...
	    ListaOUT.Values['RESULT']:='OK';
	    ListaOUT.Values['MSG_RESULT']:='OK';
    end
    else
    begin
      // Erro ao tentar conectar ao servidor
      ListaOUT.Values['RESULT']:='FAIL';
      ListaOUT.Values['MSG_RESULT']:='Autenticação falhou';
    end;
  except
  on e:exception do
     begin
	     ListaOUT.Values['RESULT']:='FAIL';
       ListaOUT.Values['MSG_RESULT']:=e.message;
	   end;
  end;
  ListaOUT.Values['User_Name']:=sLoginName;
  ListaOUT.Values['Password']:=sLoginPassword;
  ListaOUT.Values['Role']:=sRole;
  Result:=pChar(ListaOUT.Text);
  ListaIN.Free;
  ListaOUT.Free;
end;

exports
  F_TestLogin;

begin
end.

