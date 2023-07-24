library lazdemo_dll_server;

{$mode objfpc}{$H+}

uses
  // Sharemem does not have to be used because we work with pchar values
  //Sharemem,
  Interfaces,
  Classes,
  SysUtils,
  Forms,
  Dialogs,
  lazdemo_dll_server_register;

exports
  DLL_Proc,
  DLL_WhoAmI,
  DLL_Echo,
  DLL_FreeProc;


begin
  // I need to uncomment line bellow to to use Application.MessageBox
  //Application.Initialize;
end.
