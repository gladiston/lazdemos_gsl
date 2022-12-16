unit utils_dll;
{
Biblioteca dedicada a carregar DLLs dinamicamente
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
  Classes,
  SysUtils;



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


end.
