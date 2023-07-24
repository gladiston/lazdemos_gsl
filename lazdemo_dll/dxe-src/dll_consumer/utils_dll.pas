unit utils_dll;
{
Library dedicated to dynamically loading DLLs
}

interface
uses
  //Forms,
  //Controls,
  //Graphics,
  //Dialogs,
  //Buttons,
  //StdCtrls,
  //ExtCtrls,
  WinApi.Windows,
  Classes,
  SysUtils;

function DLL_Proc(
  ADLL_Filename:String;
  ADLL_Param1:WideString;
  out ADLL_ResultAsString:String):String;

function DLL_WhoAmI(
  ADLL_Filename:String;
  ADLL_Param1:WideString;
  out ADLL_ResultAsString:String):String;

function DLL_Echo(
  ADLL_Filename:String;
  ADLL_Param1:WideString;
  out ADLL_ResultAsString:String):String;

implementation


function DLL_Proc(
  ADLL_Filename:String;
  ADLL_Param1:WideString;
  out ADLL_ResultAsString:String):String;
type
  TDLL_Proc= function (pParamList:PWideChar): PWideChar; cdecl;
  TDLL_FreeProc= procedure (pParamList:PWideChar); cdecl;
var
  myDLL_Proc: TDLL_Proc;
  myDLL_FreeProc: TDLL_FreeProc;
  //myLibHandle : TLibHandle;    // Lazarus
  myLibHandle : HMODULE;         // Delphi
  ADLL_Param1_AsPWideChar:PWideChar;
  ADLL_Result_AsPWideChar:PWideChar;
begin
  Result:=emptyStr;
  ADLL_ResultAsString:='';
  ADLL_Filename:=Trim(ADLL_Filename);
  ADLL_Param1_AsPWideChar:=PWideChar(ADLL_Param1);
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
        //Pointer(myDLL_Proc) := GetProcAddress(myLibHandle, 'DLL_Proc');  // Lazarus way
        @myDLL_Proc := GetProcAddress(myLibHandle, 'DLL_Proc');            // Delphi way
        // Verifica se um endereço válido foi retornado
        if @myDLL_Proc <> nil then
        begin
          ADLL_Result_AsPWideChar := myDLL_Proc(ADLL_Param1_AsPWideChar);
          // retornando como string
          ADLL_ResultAsString:=String(ADLL_Result_AsPWideChar);
          // Liberando memória que esta na DLL, neste caso, passo o ponteiro
          //   a se eliminado com StrDispose(dentro da DLL). Se não fizer isso
          //   haverá vazamento de memória
          try
            //Pointer(myDLL_FreeProc) := GetProcAddress(myLibHandle, 'DLL_FreeProc');  // Lazarus way
            @myDLL_FreeProc := GetProcAddress(myLibHandle, 'DLL_FreeProc');            // Delphi way
            if @myDLL_FreeProc <> nil then
            begin
              if ADLL_Result_AsPWideChar<>nil then
                 myDLL_FreeProc(ADLL_Result_AsPWideChar); // --> StrDispose(ADLL_Result_AsPWideChar);
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
    myDLL_FreeProc := nil;

    if myLibHandle <> 0 then
      FreeLibrary(myLibHandle);
  end;
end;

function DLL_WhoAmI(
  ADLL_Filename:String;
  ADLL_Param1:WideString;
  out ADLL_ResultAsString:String):String;
type
  TDLL_WhoAmI= function (pParamList:PWideChar): PWideChar; cdecl;
  TDLL_FreeProc= procedure (pParamList:PWideChar); cdecl;
var
  myDLL_WhoAmI: TDLL_WhoAmI;
  myDLL_FreeProc: TDLL_FreeProc;
  //myLibHandle : TLibHandle;    // Lazarus
  myLibHandle : HMODULE;         // Delphi
  ADLL_Param1_AsPWideChar:PWideChar;
  ADLL_Result_AsPWideChar:PWideChar;
begin
  Result:=emptyStr;
  ADLL_ResultAsString:='';
  ADLL_Filename:=Trim(ADLL_Filename);
  ADLL_Param1_AsPWideChar:=PWideChar(ADLL_Param1);
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
        //Pointer(myDLL_WhoAmI) := GetProcAddress(myLibHandle, 'DLL_WhoAmI');  // Lazarus way
        @myDLL_WhoAmI := GetProcAddress(myLibHandle, 'DLL_WhoAmI');            // Delphi way
        // Verifica se um endereço válido foi retornado
        if @myDLL_WhoAmI <> nil then
        begin
          ADLL_Result_AsPWideChar := myDLL_WhoAmI(ADLL_Param1_AsPWideChar);
          // retornando como string
          ADLL_ResultAsString:=String(ADLL_Result_AsPWideChar);
          // Liberando memória que esta na DLL, neste caso, passo o ponteiro
          //   a se eliminado com StrDispose(dentro da DLL). Se não fizer isso
          //   haverá vazamento de memória
          try
            //Pointer(myDLL_FreeProc) := GetProcAddress(myLibHandle, 'DLL_FreeProc');  // Lazarus way
            @myDLL_FreeProc := GetProcAddress(myLibHandle, 'DLL_FreeProc');            // Delphi way
            if @myDLL_FreeProc <> nil then
            begin
              if ADLL_Result_AsPWideChar<>nil then
                myDLL_FreeProc(ADLL_Result_AsPWideChar); // --> StrDispose(ADLL_Result_AsPWideChar);
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
    myDLL_FreeProc := nil;
    if myLibHandle <> 0 then
      FreeLibrary(myLibHandle);
  end;
end;

function DLL_Echo(
  ADLL_Filename:String;
  ADLL_Param1:WideString;
  out ADLL_ResultAsString:String):String;
type
  TDLL_Echo= function (pParamList:PWideChar): PWideChar; cdecl;
  TDLL_FreeProc= procedure (pParamList:PWideChar); cdecl;
var
  myDLL_Echo: TDLL_Echo;
  myDLL_FreeProc: TDLL_FreeProc;
  //myLibHandle : TLibHandle;    // Lazarus
  myLibHandle : HMODULE;         // Delphi
  ADLL_Param1_AsPWideChar:PWideChar;
  ADLL_Result_AsPWideChar:PWideChar;
begin
  Result:=emptyStr;
  ADLL_ResultAsString:=emptyStr;
  ADLL_Filename:=Trim(ADLL_Filename);
  ADLL_Param1_AsPWideChar:=PWideChar(ADLL_Param1);

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
        //Pointer(myDLL_Echo) := GetProcAddress(myLibHandle, 'DLL_Echo');  // Lazarus way
        @myDLL_Echo := GetProcAddress(myLibHandle, 'DLL_Echo');            // Delphi way
        // Verifica se um endereço válido foi retornado
        if Assigned(myDLL_Echo) then
        begin
          ADLL_Result_AsPWideChar := myDLL_Echo(ADLL_Param1_AsPWideChar);
          // retornando como string
          ADLL_ResultAsString:=WideString(ADLL_Result_AsPWideChar);
          // Liberando memória que esta na DLL, neste caso, passo o ponteiro
          //   a se eliminado com StrDispose(dentro da DLL). Se não fizer isso
          //   haverá vazamento de memória
          try
            //Pointer(myDLL_FreeProc) := GetProcAddress(myLibHandle, 'DLL_FreeProc');  // Lazarus way
            @myDLL_FreeProc := GetProcAddress(myLibHandle, 'DLL_FreeProc');            // Delphi way
            if @myDLL_FreeProc <> nil then
            begin
              if ADLL_Result_AsPWideChar<>nil then
                 myDLL_FreeProc(ADLL_Result_AsPWideChar); // --> StrDispose(ADLL_Result_AsPWideChar);
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
    myDLL_FreeProc:=nil;

    if myLibHandle <> 0 then
      FreeLibrary(myLibHandle);
  end;
end;


end.
