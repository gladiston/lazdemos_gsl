unit lazdemo_dll_server_register;

{
  DLL sample to use in projects writen in freepascal or Delphi.
  The parameter can be stringList.Text where you can send many pair values
  and receive a long stringlist.text with  pair values. Example:
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
      Result:='Arquivo não existe: '+ADLL_Filename;

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
            //   haverá vazamento de memória (memory lake)
            try
              Pointer(myDLL_FreeProc) := GetProcAddress(myLibHandle, 'DLL_FreeProc');
              if @myDLL_FreeProc <> nil then
              begin
                //myDLL_FreeProc(@myDLL_Proc);
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
}

{$mode ObjFPC}{$H+}

interface

uses
  Interfaces,
  Rtti,
  Classes,
  SysUtils,
  Forms,
  Dialogs;

function DLL_Proc(pParamList:PWideChar): PWideChar; cdecl;
function DLL_WhoAmI(pParamList:PWideChar): PWideChar; cdecl;
function DLL_Echo(pParamList:pWideChar): pWideChar; cdecl;
procedure DLL_FreeProc(pParamList: PWideChar); cdecl;
procedure DLL_MsgBox(AText, ATitle:PChar);

implementation
//uses

function DLL_Proc(pParamList:PWideChar): PWideChar; cdecl;
var
  LResult:TStringList;
  LParamList:TStringList;
  S:UnicodeString;
begin
  S:=WideCharToString(pParamList);
  LParamList:=TStringList.Create;
  LParamList.DefaultEncoding:=TEncoding.ANSI;
  LParamList.Text:=AnsiString(S);

  LResult:=TStringList.Create;
  LResult.Text:=String(S);
  LResult.Values['Result']:='FAIL';

  DLL_MsgBox(pChar(LParamList.Text), pChar('DLL received the following data:'));

  //
  // do something...
  //


  // now we returning what I need from prior process
  LResult.Values['Result']:='OK';

  // The best way to transfer stringList.text to Result as pWideChar is byte per byte
  //   using WideStrAlloc and StrPCopy. WideStrAlloc requires call DLL_FreeProc(pParamList)
  //   in consumer side after returning. See header example.
  Result := WideStrAlloc(Length(LResult.Text)+1);
  StrPCopy(Result, LResult.Text);

  // Clean vars
  LParamList.Free;
  LResult.Free;
end;

function DLL_WhoAmI(pParamList:PWideChar): PWideChar; cdecl;
var
  LResult:TStringList;
  LParamList:TStringList;
  S:UnicodeString;
begin
  S:=WideCharToString(pParamList);
  LParamList:=TStringList.Create;
  LParamList.DefaultEncoding:=TEncoding.ANSI;
  //LParamList.Text:=S;
  LParamList.Text:=AnsiString(S);

  DLL_MsgBox(pChar(LParamList.Text), pChar('DLL_WhoAmI received the following data:'));

  LResult:=TStringList.Create;
  LResult.Values['title']:='Sales Report';
  LResult.Values['category']:='finance';
  LResult.Values['tags']:='sales, money, coin';
  LResult.Values['groups']:='finance';
  LResult.Values['se_supervisor']:='N';
  LResult.Values['explain']:='This report show sales per month';
  LResult.Values['last_update']:='2017-07-10 00:00';
  LResult.Values['last_owner']:='MyName';
  LResult.Values['Parameters received count:']:=IntToStr(LParamList.Count);
  LResult.AddStrings(LParamList);


  //DLL_MsgBox(LResult.Text, 'DLL_WhoAmI returning:');

  // The best way to transfer stringList.text to Result as pWideChar is byte per byte
  //   using WideStrAlloc and StrPCopy. WideStrAlloc requires call DLL_FreeProc(pParamList)
  //   in consumer side after returning. See header example.
  Result := WideStrAlloc(Length(LResult.Text)+1);
  StrPCopy(Result, LResult.Text);

  // Clean vars
  LParamList.Free;
  LResult.Free;
end;

function DLL_Echo(pParamList:PWideChar): PWideChar; cdecl;
var
  LResult:TStringList;
  LParamList:TStringList;
  S:UnicodeString;
begin
  S:=WideCharToString(pParamList);
  LParamList:=TStringList.Create;
  LParamList.DefaultEncoding:=TEncoding.ANSI;
  //LParamList.Text:=S;
  LParamList.Text:=AnsiString(S);
  //DLL_MsgBox(pChar(LParamList.Text), pChar('DLL_Echo received the following data:'));

  LResult:=TStringList.Create;
  LResult.DefaultEncoding:=TEncoding.ANSI;
  LResult.AddStrings(LParamList);
  //DLL_MsgBox(pChar(LParamList.Text), pChar('DLL_Echo LResult:'));

  // The best way to transfer stringList.text to Result as pWideChar is byte per byte
  //   using WideStrAlloc and StrPCopy. WideStrAlloc requires call DLL_FreeProc(pParamList)
  //   in consumer side after returning. See header example.
  Result := WideStrAlloc(Length(LResult.Text)+1);
  StrPCopy(Result, LResult.Text);

  // Clean vars
  LParamList.Free;
  LResult.Free;
end;

procedure DLL_FreeProc(pParamList: PWideChar); cdecl;
begin
  // When any function use StrAlloc, after consumes, we need to call
  //   DLL_FreeProc(pParamList) to deallocate memory used from this DLL
  StrDispose(pParamList);
end;

// DLL_MsgBox - Just for debug
procedure DLL_MsgBox(AText, ATitle: pChar);
begin
  //Application.MessageBox(AText, ATitle);
end;

end.

