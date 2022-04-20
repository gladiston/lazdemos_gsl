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
        btnAlimentar_Literal: TBitBtn;
    btnAlterar1: TBitBtn;
    cBox_Preparar: TCheckBox;
    ComboBox_Con1: TComboBox;
    DBGrid1: TDBGrid;
    DBGridCon1: TGroupBox;
    DS_ZQuery_Con1: TDataSource;
    gbConexao1: TPanel;
    gb_test: TGroupBox;
    MemoStatus: TMemo;
    OpenDialog1: TOpenDialog;
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
    ZQuery_Con1END_CIDADE: TStringField;
    ZQuery_Con1END_UF: TStringField;
    ZQuery_Con1ID_CLIENTE: TLongintField;
    ZQuery_Con1NOME_ALTERNATIVO: TStringField;
    ZQuery_Con1STATUS: TStringField;
    zqupdate: TZQuery;
    procedure actDB_Conectar1Execute(Sender: TObject);
    procedure actDB_CriarExecute(Sender: TObject);
    procedure actDB_Desconectar1Execute(Sender: TObject);
    procedure actDelete_ALLExecute(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
    procedure actTrans1_CommitExecute(Sender: TObject);
    procedure actTrans1_IniciarExecute(Sender: TObject);
    procedure actTrans1_RollbackExecute(Sender: TObject);
    procedure btnAlterar1Click(Sender: TObject);
    procedure btnAlimentar_LiteralClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
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
    function SQL_TableExists(ATableName: String; out AExist: Boolean): String;
    function Truncate_Table: String;
    function SQL_TableCount(ATABLE_NAME:String): Cardinal;
    function CSV_Importar_ComSQLLiteral(AFileName:String; AUsePrepare:Boolean):String;
  public
  published
    property FDB_FileEx:String read FFDB_FileEx;
    property MsgStatus:String read FMsgStatus write SetMsgStatus;
  end;
const
  FDB_FILE='lazdemos_gsl.fdb';
  FDB_TABLE1='UF';
  FDB_TABLE2='CLIENTES';
  FDB_USERNAME='SYSDBA';
  FDB_PASSWORD='masterkey';
  FDB_PAGESIZE=16384;
  FDB_CHARSET='UTF8';
  FDB_COLLATION='UNICODE_CI_AI';
  CSV_FILE='clien tes.csv';
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

procedure TfmPrincipal.FormShow(Sender: TObject);
begin
  OpenDialog1.Filename:='..'+PathDelim+'db'+PathDelim+CSV_FILE;
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
  sys_last_error:String;
begin
  sys_last_error:=emptyStr;
  if OpenDialog1.Execute then
    begin
      sys_last_error:=CSV_Importar_ComSQLLiteral(OpenDialog1.Filename, true);
    end
  else
    sys_last_error:='Nenhum arquivo foi selecionado';

  if  sys_last_error<>emptyStr then
    MemoStatus.Lines.Add('FALHOU: '+sys_last_error)
  else
    OpenMyData(false, false);

end;

procedure TfmPrincipal.btnAlimentar_LiteralClick(Sender: TObject);
var
  sys_last_error:String;
begin
  sys_last_error:=emptyStr;
  if OpenDialog1.Execute then
    begin
      sys_last_error:=CSV_Importar_ComSQLLiteral(OpenDialog1.Filename, false);
    end
  else
    sys_last_error:='Nenhum arquivo foi selecionado';

  if  sys_last_error<>emptyStr then
    MemoStatus.Lines.Add('FALHOU: '+sys_last_error)
  else
    OpenMyData(false, false);

end;

procedure TfmPrincipal.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=true;
  actDB_Desconectar1Execute(Sender);

end;

procedure TfmPrincipal.actDB_Conectar1Execute(Sender: TObject);
var
  bIsDirect:Boolean;
  bTable1Exists:Boolean;
  bTable2Exists:Boolean;
  ErrorMsg:String;
  iRecCount:Cardinal;
  L:TStringList;
begin
  ErrorMsg:=emptyStr;
  bIsDirect:=true;
  bTable1Exists:=true;
  bTable2Exists:=true;
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
    ErrorMsg:=SQL_TableExists(FDB_TABLE1, bTable1Exists);
    if ErrorMsg=emptyStr then
      ErrorMsg:=SQL_TableExists(FDB_TABLE2, bTable2Exists);
  end;

  if (ErrorMsg=emptyStr) and (ZConnection1.Connected) and (not bTable1Exists) then
  begin
    // todo: test existence of table and not recreate
    try
      L.Clear;
      L.Add('CREATE TABLE '+FDB_TABLE1+'(');
      L.Add('     uf varchar(2) primary key,');     // sem pk a inserção é mais rapida
      L.Add('     descricao varchar(30),');
      L.Add('     status char(1));');
      if not ZConnection1.InTransaction then
        ZConnection1.StartTransaction;
      ZConnection1.ExecuteDirect(L.Text);
      ZConnection1.Commit;
      MsgStatus:='Tabela '+FDB_TABLE1+' criada!';
    except
    on e:exception do
       begin
         ErrorMsg:=e.Message;
         ZConnection1.Rollback;
       end;
    end;
  end;

  if (ErrorMsg=emptyStr) and (ZConnection1.Connected) and (not bTable2Exists) then
  begin
    // todo: test existence of table and not recreate
    try
      L.Clear;
      L.Add('CREATE TABLE '+FDB_TABLE2+'(');
      L.Add('     id_cliente integer generated by default as identity primary key,');     // sem pk a inserção é mais rapida
      L.Add('     nome_alternativo varchar(120),');
      L.Add('     end_cidade varchar(120),');
      L.Add('     end_uf varchar(2),');
      L.Add('     status char(1));');
      if not ZConnection1.InTransaction then
        ZConnection1.StartTransaction;
      ZConnection1.ExecuteDirect(L.Text);
      ZConnection1.Commit;
      MsgStatus:='Tabela '+FDB_TABLE2+' criada!';
    except
    on e:exception do
       begin
         ErrorMsg:=e.Message;
         ZConnection1.Rollback;
       end;
    end;
  end;

  if (ErrorMsg=emptyStr) and (bTable1Exists) then
  begin
    iRecCount:=SQL_TableCount(FDB_TABLE1);
    if iRecCount=0 then
    begin
      try
        if not ZConnection1.InTransaction then
          ZConnection1.StartTransaction;
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''SP'', ''SÃO PAULO'', ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''*'', ''Nao se aplica'',  ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''AC'', ''ACRE'',  ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''AL'', ''ALAGOAS'', ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''AM'', ''AMAZONAS'',  ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''AP'', ''AMAPÁ'',  ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''BA'', ''BAHIA'',  ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''CE'', ''CEARÁ'',  ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''DF'', ''DISTRITO FEDERAL'',  ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''ES'', ''ESPÍRITO SANTO'',  ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''GO'', ''GOÍAS'',  ''A'' );');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''MA'', ''MARANHÃO'',  ''A'' );');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''MG'', ''MINAS GERAIS'', ''A'' );');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''MS'', ''MATO GROSSO DO SUL'', ''A'' );');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''MT'', ''MATO GROSSO'', ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''PA'', ''PARÁ'', ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''PB'', ''PARAIBA'', ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''PE'', ''PERNAMBUCO'', ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''PI'', ''PIAUÍ'', ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''PR'', ''PARANÁ'', ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''RJ'', ''RIO DE JANEIRO'', ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''RN'', ''RIO GRANDE DO NORTE'', ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''RO'', ''RONDONIA'', ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''RR'', ''RORAIMA'', ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''RS'', ''RIO GRANDE DO SUL'', ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''SC'', ''SANTA CATARINA'', ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''SE'', ''SERGIPE'', ''A'');');
        ZConnection1.ExecuteDirect('INSERT INTO '+FDB_TABLE1+' (UF, DESCRICAO, STATUS) VALUES (''TO'', ''TOCANTINS'', ''A'');');
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
    begin
      if zqupdate.active then
        zqupdate.Close;
      zqupdate.Connection:=ZConnection1;
      zqupdate.sql.clear;
      zqupdate.sql.add('UPDATE OR INSERT INTO '+FDB_TABLE2+'(');
      zqupdate.sql.add('     id_cliente,');
      zqupdate.sql.add('     nome_alternativo,');
      zqupdate.sql.add('     end_cidade,');
      zqupdate.sql.add('     end_uf,');
      zqupdate.sql.add('     status) ');
      zqupdate.sql.add('values(');
      zqupdate.sql.add('  :p_id_cliente,');
      zqupdate.sql.add('  :p_NOME_ALTERNATIVO,');
      zqupdate.sql.add('  :p_END_CIDADE,');
      zqupdate.sql.add('  :p_END_UF,');
      zqupdate.sql.add('  :p_STATUS) ');
      zqupdate.sql.add('MATCHING(id_cliente) ;');      // bug tá comendo linhas com a com til porque banco utf8 e charset=ISO8859_1 e autoencode=true
      try
        if not zqupdate.Prepared then
          zqupdate.Prepare;
      except
      on e:exception do MsgStatus:='Erro ao preparar query:'+sLineBreak+zqupdate.sql.Text;
      end;

      actSearchExecute(nil);
    end;
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
    ZQuery_Con1.SQL.Add('select');
    ZQuery_Con1.SQL.Add(' a.ID_CLIENTE, a.NOME_ALTERNATIVO, a.END_CIDADE, a.END_UF, a.STATUS');
    ZQuery_Con1.SQL.Add('FROM '+FDB_TABLE2+' a');
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

function TfmPrincipal.SQL_TableCount(ATABLE_NAME:String): Cardinal;
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
    q1.SQL.Add('select count(*) as ncount from '+ATABLE_NAME);
    q1.Open;
    if not q1.IsEmpty then
      Result:=q1.FieldbyName('ncount').AsInteger;
  except
  on e:exception do MsgStatus:=zConnection1.Name+': '+e.message+sLineBreak+q1.SQL.Text;
  end;
  q1.Free;
end;

function TfmPrincipal.CSV_Importar_ComSQLLiteral(AFileName: String; AUsePrepare:Boolean): String;
var
  i:integer;
  sID_CLIENTE:String;
  col_ID_CLIENTE:Longint;
  col_NOME_ALTERNATIVO:String;
  col_END_CIDADE:String;
  col_END_UF:String;
  col_STATUS:String;
  sLinha:String;
  sSQL:Utf8String;
  CSV_DataRow: TStringList;
  myFile : TextFile;
begin
  Result:=emptyStr;

  CSV_DataRow:=TStringList.Create;
  CSV_DataRow.Delimiter:=';'; // delimitador
  CSV_DataRow.QuoteChar:='''';     // aspas simples
  CSV_DataRow.StrictDelimiter:=true;  // quando não for usar espaço como delimitador

  if zqupdate.active then
    zqupdate.Close;
  zqupdate.Connection:=ZConnection1;
  if not fileExists(AFileName) then
      Result:='Arquivo não existe: '+AFileName;

  if Result=emptyStr then
  begin
    AssignFile(myFile, AFileName);
    Reset(myFile);
    ReadLn(myFile, sLinha); // a linha 0 é o cabecalho e precisa ser pulada
    i:=0;
    while not Eof(myFile) do
    begin
      Inc(i);
      ReadLn(myFile, sLinha);
      CSV_DataRow.Clear;
      CSV_DataRow.DelimitedText:=sLinha;  // texto delimitado

      sID_CLIENTE:=CSV_DataRow[0];
      col_NOME_ALTERNATIVO:=emptystr;
      col_END_CIDADE:=emptystr;
      col_END_UF:=emptyStr;
      col_STATUS:=emptystr;
      if CSV_DataRow.Count>0
        then col_NOME_ALTERNATIVO:=CSV_DataRow[1]; // coluna 1
      if CSV_DataRow.Count>1
        then col_END_CIDADE:=CSV_DataRow[2]; // coluna 2
      if CSV_DataRow.Count>2
        then col_END_UF:=CSV_DataRow[3];  // coluna 3
      if CSV_DataRow.Count>3
        then col_STATUS:=CSV_DataRow[4];  // coluna 4

      if (Result=emptyStr) and (not TryStrToInt(sID_CLIENTE, col_ID_CLIENTE)) then  // coluna 0
        Result:='Erro ao ler a linha #'+IntToStr(i)+': id_cliente='+sID_CLIENTE+' é inválido';
      //if (Result=emptyStr) and (col_NOME_ALTERNATIVO=emptyStr) then  // coluna 1
      //  Result:='Erro ao ler a linha #'+IntToStr(i)+': nome alternativo não pode ser vazio';
      //if (Result=emptyStr) and (col_END_CIDADE=emptyStr) then  // coluna 2
      //  Result:='Erro ao ler a linha #'+IntToStr(i)+': cidade não pode ser vazio';
      //if (Result=emptyStr) and (col_END_UF=emptyStr) then  // coluna 3
      //  Result:='Erro ao ler a linha #'+IntToStr(i)+': UF não pode ser vazio';
      //if (Result=emptyStr) and (col_STATUS=emptyStr) then  // coluna 3
      //  Result:='Erro ao ler a linha #'+IntToStr(i)+': STATUS não pode ser vazio';
      if (Result=emptyStr)
        and (col_END_CIDADE<>emptyStr)
        and (col_NOME_ALTERNATIVO<>emptyStr)
        and (col_END_CIDADE<>emptyStr)
        and (col_END_UF<>emptyStr)
        and (col_STATUS<>emptyStr)  then
      begin
        col_NOME_ALTERNATIVO:=Trim(col_NOME_ALTERNATIVO);
        col_END_CIDADE:=Trim(col_END_CIDADE);
        col_END_UF:=Trim(col_END_UF);
        col_STATUS:=Trim(col_STATUS);
        sSQL:=
          'UPDATE OR INSERT INTO '+FDB_TABLE2+'('+sLineBreak+
          '     id_cliente,'+sLineBreak+
          '     nome_alternativo,'+sLineBreak+
          '     end_cidade,'+sLineBreak+
          '     end_uf,'+sLineBreak+
          '     status) '+sLineBreak+
          'values('+sLineBreak+
          IntToStr(col_ID_CLIENTE)+','+sLineBreak+
          QuotedStr(col_NOME_ALTERNATIVO)+','+sLineBreak+
          QuotedStr(col_END_CIDADE)+','+sLineBreak+
          QuotedStr(col_END_UF)+','+sLineBreak+
          QuotedStr(col_STATUS)+') '+sLineBreak+
          'MATCHING(id_cliente) ;'+sLineBreak;
        if AUsePrepare then
        begin
          if zqupdate.Active then
            zqupdate.Close;
          zqupdate.parambyname('p_id_cliente').AsInteger:=col_ID_CLIENTE;
          zqupdate.parambyname('p_NOME_ALTERNATIVO').AsString:=col_NOME_ALTERNATIVO;
          zqupdate.parambyname('p_END_CIDADE').AsString:=col_END_CIDADE;
          zqupdate.parambyname('p_END_UF').AsString:=col_END_UF;
          zqupdate.parambyname('p_STATUS').AsString:=col_STATUS;
          try
            zqupdate.ExecSQL;
          except
          on e:exception do Result:='Erro na linha #'+IntToStr(i)+': '+e.message+sLineBreak+zqupdate.sql.Text;
          end;
        end
        else
        begin
          // bug tá comendo linhas com 'a' com til porque banco utf8 e charset=ISO8859_1 e autoencode=true

          try
            zqupdate.sql.clear;
            zqupdate.sql.AddText(sSQL);
            zqupdate.ExecSQL;
            //ZConnection1.ExecuteDirect(sSQL);
          except
          on e:exception do Result:='Erro na linha #'+IntToStr(i)+': '+e.message+sLineBreak+sSQL;
          end;
        end;


      end;
    end;
  end;
  CSV_DataRow.Free;
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

