unit view.principal;

{
  Este código intencionalmente funciona em Lazarus e Delphi, no entanto, se
  fosse para usar apenas o Lazarus, usaríamos a unit CustApp como
  exemplificado neste artigo:
  https://gladiston.net.br/lidando-com-parametros-de-entrada-em-seu-aplicativo/
  https://wiki.freepascal.org/Command_line_parameters_and_environment_variables

  // Para este exemplo funcionar direito vá em
  // Project|Project Options|Compiler Options|Config and Target|Win32 gui aplication (-WG)
  // que normalmente esta ligada e desmarque-a, caso contrário,
  // as mensagens serão mostradas num ShowMessage.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs;

type

  { TForm1 }

  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation
uses StrUtils;

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  ErrorMsg:String;
  sParam:String;
  iParamCount:Cardinal;
  bHasImport:Boolean;
  bHasExport:Boolean;
  i:Integer;
begin
  // você não verá as mensagens na console usando o Windows porque
  // há uma opção em Project|Project Options|
  // Compiler Options|Config and Target|Win32 gui aplication (-WG)
  // que fica ligada, assim ao inves de mostrar no terminal
  // as mensagens ele a mostrará num ShowMessage. Deixe-a desligada
  // se quiser ver as mensagens diretamente no terminal
  iParamCount:=ParamCount;
  bHasImport:=false;
  bHasExport:=false;
  ErrorMsg:=emptyStr;
  if iParamCount=0 then
  begin
    ErrorMsg:='Não há parâmetros';
  end
  else
  begin
    // nosso exemplo dois parâmetros serão obrigatórios import=xxxx, export=yyyy
    for i:=1 to iParamCount do
    begin
      sParam:=ParamStr(i);
      if ContainsText(sParam, 'import=') then
        bHasImport:=true;
      if ContainsText(sParam, 'export=') then
        bHasExport:=true;
    end;
    if (ErrorMsg=emptyStr) and (not bHasImport) then
      ErrorMsg:='Falta o parametro import=(...)';
    if (ErrorMsg=emptyStr) and (not bHasExport) then
      ErrorMsg:='Falta o parametro export=(...)';
  end;
  if ErrorMsg<>emptyStr then
  begin
    writeln(stderr, ErrorMsg);
    Sleep(5000); // 5s de espera
    Halt(2); // <-- Exit Code 2 para indicar a quem o chamou que houve falha
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
var
  aList:TStringList;
  iParamCount:Cardinal;
  sParam:String;
  sImportFile:String;
  sExportFile:String;
  bHasVerbose:Boolean;
  ErrorMsg:String;
  i:Integer;
begin
  ErrorMsg:=emptyStr;
  sImportFile:=emptyStr;
  sExportFile:=emptyStr;
  aList:=TStringList.Create;
  aList.CaseSensitive:=false;
  iParamCount:=ParamCount;
  // incluindo todos os parâmetros numa stringlist,
  // verá como isso facilitará muito
  for i:=1 to iParamCount do
  begin
    sParam:=ParamStr(i);
    // não queremos duplicar parâmetros iguais
    if aList.IndexOF(sParam)<0 then
      aList.Add(sParam);
  end;
  // Quero verbosidade?
  bHasVerbose:=(aList.IndexOfName('verbose')>=0);
  // olhando se o parametro import=arquivo.log, ele deve
  // existir para prosseguir
  if (ErrorMsg=emptyStr) and (aList.IndexOfName('import')>=0) then
  begin
    sImportFile:=aList.Values['import'];
    if not FileExists(sImportFile) then
      ErrorMsg:='Arquivo para importar não existe: '+sImportFile
  end
  else
  begin
    ErrorMsg:='Cadê o parâmetro import=arquivo.log!';
  end;
  // olhando se o parâmetro export=arquivo.csv, ele não deve
  // existir para prosseguir
  if (ErrorMsg=emptyStr) then
  begin
    if(aList.IndexOfName('export')>=0) then
    begin
      sExportFile:=aList.Values['export'];
      if FileExists(sExportFile) then
        ErrorMsg:='Arquivo para exportar já existe: '+sExportFile
    end
    else
    begin
      ErrorMsg:='Cadê o parâmetro export=arquivo.csv!';
    end;
  end;

  if ErrorMsg<>emptyStr then
  begin
    writeln(stderr, ErrorMsg);
    Sleep(5000); // 5s de espera
    Halt(2); // <-- Exit Code 2 para indicar a quem o chamou que houve falha
  end
  else
  begin
    // processando o restante do programa...
    if bHasVerbose then
     writeln(StdOut, 'Importando '+sImportFile+' e exportando '+sExportFile+'...')
    else
     writeln(StdOut, 'Importando...');
  end;
  aList.Free;
end;

end.

