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
    btnAlterar: TBitBtn;
    btnAlterar1: TBitBtn;
    ComboBox_Con1: TComboBox;
    DBGrid1: TDBGrid;
    DBGridCon1: TGroupBox;
    DS_ZQuery_Con1: TDataSource;
    edtCodigo: TDBEdit;
    edtDescricao_Atual: TDBEdit;
    edtDescricao_Nova: TComboBox;
    gbConexao1: TPanel;
    gb_test: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MemoStatus: TMemo;
    pnlAceitar: TPanel;
    sbDB_Conectar1: TSpeedButton;
    sbDB_Criar: TSpeedButton;
    sbDB_TransacaoCommit: TSpeedButton;
    sbDB_TransacaoIniciar: TSpeedButton;
    sbDB_TransacaoRollBack: TSpeedButton;
    sbMenu1: TScrollBox;
    sb_search: TSpeedButton;
    SpeedButton3: TSpeedButton;
    Splitter1: TSplitter;
    ZConnection1: TZConnection;
    ZQuery_Con1: TZQuery;
    ZQuery_Con1CODIGO: TLongintField;
    ZQuery_Con1DESCRICAO: TStringField;
    ZQuery_Con1STATUS: TStringField;
    procedure actDB_Conectar1Execute(Sender: TObject);
    procedure actDB_CriarExecute(Sender: TObject);
    procedure actDB_Desconectar1Execute(Sender: TObject);
    procedure actDelete_ALLExecute(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
    procedure actTrans1_CommitExecute(Sender: TObject);
    procedure actTrans1_IniciarExecute(Sender: TObject);
    procedure actTrans1_RollbackExecute(Sender: TObject);
    procedure btnAlterar1Click(Sender: TObject);
    procedure btnAlterarClick(Sender: TObject);
    procedure edtDescricao_NovaChange(Sender: TObject);
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
    procedure ZQuery_Con1AfterScroll(DataSet: TDataSet);
  private
    FMsgStatus: String;
    FFDB_FileEx:String;
    procedure SetMsgStatus(AValue: String);
    procedure CheckButtons;
    procedure OpenMyData(AForUpdate, AWithLock:Boolean);
    function SQL_TableExists(ATableName: String; out AExist: Boolean): String;
    function Truncate_Table: String;
    function SQL_TableCount:Cardinal;
  public
  published
    property FDB_FileEx:String read FFDB_FileEx;
    property MsgStatus:String read FMsgStatus write SetMsgStatus;
  end;
const
  FDB_FILE='lazdemos_gsl.fdb';
  FDB_TABLE='TEST_SQLINJECTION';
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

{ TfmPrincipal }

procedure TfmPrincipal.FormCreate(Sender: TObject);
begin
  Caption:='Teste de SQL Injection';
  Width:=800;
  Height:=600;
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

procedure TfmPrincipal.actDB_Desconectar1Execute(Sender: TObject);
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

procedure TfmPrincipal.actDelete_ALLExecute(Sender: TObject);
var
  ErrorMsg:String;
begin
  ErrorMsg:=Truncate_Table;
  if ErrorMsg=emptyStr then
    OpenMyData(false, false)
  else
    MsgStatus:=ErrorMsg;
end;

procedure TfmPrincipal.actSearchExecute(Sender: TObject);
begin
  OpenMyData(false, false);
end;

procedure TfmPrincipal.actTrans1_CommitExecute(Sender: TObject);
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

procedure TfmPrincipal.actTrans1_IniciarExecute(Sender: TObject);
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

procedure TfmPrincipal.actTrans1_RollbackExecute(Sender: TObject);
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

procedure TfmPrincipal.btnAlterar1Click(Sender: TObject);
var
  q1:TZQuery;
begin
  q1:=TZQuery.Create(Self);
  q1.Connection:=ZConnection1;
  try
    q1.SQL.Add('UPDATE '+FDB_TABLE+' SET ');
    q1.SQL.Add('  DESCRICAO=:P_DESCRICAO');
    q1.SQL.Add('WHERE CODIGO=:P_CODIGO');
    q1.ParamByName('P_DESCRICAO').AsString:=edtDescricao_Nova.Text;
    q1.ParamByName('P_CODIGO').AsString:=edtCodigo.Text;
    if not q1.Prepared then
    begin
      q1.Prepare;
      MemoStatus.Lines.Add('Query precisou ser preparada');
    end;
    q1.ExecSQL;
    MemoStatus.Lines.Add('Veja o resultado da query parametrizada que você executou:');
    MemoStatus.Lines.Add(q1.SQL.Text);
    OpenMyData(false, false);
  except
  on e:exception do MsgStatus:=zConnection1.Name+': '+e.message;
  end;
  q1.Free;

end;

procedure TfmPrincipal.btnAlterarClick(Sender: TObject);
var
  q1:TZQuery;
begin
  q1:=TZQuery.Create(Self);
  q1.Connection:=ZConnection1;
  try
    q1.SQL.Text:=
      'UPDATE '+FDB_TABLE+' SET '+
      '  DESCRICAO='''+edtDescricao_Nova.Text+''' '+
      'WHERE CODIGO='+edtCodigo.Text;
    q1.ExecSQL;
    MemoStatus.Lines.Add('Veja o resultado da query literal que você executou:');
    MemoStatus.Lines.Add(q1.SQL.Text);
    OpenMyData(false, false);
  except
  on e:exception do MsgStatus:=zConnection1.Name+': '+e.message;
  end;
  q1.Free;

end;

procedure TfmPrincipal.edtDescricao_NovaChange(Sender: TObject);
begin
  MemoStatus.Clear;
end;

procedure TfmPrincipal.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=true;
  actDB_Desconectar1Execute(Sender);

end;

procedure TfmPrincipal.actDB_Conectar1Execute(Sender: TObject);
var
  bIsDirect:Boolean;
  bTableExists:Boolean;
  ErrorMsg:String;
  iRecCount:Cardinal;
  L:TStringList;
begin
  ErrorMsg:=emptyStr;
  bIsDirect:=true;
  bTableExists:=true;
  iRecCount:=0;
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
    ErrorMsg:=SQL_TableExists(FDB_TABLE, bTableExists);
  end;

  if (ErrorMsg=emptyStr) and (ZConnection1.Connected) and (not bTableExists) then
  begin
    // todo: test existence of table and not recreate
    try
      L.Clear;
      L.Add('CREATE TABLE '+FDB_TABLE+'(');
      L.Add('     codigo integer primary key,');     // sem pk a inserção é mais rapida
      L.Add('     descricao varchar(30),');
      L.Add('     status char(1));');
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

  if (ErrorMsg=emptyStr) and (bTableExists) then
  begin
    iRecCount:=SQL_TableCount;
    if iRecCount=0 then
    begin
      try
        if not ZConnection1.InTransaction then
          ZConnection1.StartTransaction;
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE+' (CODIGO, DESCRICAO, STATUS) VALUES (1, ''Açaí'', ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE+' (CODIGO, DESCRICAO, STATUS) VALUES (2, ''Avelã'', ''A'');');

        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE+' (CODIGO, DESCRICAO, STATUS) VALUES (3, ''Maracujá'', ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE+' (CODIGO, DESCRICAO, STATUS) VALUES (4, ''Melão'', ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE+' (CODIGO, DESCRICAO, STATUS) VALUES (5, ''Maçã'', ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE+' (CODIGO, DESCRICAO, STATUS) VALUES (6, ''Mamão'', ''A'');');

        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE+' (CODIGO, DESCRICAO, STATUS) VALUES (7, ''Laranja'', ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE+' (CODIGO, DESCRICAO, STATUS) VALUES (8, ''Limão'', ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE+' (CODIGO, DESCRICAO, STATUS) VALUES (9, ''Lichia'', ''A'');');

        ZConnection1.Commit;
        MsgStatus:='Registros adicionadas na tabela!';
      except
      on e:exception do
         begin
           MsgStatus:=e.Message;
           ZConnection1.Rollback;
         end;
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

procedure TfmPrincipal.Transacao_Iniciada(Sender: TObject);
begin
  // quando uma transação é iniciada então ligo a opção de commit e rollback
  CheckButtons;
  MsgStatus:=TZConnection(Sender).Name+': Transação iniciada';
end;

procedure TfmPrincipal.Transacao_RollBack(Sender: TObject);
begin
  CheckButtons;
  MsgStatus:=TZConnection(Sender).Name+': RollBack';
end;

procedure TfmPrincipal.Conexao_Ligada(Sender: TObject);
begin
  MsgStatus:=TZConnection(Sender).Name+': conectado';
  CheckButtons;

end;

procedure TfmPrincipal.Conexao_Desligada(Sender: TObject);
begin
  CheckButtons;
  MsgStatus:=TZConnection(Sender).Name+': desconectado';
end;

procedure TfmPrincipal.Conexao_Refeita(Sender: TObject);
begin
  CheckButtons;
  MsgStatus:=TZConnection(Sender).Name+': reconectado';
end;

procedure TfmPrincipal.ZConnection1Commit(Sender: TObject);
begin
  CheckButtons;
  MsgStatus:='Transação '+TZConnection(Sender).Name+': Commit';
end;

procedure TfmPrincipal.ZQuery_Con1AfterOpen(DataSet: TDataSet);
begin
  DBGridCon1.Visible:=ZQuery_Con1.Active;
end;

procedure TfmPrincipal.ZQuery_Con1AfterScroll(DataSet: TDataSet);
var
  S:String;
begin
  S:=Dataset.FieldbyName('descricao').AsString;
  edtDescricao_Nova.Items.Clear;
  if edtDescricao_Nova.Items.IndexOf(S)<0 then
  begin
    edtDescricao_Nova.Items.Add(S);
    edtDescricao_Nova.Items.Add('''--'+S);  // forçando o SQL Injection
  end;
end;

procedure TfmPrincipal.SetMsgStatus(AValue: String);
begin
  if FMsgStatus=AValue then Exit;
  FMsgStatus:=AValue;
  MemoStatus.Lines.Add(FMsgStatus);
  //MemoStatus.SelStart:=Length(MemoStatus.Lines.Text);
  MemoStatus.VertScrollBar.Position:=Pred(MemoStatus.Lines.Count);
end;

procedure TfmPrincipal.CheckButtons;
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


  actDelete_ALL.Enabled:= (ZConnection1.Connected);
  gb_test.Visible:=(ZConnection1.Connected);

  if ZConnection1.Connected then
    sbDB_Conectar1.Action:=actDB_Desconectar1
  else
    sbDB_Conectar1.Action:=actDB_Conectar1;

end;

procedure TfmPrincipal.OpenMyData(AForUpdate, AWithLock: Boolean);
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
  on e:exception do MsgStatus:=zConnection1.Name+': '+e.message+sLineBreak+ZQuery_Con1.SQL.Text;
  end;

end;

function TfmPrincipal.Truncate_Table: String;
var
  q1:TZQuery;
begin
  Result:=emptyStr;
  q1:=TZQuery.Create(Self);
  q1.Connection:=ZConnection1;

  // find last one
  q1.sql.Clear;
  q1.sql.add('DELETE FROM TEST_SQLINJECTION;');
  try
    q1.ExecSQL;
  except
  on e:exception do Result:=e.message;
  end;
  if q1.Active then
    q1.Close;
  q1.Free;
end;

function TfmPrincipal.SQL_TableCount: Cardinal;
var
  q1:TZQuery;
begin
  Result:=0;
  if not zConnection1.Connected then
    Exit;
  q1:=TZQuery.Create(Self);
  try
    if q1.Active then
      q1.Close;
    q1.Connection:=ZConnection1;
    q1.SQL.Clear;
    q1.SQL.Add('select count(*) as ncount from '+FDB_TABLE);
    q1.Open;
    if not q1.IsEmpty then
      Result:=q1.FieldbyName('ncount').AsInteger;
  except
  on e:exception do MsgStatus:=zConnection1.Name+': '+e.message+sLineBreak+q1.SQL.Text;
  end;
  q1.Free;
end;

function TfmPrincipal.SQL_TableExists(ATableName: String; out AExist:Boolean): String;
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

