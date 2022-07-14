unit __mainunit__;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  StdCtrls,
  Windows; // requerido para consumir DLL

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnConsumir: TButton;
    memoResultado: TMemo;
    procedure BtnConsumirClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.BtnConsumirClick(Sender: TObject);
type
  TF_TestLogin = function (pParamList:pChar): pChar; stdcall;
var
  F_TestLogin: TF_TestLogin;  // Uma variável para acessar a sub-rotina na DLL
  LibHandle: THandle; // um handle para a DLL
  pResultado:pChar;   // resultado da função é um pchar
  ListaIN:TStringList;   // lista de parametros de entrada
  ListaRecebe:TStringList;  // valores recebidos em forma de lista
  pListaIN:Pchar;        // lista de parametros de entrada em formato pChar
  ErrorMode: UINT;       // codigo de erro caso aconteça
  ErrorMsg:String;       // mensagem de erro que impeça de prosseguir
const
  DLL='C:\Projetos-fpc\laztemplates\dll_provedor\__ProjName__.dll';
  //DLL='C:\caminho\para\DLL_Teste.dll';
begin
  // variavel que indicará a ocorrência de algum erro
  ErrorMsg:=emptyStr;
  // variavel que conterá o retorno da função dentro da DLL
  pResultado:=pChar(emptyStr);
  // Minha lista que receberá o retorno
  ListaRecebe:=TStringList.Create;
  // Meu parametro de entrada
  ListaIN:=TStringList.Create;
  ListaIN.Values['User_Name']:='meulogin';
  ListaIN.Values['Password'] :='minhasenha';
  ListaIN.Values['Role']     :='RDB$ADMIN';
  // Caminho para a DLL
  if not FileExists(DLL)
    then ErrorMsg:='Arquivo não existe: '+DLL;
  if ErrorMsg=emptyStr then
  begin
    // Desliga OS error messages
    ErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
    // Pegar o handle identificador da biblioteca a ser usada
    try
      LibHandle := LoadLibrary(PChar(DLL));
    finally
      SetErrorMode(ErrorMode);
    end;
    if LibHandle  <= HINSTANCE_ERROR
      then ErrorMsg:='Erro ao carregar: '+DLL;
    if ErrorMsg=emptyStr then
    begin
      // Confere se o carregamento da DLL foi bem-sucedido
      if Win32Check(Bool(LibHandle)) then
      begin
        // Atribui o endereço da chamada da subrotina à variável F_TestLogin, mas
        // nesse ponto o FPC e Delphi tem jeitos diferentes:
        {$IFDEF FPC}
          Pointer(F_TestLogin) := GetProcAddress(LibHandle, 'F_TestLogin');
        {$ELSE}
          F_TestLogin := GetProcAddress(LibHandle, 'F_TestLogin');
        {$ENDIF}

        // Verifica se um endereço válido foi retornado
        if @F_TestLogin <> nil then
        begin
          pListaIN:=pChar(ListaIN.Text);
          pResultado := F_TestLogin(pListaIN);
          // como o resultado é pChar então tenho que converter para string
          ListaRecebe.Text:=String(pResultado);
        end;
      end;
    end;
  end;
  //
  // tudo pronto para usufruir do retorno
  //
  if ErrorMsg=emptyStr then
  begin
    memoResultado.Text:=ListaRecebe.Text;
    if SameText(ListaRecebe.Values['RESULT'],'OK') then
      memoResultado.Lines.Add('Legal que tudo tenha ocorrido bem.')
    else
      memoResultado.Lines.Add('Que chato, parece que o login falhou.');
  end
  else
  begin
    memoResultado.Lines.Add('Não pude chamar a DLL: '+ErrorMsg);
  end;

  // liberando memoria
  F_TestLogin := nil;
  while not FreeLibrary(LibHandle) do
    Sleep(5); // espera 5s para uma nova tentativa
  ListaIN.Free;
  ListaRecebe.Free;
end;

end.

