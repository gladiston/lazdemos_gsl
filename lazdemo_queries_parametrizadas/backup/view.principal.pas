unit view.principal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, ZSqlUpdate, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ExtCtrls, Buttons, ActnList, DBGrids, Menus,
  DBCtrls, DB;

type

  { TForm1 }

  TForm1 = class(TForm)
    actDB_Criar: TAction;
    actDB_Conectar1: TAction;
    actDB_Desconectar1: TAction;
    actInsert_Prepare: TAction;
    actInsert_WPrepare: TAction;
    actDelete_ALL: TAction;
    actSearch: TAction;
    actTrans1_Rollback: TAction;
    actTrans1_Commit: TAction;
    actTrans1_Iniciar: TAction;
    ActionList1: TActionList;
    autocommit1: TCheckBox;
    cboxParamCheck: TCheckBox;
    ComboBox_Con1: TComboBox;
    DBGrid1: TDBGrid;
    DBGridCon1: TGroupBox;
    DS_ZQuery_Con1: TDataSource;
    gbConexao1: TPanel;
    GroupBox2: TGroupBox;
    MemoStatus: TMemo;
    sbDB_Conectar1: TSpeedButton;
    sbDB_Criar: TSpeedButton;
    sbDB_TransacaoCommit: TSpeedButton;
    sbDB_TransacaoIniciar: TSpeedButton;
    sbDB_TransacaoRollBack: TSpeedButton;
    sbMenu1: TScrollBox;
    sb_search: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton3: TSpeedButton;
    Splitter1: TSplitter;
    ZConnection1: TZConnection;
    ZQuery_Con1: TZQuery;
    procedure actDB_Conectar1Execute(Sender: TObject);
    procedure actDB_CriarExecute(Sender: TObject);
    procedure actDB_Desconectar1Execute(Sender: TObject);
    procedure actDelete_ALLExecute(Sender: TObject);
    procedure actInsert_PrepareExecute(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
    procedure actTrans1_CommitExecute(Sender: TObject);
    procedure actTrans1_IniciarExecute(Sender: TObject);
    procedure actTrans1_RollbackExecute(Sender: TObject);
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
    procedure CheckButtons;
    procedure OpenMyData(AForUpdate, AWithLock:Boolean);
    function Insert_Data(
      ATotal: Cardinal;
      APrepare: Boolean;
      out AMilToPrepare:Integer;
      out AMilToComplete:Integer): String;
    function SQL_TableExists(ATableName: String; out AExist: Boolean): String;
    function Truncate_Table: String;
  public
  published
    property FDB_FileEx:String read FFDB_FileEx;
    property MsgStatus:String read FMsgStatus write SetMsgStatus;
  end;
const
  FDB_FILE='lazdemos_gsl.fdb';
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
  Form1: TForm1;


implementation
uses
  ZDbcIntfs,
  ZCompatibility,
  DateUtils;
{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  Caption:='Teste de conexão e TIL';
  FFDB_FileEx:='..'+PathDelim+'db'+PathDelim+FDB_FILE;
  // algumas opções devem estar desligadas no inicio
  MemoStatus.Clear;
  CheckButtons;
  ComboBox_Con1.Clear;
  ComboBox_Con1.Items.Add(TIL_READ_COMMITED);
  ComboBox_Con1.Items.Add(TIL_READ_UNCOMMITED);
  ComboBox_Con1.Items.Add(TIL_REPEATABLE_READ);
  ComboBox_Con1.Items.Add(TIL_SERIALIZABLE);
  ComboBox_Con1.ItemIndex:=0;
  DBGridCon1.Visible:=false;
end;

procedure TForm1.Sublinhado_Desligar(Sender: TObject);
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

procedure TForm1.Sublinhado_Ligar(Sender: TObject; Shift: TShiftState; X,
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

procedure TForm1.actDB_CriarExecute(Sender: TObject);
var
  L:TStringList;
  ErrorMsg:String;
begin
  // O codigo abaixo esta criando o banco de dados, porém o tamanho de página
  // que deveria ser 16384 esta sendo criado com 8192 e o collation UTF8 que
  // deveria ser UNICODE_CI_AI está sem nenhum collation. Estes foram bugs
  // reportados que aguardo estarem resolvidos na próxima revisão.
  ErrorMsg:=emptyStr;
  L:=TStringList.Create;
  if FileExists(FFDB_FileEx) then
  begin
    MsgStatus:='Banco "'+FFDB_FileEx+'" ja existe!';
  end
  else
  begin
    try
      if ZConnection1.Connected then
        ZConnection1.Disconnect;
      zConnection1.AutoCommit:=false;
      //zConnection1.AutoEncodeStrings:=false; // ela é inoqua
      zConnection1.Catalog:=''; // voce usa postgre?
      zConnection1.Protocol:='firebird';
      zConnection1.ClientCodePage:=FDB_CHARSET; //'ISO8859_1';
      // A constante cCP_UTF8 precisa da unit ZCompatibility no uses
      // as constantes cCP_UTF16 e cGET_ACP não são usados no Lazarus.
      zConnection1.ControlsCodePage:=cCP_UTF8;
      zConnection1.Database:=FFDB_FileEx;
      zConnection1.Hostname:='';
      zConnection1.LibraryLocation:='';    // fbclient.dll(win32) ou libfbclient.so(linux)
      zConnection1.LoginPrompt:=false;
      zConnection1.User:=FDB_USERNAME;
      zConnection1.Password:=FDB_PASSWORD;
      //zConnection1.Port:=3050;
      // As constantes dentro de TransactIsolationLevel
      // estão dentro da unit ZDbcIntfs
      zConnection1.TransactIsolationLevel := tiReadCommitted;
      // propriedades de read commited para o FirebirdSQL irão mudar o isolamento
      // mesmo com TransactIsolationLevel=tiReadCommitted
      zConnection1.ReadOnly:=false;
      zConnection1.SQLHourGlass:=true;
      zConnection1.UseMetadata:=true;
      zConnection1.Properties.Clear;
      ZConnection1.Properties.Values['dialect']:='3';
      ZConnection1.Properties.Values['CreateNewDatabase'] :=
        'CREATE DATABASE ' + QuotedStr(FFDB_FileEx) +
        ' USER ' + QuotedStr(FDB_USERNAME) +
        ' PASSWORD ' + QuotedStr(FDB_PASSWORD) +
        ' PAGE_SIZE ' + intToStr(FDB_PAGESIZE) +
        ' DEFAULT CHARACTER SET '+QuotedStr(FDB_CHARSET)+
        ' COLLATION '+QuotedStr(FDB_COLLATION) +';'+sLineBreak;
      ZConnection1.Connect;
      MsgStatus:='banco criado!';
    except
    on e:exception do ErrorMsg:=e.Message;
    end;
  end;


  if ErrorMsg=emptyStr then
    actDB_Conectar1Execute(Sender)
  else
    MsgStatus:=ErrorMsg;

  FreeAndNil(L);
end;

procedure TForm1.actDB_Desconectar1Execute(Sender: TObject);
begin
  try
    if zConnection1.Connected then
      zConnection1.Disconnect;
    sbDB_Conectar1.Action:=actDB_Conectar1;
  except
  on e:exception do MsgStatus:=zConnection1.Name+': '+e.message;
  end;
  CheckButtons;
end;

procedure TForm1.actDelete_ALLExecute(Sender: TObject);
var
  ErrorMsg:String;
begin
  ErrorMsg:=Truncate_Table;
  if ErrorMsg=emptyStr then
    OpenMyData(false, false)
  else
    MsgStatus:=ErrorMsg;
end;

procedure TForm1.actInsert_PrepareExecute(Sender: TObject);
var
  ErrorMsg:String;
  iTotal:Integer;
  S:String;
  iMilToPrepare:Integer;
  iMilToComplete:Integer;
  bPrepare:Boolean;
begin
  // inserir x registros com prepare
  ErrorMsg:=emptyStr;
  bPrepare:=false;
  iTotal:=10000;
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
      OpenMyData(false, false);
      DBGrid1.DataSource.DataSet.Last;
    end;
  end;

  if ErrorMsg<>emptyStr then
    MsgStatus:=ErrorMsg;
end;

procedure TForm1.actSearchExecute(Sender: TObject);
begin
  OpenMyData(false, false);
end;

procedure TForm1.actTrans1_CommitExecute(Sender: TObject);
begin
  if ZConnection1.Connected then
  begin
    try
      ZConnection1.Commit;
      sbDB_TransacaoIniciar.Font.Style:=Font.Style-[fsBold];
      ZQuery_Con1.Refresh;
    except
    on e:exception do MsgStatus:=zConnection1.Name+': '+e.message;
    end;
  end;
  CheckButtons;
end;

procedure TForm1.actTrans1_IniciarExecute(Sender: TObject);
begin
  if ZConnection1.Connected then
  begin
    if not ZConnection1.InTransaction then
    begin
      try
        ZConnection1.StartTransaction;
        sbDB_TransacaoIniciar.Font.Style:=Font.Style+[fsBold];
      except
      on e:exception do MsgStatus:=zConnection1.Name+': '+e.message;
      end;
    end;
  end;
  CheckButtons;
  if ZConnection1.Connected then
  begin
    if not autocommit1.checked then
      actTrans1_Iniciar.Enabled:=false;
  end;

end;

procedure TForm1.actTrans1_RollbackExecute(Sender: TObject);
begin
  if ZConnection1.Connected then
  begin
    try
      ZConnection1.Rollback;
      sbDB_TransacaoIniciar.Font.Style:=Font.Style-[fsBold];
      ZQuery_Con1.Refresh;
    except
    on e:exception do MsgStatus:=zConnection1.Name+': '+e.message;
    end;
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=true;
  actDB_Desconectar1Execute(Sender);

end;

procedure TForm1.actDB_Conectar1Execute(Sender: TObject);
var
  bIsDirect:Boolean;
  bTableExists:Boolean;
  ErrorMsg:String;
  L:TStringList;
begin
  ErrorMsg:=emptyStr;
  bIsDirect:=true;
  bTableExists:=true;
  L:=TStringList.Create;
  if ErrorMsg=emptyStr then
  begin
    case QuestionDlg(
      'Conexão embarcada?',
      'Conexão embarcada é monousuario e mais rapida, '+
      'Conexão cliente/servidor precisará de um alias '+FDB_FILE+'='+FFDB_FileEx+
      ' no arquivo databases.conf e a a senha de '+FDB_USERNAME+
      ' deve ser "'+FDB_PASSWORD+'". Qual sua opção:',
      mtInformation, [mrNo, 'Nao, cliente/servidor', mrYes, 'Sim, embarcada', 'IsDefault'], '') of
        mrYes: bIsDirect:=true;
        mrNo: bIsDirect:=false;
      else
        ErrorMsg:='Operação canelada pelo usuário.';
    end;
  end;
  if ErrorMsg=emptyStr then
  begin
    try
      if ZConnection1.Connected then
        ZConnection1.Disconnect;

      ZConnection1.AutoCommit:=(autocommit1.Checked);
      //ZConnection1.AutoEncodeStrings:=false; // ela é inoqua
      ZConnection1.Catalog:=''; // voce usa postgre?
      ZConnection1.Protocol:='firebird';
      ZConnection1.ClientCodePage:=FDB_CHARSET; //'ISO8859_1';
      // A constante cCP_UTF8 precisa da unit ZCompatibility no uses
      // as constantes cCP_UTF16 e cGET_ACP não são usados no Lazarus.
      ZConnection1.ControlsCodePage:=cCP_UTF8;
      if bIsDirect then
      begin
        ZConnection1.Hostname:='';
        ZConnection1.Port:=0;
        ZConnection1.Database:=FFDB_FileEx;
      end
      else
      begin
        ZConnection1.Hostname:='localhost';
        ZConnection1.Port:=3050;
        ZConnection1.Database:=FDB_FILE;
      end;
      zConnection1.LibraryLocation:='';    // fbclient.dll(win32) ou libfbclient.so(linux)
      ZConnection1.LoginPrompt:=false;
      ZConnection1.User:=FDB_USERNAME;
      ZConnection1.Password:=FDB_PASSWORD;
      //ZConnection1.Port:=3050;
      // As constantes dentro de TransactIsolationLevel
      // estão dentro da unit ZDbcIntfs
      if SameText(ComboBox_Con1.Text, TIL_READ_COMMITED) then
        ZConnection1.TransactIsolationLevel:=tiReadCommitted;
      if SameText(ComboBox_Con1.Text, TIL_READ_UNCOMMITED) then
        ZConnection1.TransactIsolationLevel:=tiReadUnCommitted;
      if SameText(ComboBox_Con1.Text, TIL_REPEATABLE_READ) then
        ZConnection1.TransactIsolationLevel:=tiRepeatableRead;
      if SameText(ComboBox_Con1.Text, TIL_SERIALIZABLE) then
        ZConnection1.TransactIsolationLevel:=tiSerializable;
      ZConnection1.Properties.Clear;
      ZConnection1.ReadOnly:=false;
      ZConnection1.SQLHourGlass:=true;
      ZConnection1.UseMetadata:=true;
      ZConnection1.Connected:=true;
    except
    on e:exception do ErrorMsg:=zConnection1.Name+': '+e.message;
    end;
  end;

  if (ErrorMsg=emptyStr) and (ZConnection1.Connected) then
  begin
    // Check existence and dont recreate table
    ErrorMsg:=SQL_TableExists('FRUTAS', bTableExists);
  end;

  if (ErrorMsg=emptyStr) and (ZConnection1.Connected) and (not bTableExists) then
  begin
    // todo: test existence of table and not recreate
    try
      L.Clear;
      L.Add('CREATE TABLE TEST_PREPARE(');
      L.Add('     codigo integer primary key,');     // sem pk a inserção é mais rapida
      L.Add('     descricao varchar(30));');
      if not ZConnection1.InTransaction then
        ZConnection1.StartTransaction;
      ZConnection1.ExecuteDirect(L.Text);
      ZConnection1.Commit;
      MsgStatus:='Tabela criada!';
    except
    on e:exception do
       begin
         ErrorMsg:=e.Message;
         ZConnection1.Rollback;
       end;
    end;
  end;

  if (ErrorMsg=emptyStr) then
  begin
    if (ZConnection1.Connected) then
      actSearchExecute(nil);
  end
  else
  begin
     MsgStatus:=ErrorMsg;
  end;

  L.Free;
end;

procedure TForm1.Transacao_Iniciada(Sender: TObject);
begin
  // quando uma transação é iniciada então ligo a opção de commit e rollback
  CheckButtons;
  MsgStatus:=TZConnection(Sender).Name+': Transação iniciada';
end;

procedure TForm1.Transacao_RollBack(Sender: TObject);
begin
  CheckButtons;
  MsgStatus:=TZConnection(Sender).Name+': RollBack';
end;

procedure TForm1.Conexao_Ligada(Sender: TObject);
var
  S:String;
begin
  MsgStatus:=TZConnection(Sender).Name+': conectado';
  CheckButtons;

end;

procedure TForm1.Conexao_Desligada(Sender: TObject);
begin
  CheckButtons;
  MsgStatus:=TZConnection(Sender).Name+': desconectado';
end;

procedure TForm1.Conexao_Refeita(Sender: TObject);
begin
  CheckButtons;
  MsgStatus:=TZConnection(Sender).Name+': reconectado';
end;

procedure TForm1.ZConnection1Commit(Sender: TObject);
begin
  CheckButtons;
  MsgStatus:='Transação '+TZConnection(Sender).Name+': Commit';
end;

procedure TForm1.ZQuery_Con1AfterOpen(DataSet: TDataSet);
begin
  DBGridCon1.Visible:=ZQuery_Con1.Active;
end;

procedure TForm1.SetMsgStatus(AValue: String);
begin
  if FMsgStatus=AValue then Exit;
  FMsgStatus:=AValue;
  MemoStatus.Lines.Add(FMsgStatus);
  //MemoStatus.SelStart:=Length(MemoStatus.Lines.Text);
  MemoStatus.VertScrollBar.Position:=Pred(MemoStatus.Lines.Count);
end;

procedure TForm1.CheckButtons;
begin
  if (ZConnection1.Connected) then
    actDB_Criar.Visible:=false
  else
    actDB_Criar.Visible:=true;

  if FileExists(FFDB_FileEx) then
    actDB_Criar.Visible:=false;

  actTrans1_Iniciar.Enabled:=false;
  actTrans1_Commit.Enabled:=false;
  actTrans1_Rollback.Enabled:=false;

  if (ZConnection1.Connected) then
  begin
    actTrans1_Iniciar.Enabled:=true;
    if autocommit1.checked then
      actTrans1_Iniciar.Enabled:=(not ZConnection1.InTransaction);
  end;
  if (ZConnection1.Connected) then
    actTrans1_Commit.Enabled:=(ZConnection1.InTransaction);
  if (ZConnection1.Connected) then
    actTrans1_Rollback.Enabled:=(ZConnection1.InTransaction);
  ComboBox_Con1.Enabled:= (not ZConnection1.Connected);
  autocommit1.Enabled:= (not ZConnection1.Connected);

  actInsert_Prepare.Enabled:= (ZConnection1.Connected);
  actInsert_WPrepare.Enabled:= (ZConnection1.Connected);
  actSearch.Enabled:= (ZConnection1.Connected);
  cboxParamCheck.Enabled:= (ZConnection1.Connected);

  actDelete_ALL.Enabled:= (ZConnection1.Connected);

  if ZConnection1.Connected then
    sbDB_Conectar1.Action:=actDB_Desconectar1
  else
    sbDB_Conectar1.Action:=actDB_Conectar1;

end;

procedure TForm1.OpenMyData(AForUpdate, AWithLock: Boolean);
var
  S:String;
begin
  S:=zConnection1.Name+': exibindo todos os registros';
  try
    if ZQuery_Con1.Active then
      ZQuery_Con1.Close;
    DS_ZQuery_Con1.AutoEdit:=false;
    ZQuery_Con1.Connection:=ZConnection1;
    ZQuery_Con1.SQL.Clear;
    ZQuery_Con1.SQL.Add('select * from TEST_PREPARE');
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
  on e:exception do MsgStatus:=zConnection1.Name+': '+e.message+sLineBreak+ZQuery_Con1.SQL.Text;
  end;

end;

function TForm1.Insert_Data(
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
  q1.Connection:=ZConnection1;

  // procura o ultimo
  q1.sql.Clear;
  q1.sql.add('SELECT MAX(codigo) as LAST_RECNO FROM TEST_PREPARE;');
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
        q1.sql.add('INSERT INTO TEST_PREPARE(codigo, descricao)');
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
        q1.sql.add('INSERT INTO TEST_PREPARE(codigo, descricao)');
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

function TForm1.Truncate_Table: String;
var
  q1:TZQuery;
begin
  Result:=emptyStr;
  q1:=TZQuery.Create(Self);
  q1.Connection:=ZConnection1;

  // find last one
  q1.sql.Clear;
  q1.sql.add('DELETE FROM TEST_PREPARE;');
  try
    q1.ExecSQL;
  except
  on e:exception do Result:=e.message;
  end;
  if q1.Active then
    q1.Close;
  q1.Free;
end;

function TForm1.SQL_TableExists(ATableName: String; out AExist:Boolean): String;
var
  q1:TZQuery;
begin
   Result:=emptyStr;
   AExist:=false;
   ATableName:=Trim(ATableName);
   if not zConnection1.Connected then
     Result:='Função SQL_TableExists: Banco de dados esta desconectado';

   q1:=TZQuery.Create(Self);
   if Result=emptyStr then
   begin
     try
       if q1.Active then
         q1.Close;
       q1.Connection:=ZConnection1;
       q1.SQL.Clear;
       q1.SQL.Add('select RDB$RELATION_NAME FROM RDB$RELATIONS');
       q1.SQL.Add('where (RDB$RELATION_NAME = '+QuotedStr(ATableName)+')');
       q1.Open;
       if not q1.IsEmpty then
         AExist:=true;
     except
     on e:exception do MsgStatus:=zConnection1.Name+': '+e.message+sLineBreak+q1.SQL.Text;
     end;

   end;
   q1.Free;
end;


end.

