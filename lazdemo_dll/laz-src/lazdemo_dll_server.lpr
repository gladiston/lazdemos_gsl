library lazdemo_dll_server;

{$mode objfpc}{$H+}

uses
  // Sharemem does not have to be used because we work with pchar values
  //Sharemem,
  Classes,
  Interfaces,
  lazdemo_dll_server_register;

exports
  DLL_Proc,
  DLL_WhoAmI,
  DLL_Echo,
  DLL_FreeProc;


begin
  ;
end.
