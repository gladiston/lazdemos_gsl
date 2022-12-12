unit view.principal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, ZSqlUpdate, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ExtCtrls, Buttons, ActnList, DBGrids, Menus,
  DBCtrls, DB;

type

  { TfmPrincipal }

  TfmPrincipal = class(TForm)
    actDB_Criar: TAction;
    actDB_Conectar: TAction;
    actDB_Desconectar: TAction;
    actInsert_Prepare: TAction;
    actDelete_ALL: TAction;
    actSearch: TAction;
    actTrans1_Rollback: TAction;
    actTrans1_Commit: TAction;
    actTrans1_Iniciar: TAction;
    ActionList1: TActionList;
    autocommit1: TCheckBox;
    cboxParamCheck: TCheckBox;
    ComboBox_Con1: TComboBox;
    DBGridCon1: TGroupBox;
    DS_ZQuery_Con1: TDataSource;
    gbConexao1: TPanel;
    GroupBox2: TGroupBox;
    MemoStatus: TMemo;
    numRegistros: TEdit;
    sbDB_Criar: TSpeedButton;
    sbMenu1: TScrollBox;
    sb_search: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton3: TSpeedButton;
    Splitter1: TSplitter;
    ZQuery_Con1: TZQuery;
    procedure actDB_CriarExecute(Sender: TObject);
    procedure actDB_DesconectarExecute(Sender: TObject);
    procedure actDelete_ALLExecute(Sender: TObject);
    procedure actInsert_PrepareExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure Sublinhado_Desligar(Sender: TObject);
    procedure Sublinhado_Ligar(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Transacao_Iniciada(Sender: TObject);
    procedure Transacao_RollBack(Sender: TObject);
    procedure Conexao_Ligada(Sender: TObject);
    procedure Conexao_Desligada(Sender: TObject);
    procedure Conexao_Refeita(Sender: TObject);
    procedure ZConnection1Commit(Sender: TObject);
    procedure ZQuery_Con1AfterOpen(DataSet: TDataSet);
  private
    FMsgStatus: String;
    FFDB_FileEx:String;
    procedure SetMsgStatus(AValue: String);
    procedure CheckButtons(AConn:TZConnection);
    procedure OpenMyData(AConn:TZConnection; AForUpdate, AWithLock:Boolean);
    function Insert_Data(
      AConn:TZConnection;
      ATotal: Cardinal;
      APrepare: Boolean;
      out AMilToPrepare:Integer;
      out AMilToComplete:Integer): String;
    function SQL_TableCount(AConn:TZConnection): Cardinal;
    function SQL_TableExists(AConn:TZConnection; ATableName: String; out AExist:Boolean): String;
    function Truncate_Table(AConn:TZConnection): String;
    function Create_DB(AConn: TZConnection):String;
    function Prepare_Conn(AConn:TZConnection; ADirect:Boolean=false):String;
  public
  published
    property FDB_FileEx:String read FFDB_FileEx;
    property MsgStatus:String read FMsgStatus write SetMsgStatus;
  end;
const
  FDB_FILE='lazdemos_gsl.fdb';
  FDB_TABLE='TEST_PREPARE';
  FDB_HOST='localhost';
  FDB_PORT=3050;
  FDB_USERNAME='SYSDBA';
  FDB_PASSWORD='masterkey';
  FDB_PAGESIZE=16384;
  FDB_CHARSET='UTF8';
  FDB_COLLATION='UNICODE_CI_AI';
  TIL_READ_COMMITED='READ COMMITED';
  TIL_READ_UNCOMMITED='READ UNCOMMITED';
  TIL_REPEATABLE_READ='REPEATABLE READ';
  TIL_SERIALIZABLE='SERIALIZABLE';


var
  fmPrincipal: TfmPrincipal;


implementation
uses
  ZDbcIntfs,
  ZCompatibility,
  DateUtils;
{$R *.lfm}

function TfmPrincipal.SQL_TableCount(AConn:TZConnection): Cardinal;
var
  q1:TZQuery;
begin
  Result:=0;
  if not AConn.Connected then
    Exit;
  q1:=TZQuery.Create(Self);
  try
    if q1.Active then
      q1.Close;
    q1.Connection:=AConn;
    q1.SQL.Clear;
    q1.SQL.Add('select count(*) as ncount from '+FDB_TABLE);
    q1.Open;
    if not q1.IsEmpty then
      Result:=q1.FieldbyName('ncount').AsInteger;
  except
  on e:exception do MsgStatus:=AConn.Name+': '+e.message+sLineBreak+q1.SQL.Text;
  end;
  q1.Free;
end;

{ TfmPrincipal }

procedure TfmPrincipal.FormCreate(Sender: TObject);
begin
  Caption:='Teste de conexão e TIL';
  FFDB_FileEx:='..'+PathDelim+'db'+PathDelim+FDB_FILE;
  // algumas opções devem estar desligadas no inicio
  MemoStatus.Clear;
  ComboBox_Con1.Clear;
  ComboBox_Con1.Items.Add(TIL_READ_COMMITED);
  ComboBox_Con1.Items.Add(TIL_READ_UNCOMMITED);
  ComboBox_Con1.Items.Add(TIL_REPEATABLE_READ);
  ComboBox_Con1.Items.Add(TIL_SERIALIZABLE);
  ComboBox_Con1.ItemIndex:=0;
  DBGridCon1.Visible:=false;
end;

procedure TfmPrincipal.Sublinhado_Desligar(Sender: TObject);
begin
  // ligar sublinhado
  if (Sender is TSpeedButton) then
  begin
    with (Sender as TSpeedButton) do
    begin
      Font.Style:=Font.Style-[fsBold, fsUnderline];
    end;
  end;
end;

procedure TfmPrincipal.Sublinhado_Ligar(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  // ligar sublinhado
  if (Sender is TSpeedButton) then
  begin
    with (Sender as TSpeedButton) do
    begin
      Font.Style:=Font.Style+[fsBold, fsUnderline];
    end;
  end;
end;

procedure TfmPrincipal.actDB_CriarExecute(Sender: TObject);
var
  ErrorMsg:String;
  ZConnection1:TZConnection;
begin
  // O codigo abaixo esta criando o banco de dados, porém o tamanho de página
  // que deveria ser 16384 esta sendo criado com 8192 e o collation UTF8 que
  // deveria ser UNICODE_CI_AI está sem nenhum collation. Estes foram bugs
  // reportados que aguardo estarem resolvidos na próxima revisão.
  ErrorMsg:=emptyStr;
  ZConnection1:=TZConnection.Create(Self);
  if FileExists(FFDB_FileEx) then
  begin
    MsgStatus:='Banco "'+FFDB_FileEx+'" ja existe!';
  end
  else
  begin
    // criar o banco
    ErrorMsg:=Create_DB(ZConnection1);
    if ErrorMsg=emptyStr then
    begin
      MsgStatus:='banco criado!';
    end;
  end;

  ErrorMsg:=Prepare_Conn(ZConnection1);
  CheckButtons(ZConnection1);

  if ErrorMsg<>emptyStr then
    MsgStatus:=ErrorMsg;

  ZConnection1.Free;
end;

procedure TfmPrincipal.actDB_DesconectarExecute(Sender: TObject);
var
  i:Integer;
  myConn:TZConnection;
begin
  for i:=Pred(ComponentCount) downto 0 do
  begin
    if Components[i] is TZConnection then
    begin
      myConn:=TZConnection(Components[i]);
      try
        if myConn.Connected then
          myConn.Disconnect;
        //sbDB_Conectar1.Action:=actDB_Conectar;

      except
      on e:exception do MsgStatus:=Name+': '+e.message;
      end;
    end;

  end;
end;

procedure TfmPrincipal.actDelete_ALLExecute(Sender: TObject);
var
  ErrorMsg:String;
  ZConnection1:TZConnection;
begin
  // O codigo abaixo esta criando o banco de dados, porém o tamanho de página
  // que deveria ser 16384 esta sendo criado com 8192 e o collation UTF8 que
  // deveria ser UNICODE_CI_AI está sem nenhum collation. Estes foram bugs
  // reportados que aguardo estarem resolvidos na próxima revisão.
  ErrorMsg:=emptyStr;
  ZConnection1:=TZConnection.Create(Self);

  ErrorMsg:=Truncate_Table(ZConnection1);
  if ErrorMsg=emptyStr then
    OpenMyData(ZConnection1, false, false)
  else
    MsgStatus:=ErrorMsg;

  ZConnection1.Free;
end;

procedure TfmPrincipal.actInsert_PrepareExecute(Sender: TObject);
var
  ErrorMsg:String;
  iTotal:Integer;
  S:String;
  iMilToPrepare:Integer;
  iMilToComplete:Integer;
  bPrepare:Boolean;
  ZConnection1:TZConnection;
begin
  // inserir x registros com prepare
  ErrorMsg:=emptyStr;
  ZConnection1:=TZConnection.Create(Self);
  ErrorMsg:=Prepare_Conn(ZConnection1);
  bPrepare:=false;
  iTotal:=StrToIntDef(numRegistros.Text,10000);
  if not cboxParamCheck.Checked then
    cboxParamCheck.Checked:=true;

  if ErrorMsg=emptyStr then
  begin
    S:=IntToStr(iTotal);
    if InputQuery(
      'Inserir quantos registros?',
      'Inserir quantos registros?', S) then
    begin
      if not TryStrToInt(S, iTotal) then
        ErrorMsg:='Quantidade invalida';
    end
    else
    begin
      ErrorMsg:='Operação canelada pelo usuário.';
    end;
  end;

  if ErrorMsg=emptyStr then
  begin
    case QuestionDlg(
      'Com preparação na execução?',
      'Preparação na execução agilizará queries repetitivas e parametrizadas. '+
      'Qual a sua opção:',
      mtInformation, [mrNo, 'Não, sem preparar', mrYes, 'Sim, preparar', 'IsDefault'], '') of
        mrYes: bPrepare:=true;
        mrNo: bPrepare:=false;
      else
        ErrorMsg:='Operação canelada pelo usuário.';
    end;
  end;

  if ErrorMsg=emptyStr then
  begin
    ErrorMsg:=Insert_Data(
      ZConnection1,
      iTotal, //ATotal: Cardinal;
      bPrepare, //APrepare: Boolean;
      iMilToPrepare, // out ATimeToPrepare:TDateTime;
      iMilToComplete); //out ATimeTotal:TDateTime);
    if ErrorMsg=emptyStr then
    begin
      S:='Performance: '+sLineBreak;
      S:=S+'  Preparação: '+IntToStr(iMilToPrepare)+' milisegundos'+sLineBreak;
      S:=S+'  Conclusão:  '+IntToStr(iMilToComplete)+' milisegundos'+sLineBreak;
      MsgStatus:=S;
      OpenMyData(ZConnection1, false, false);
    end;
  end;

  if ErrorMsg<>emptyStr then
    MsgStatus:=ErrorMsg;

  ZConnection1.Free;
end;

procedure TfmPrincipal.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=true;

end;

procedure TfmPrincipal.Transacao_Iniciada(Sender: TObject);
begin
  // quando uma transação é iniciada então ligo a opção de commit e rollback
  if Sender is TZConnection then
    CheckButtons(TZConnection(Sender));
  MsgStatus:=TZConnection(Sender).Name+': Transação iniciada';
end;

procedure TfmPrincipal.Transacao_RollBack(Sender: TObject);
begin
  if Sender is TZConnection then
    CheckButtons(TZConnection(Sender));
  MsgStatus:=TZConnection(Sender).Name+': RollBack';
end;

procedure TfmPrincipal.Conexao_Ligada(Sender: TObject);
begin
  MsgStatus:=TZConnection(Sender).Name+': conectado';
  if Sender is TZConnection then
    CheckButtons(TZConnection(Sender));

end;

procedure TfmPrincipal.Conexao_Desligada(Sender: TObject);
begin
  if Sender is TZConnection then
    CheckButtons(TZConnection(Sender));
  MsgStatus:=TZConnection(Sender).Name+': desconectado';
end;

procedure TfmPrincipal.Conexao_Refeita(Sender: TObject);
begin
  if Sender is TZConnection then
    CheckButtons(TZConnection(Sender));
  MsgStatus:=TZConnection(Sender).Name+': reconectado';
end;

procedure TfmPrincipal.ZConnection1Commit(Sender: TObject);
begin
  if Sender is TZConnection then
    CheckButtons(TZConnection(Sender));
  MsgStatus:='Transação '+TZConnection(Sender).Name+': Commit';
end;

procedure TfmPrincipal.ZQuery_Con1AfterOpen(DataSet: TDataSet);
begin
  DBGridCon1.Visible:=ZQuery_Con1.Active;
end;

procedure TfmPrincipal.SetMsgStatus(AValue: String);
begin
  if FMsgStatus=AValue then Exit;
  FMsgStatus:=AValue;
  MemoStatus.Lines.Add(FMsgStatus);
  //MemoStatus.SelStart:=Length(MemoStatus.Lines.Text);
  MemoStatus.VertScrollBar.Position:=Pred(MemoStatus.Lines.Count);
end;

procedure TfmPrincipal.CheckButtons(AConn:TZConnection);
begin
  if (AConn.Connected) then
    actDB_Criar.Visible:=false
  else
    actDB_Criar.Visible:=true;

  if FileExists(FFDB_FileEx) then
    actDB_Criar.Visible:=false;

  actTrans1_Iniciar.Enabled:=false;
  actTrans1_Commit.Enabled:=false;
  actTrans1_Rollback.Enabled:=false;

  if (AConn.Connected) then
  begin
    actTrans1_Iniciar.Enabled:=true;
    if autocommit1.checked then
      actTrans1_Iniciar.Enabled:=(not AConn.InTransaction);
  end;
  if (AConn.Connected) then
    actTrans1_Commit.Enabled:=(AConn.InTransaction);
  if (AConn.Connected) then
    actTrans1_Rollback.Enabled:=(AConn.InTransaction);
  ComboBox_Con1.Enabled:= (not AConn.Connected);
  autocommit1.Enabled:= (not AConn.Connected);

  actInsert_Prepare.Enabled:= (AConn.Connected);
  actSearch.Enabled:= (AConn.Connected);
  cboxParamCheck.Enabled:= (AConn.Connected);

  actDelete_ALL.Enabled:= (AConn.Connected);
end;

procedure TfmPrincipal.OpenMyData(AConn:TZConnection; AForUpdate, AWithLock: Boolean);
var
  S:String;
begin
  S:=AConn.Name+': exibindo todos os registros';
  try
    if ZQuery_Con1.Active then
      ZQuery_Con1.Close;
    DS_ZQuery_Con1.AutoEdit:=false;
    ZQuery_Con1.Connection:=AConn;
    ZQuery_Con1.SQL.Clear;
    ZQuery_Con1.SQL.Add('select * from '+FDB_TABLE);
    ZQuery_Con1.SQL.Add('where (true)');
    if AForUpdate then
    begin
      ZQuery_Con1.SQL.Add('  for update');
      S:=S+'(for update)';
    end;
    if AWithLock then
    begin
      ZQuery_Con1.SQL.Add('  with lock');
      S:=S+'(with lock)';
    end;
    ZQuery_Con1.Open;
    MsgStatus:=S;
  except
  on e:exception do MsgStatus:=AConn.Name+': '+e.message+sLineBreak+ZQuery_Con1.SQL.Text;
  end;

end;

function TfmPrincipal.Insert_Data(
  AConn:TZConnection;
  ATotal: Cardinal;
  APrepare: Boolean;
  out AMilToPrepare:Integer;
  out AMilToComplete:Integer): String;
var
  i:Cardinal;
  RECNO_START:Cardinal;
  iFinish:Cardinal;
  iCur_Time:TDateTime;
  iLoop:Integer;
  bCheckWhenPrepared:Boolean;
  q1:TZQuery;
begin
  Result:=emptyStr;
  AMilToPrepare:=0;
  AMilToComplete:=0;
  iCur_Time:=0;
  RECNO_START:=0;
  bCheckWhenPrepared:=(not APrepare);
  iLoop:=0;

  q1:=TZQuery.Create(Self);
  q1.Connection:=AConn;

  // procura o ultimo
  q1.sql.Clear;
  q1.sql.add('SELECT MAX(codigo) as LAST_RECNO FROM '+FDB_TABLE+';');
  try
    q1.Open;
    if not q1.IsEmpty then
      RECNO_START:=q1.fieldbyname('LAST_RECNO').AsInteger+1;
  except
  on e:exception do Result:=e.message;
  end;
  if q1.active then
    q1.close;
  q1.ParamCheck:=cboxParamCheck.Checked;
  iCur_Time:=now;
  if Result=emptyStr then
  begin
    try
      if q1.ParamCheck then
      begin
        q1.sql.Clear;
        q1.sql.add('INSERT INTO '+FDB_TABLE+'(codigo, descricao)');
        q1.sql.add('VALUES (:p_codigo, :p_descricao);');
        if APrepare then
        begin
          if not q1.Prepared then
          begin
            // notará que o Firebird também prepara automaticamente
            // caso esqueça de fazer isso, além disso, o prepare não é
            // exclusivo da sua conexão, query repetida reaproveitará
            // a preparação já executada antes
            q1.Prepare;
            MsgStatus:='Query Preparada!';
            AMilToPrepare:=MilliSecondsBetween(iCur_Time, now);
          end;
        end;
      end;
    except
    on e:exception do Result:=e.message;
    end;
  end;
  if Result=emptyStr then
  begin
    iCur_Time:=now;
    iLoop:=0;
    i:=RECNO_START;
    iFinish:=Pred(RECNO_START+ATotal);
    repeat
      Inc(iLoop);
      if (bCheckWhenPrepared) and (q1.Prepared) then
      begin
        MsgStatus:='Foi automaticamente preparada no loop# '+IntToStr(iLoop)+' pelo banco.';
        bCheckWhenPrepared:=false;
      end;
      if q1.ParamCheck then
      begin
        q1.ParambyName('p_codigo').Value:=i;
        q1.ParambyName('p_descricao').Value:='descricao #'+IntToStr(i);
      end
      else
      begin
        q1.sql.clear;
        q1.sql.add('INSERT INTO '+FDB_TABLE+'(codigo, descricao)');
        q1.sql.add('VALUES ('+IntToStr(i)+', '+QuotedStr('descricao #'+IntToStr(i))+');');
      end;
      try
        q1.ExecSQL;
      except
      on e:exception do Result:=e.message;
      end;
      Inc(i);
    until (Result<>emptyStr) or (i>iFinish);
    AMilToComplete:=MilliSecondsBetween(iCur_Time, now);
    // se não despreparar, o recurso ainda estará em uso no servidor
    // mas a liberação não é imediata, se houver uma execução e a mesma
    // ainda estiver na memória, o mesmo será reutilizado
    if q1.Prepared then
      q1.Unprepare;
  end;
  if q1.Active then
    q1.Close;
  q1.Free;
end;

function TfmPrincipal.Truncate_Table(AConn:TZConnection): String;
var
  q1:TZQuery;
begin
  Result:=emptyStr;
  q1:=TZQuery.Create(Self);
  q1.Connection:=AConn;

  // find last one
  q1.sql.Clear;
  q1.sql.add('DELETE FROM '+FDB_TABLE+';');
  try
    q1.ExecSQL;
  except
  on e:exception do Result:=e.message;
  end;
  if q1.Active then
    q1.Close;
  q1.Free;
end;

function TfmPrincipal.Create_DB(AConn: TZConnection):String;
begin
  Result:=emptyStr;
end;

function TfmPrincipal.Prepare_Conn(AConn: TZConnection; ADirect:Boolean=false):String;
var
  bTableExists:Boolean;
  L:TStringList;
begin
  bTableExists:=true;
  Result:=emptyStr;
  if Result=emptyStr then
  begin
    try
      if AConn.Connected then
        AConn.Disconnect;

      AConn.AutoCommit:=(autocommit1.Checked);
      //AConn.AutoEncodeStrings:=false; // ela é inoqua
      AConn.Catalog:=''; // voce usa postgre?
      AConn.Protocol:='firebird';
      AConn.ClientCodePage:=FDB_CHARSET; //'ISO8859_1';
      // A constante cCP_UTF8 precisa da unit ZCompatibility no uses
      // as constantes cCP_UTF16 e cGET_ACP não são usados no Lazarus.
      if ADirect then
      begin
        AConn.Hostname:='';
        AConn.Port:=0;
        AConn.Database:=FFDB_FileEx;
      end
      else
      begin
        AConn.Hostname:=FDB_HOST;
        AConn.Port:=FDB_PORT;
        AConn.Database:=FDB_FILE;
      end;
      AConn.LibraryLocation:='';    // fbclient.dll(win32) ou libfbclient.so(linux)
      AConn.LoginPrompt:=false;
      AConn.User:=FDB_USERNAME;
      AConn.Password:=FDB_PASSWORD;
      //AConn.Port:=FDB_PORT;
      // As constantes dentro de TransactIsolationLevel
      // estão dentro da unit ZDbcIntfs
      if SameText(ComboBox_Con1.Text, TIL_READ_COMMITED) then
        AConn.TransactIsolationLevel:=tiReadCommitted;
      if SameText(ComboBox_Con1.Text, TIL_READ_UNCOMMITED) then
        AConn.TransactIsolationLevel:=tiReadUnCommitted;
      if SameText(ComboBox_Con1.Text, TIL_REPEATABLE_READ) then
        AConn.TransactIsolationLevel:=tiRepeatableRead;
      if SameText(ComboBox_Con1.Text, TIL_SERIALIZABLE) then
        AConn.TransactIsolationLevel:=tiSerializable;
      AConn.Properties.Clear;
      AConn.Properties.Values['dialect']:='3';
      AConn.ReadOnly:=false;
      AConn.SQLHourGlass:=true;
      AConn.UseMetadata:=true;
      AConn.Connected:=true;
    except
    on e:exception do Result:=AConn.Name+': '+e.message;
    end;

    if Result=emptyStr then
    begin
      if (Result=emptyStr) and (AConn.Connected) then
      begin
        // Check existence and dont recreate table
        Result:=SQL_TableExists(AConn, FDB_TABLE, bTableExists);
      end;
    end;

    if (Result=emptyStr) and (AConn.Connected) and (not bTableExists) then
    begin
      // todo: test existence of table and not recreate
      L:=TStringList.Create;
      try
        L.Clear;
        L.Add('CREATE TABLE '+FDB_TABLE+'(');
        L.Add('     codigo integer primary key,');     // sem pk a inserção é mais rapida
        L.Add('     descricao varchar(30));');
        if not AConn.InTransaction then
          AConn.StartTransaction;
        AConn.ExecuteDirect(L.Text);
        AConn.Commit;
        MsgStatus:='Tabela criada!';
      except
      on e:exception do
         begin
           Result:=e.Message;
           AConn.Rollback;
         end;
      end;
      L.Free;
    end;

  end;
end;

function TfmPrincipal.SQL_TableExists(AConn:TZConnection; ATableName: String; out AExist:Boolean): String;
var
  q1:TZQuery;
begin
   Result:=emptyStr;
   AExist:=false;
   ATableName:=Trim(ATableName);
   if not AConn.Connected then
     Result:='Função SQL_TableExists: Banco de dados esta desconectado';

   q1:=TZQuery.Create(Self);
   if Result=emptyStr then
   begin
     try
       if q1.Active then
         q1.Close;
       q1.Connection:=AConn;
       q1.SQL.Clear;
       q1.SQL.Add('select RDB$RELATION_NAME FROM RDB$RELATIONS');
       q1.SQL.Add('where (RDB$RELATION_NAME = '+QuotedStr(ATableName)+')');
       q1.Open;
       if not q1.IsEmpty then
         AExist:=true;
     except
     on e:exception do MsgStatus:=AConn.Name+': '+e.message+sLineBreak+q1.SQL.Text;
     end;
   end;
   q1.Free;
end;


end.

