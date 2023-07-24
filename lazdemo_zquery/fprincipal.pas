unit fprincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, Forms, Controls, Graphics, Dialogs,
  Buttons, DBGrids, DB, Grids, DBCtrls, ExtCtrls, StdCtrls;

type

  { TfmPrincipal }

  TfmPrincipal = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    btnPreparada: TBitBtn;
    cBoxFiltro_Ativo: TCheckBox;
    edtFetch: TComboBox;
    edtFiltro: TComboBox;
    gb_procurar_por1: TGroupBox;
    Grade_Detalhe: TDBGrid;
    ds_detalhe: TDataSource;
    gb_procurar_por: TGroupBox;
    painel_dados: TPanel;
    Panel1: TPanel;
    Splitter1: TSplitter;
    ZConnection1: TZConnection;
    zqry_detalhe: TZQuery;
    zqry_detalheEND_UF: TStringField;
    zqry_detalheID_CLIENTE: TLargeintField;
    zqry_detalheNOME_ALTERNATIVO: TStringField;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure btnPreparadaClick(Sender: TObject);
    procedure cBoxFiltro_AtivoChange(Sender: TObject);
    procedure edtFetchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure edtFetchKeyPress(Sender: TObject; var Key: char);
    procedure edtFetchSelect(Sender: TObject);
    procedure edtFiltroKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtFiltroSelect(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Grade_DetalheMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Grade_DetalheTitleClick(Column: TColumn);
  private
    procedure Executar_Filtro;
    procedure Paginar_Dados;
    procedure Abrir_dados(ASQL_Extra:String='');
  public

  end;

var
  fmPrincipal: TfmPrincipal;

implementation
uses LCLType;
{$R *.lfm}

{ TfmPrincipal }

procedure TfmPrincipal.BitBtn1Click(Sender: TObject);
begin
  Abrir_dados;

end;

procedure TfmPrincipal.BitBtn2Click(Sender: TObject);
var
  i:Integer;
begin
  i:=zqry_detalhe.RecordCount;
  ShowMessage(IntToStr(i));
  zqry_detalhe.unPrepare;
end;

procedure TfmPrincipal.btnPreparadaClick(Sender: TObject);
begin
  TRY
    if zqry_detalhe.Prepared then
       ShowMessage('Preparada')
    else
    ShowMessage('Não preparada');
  finally

  end;
end;

procedure TfmPrincipal.cBoxFiltro_AtivoChange(Sender: TObject);
begin
  zqry_detalhe.Filtered:=cBoxFiltro_Ativo.Checked;
end;

procedure TfmPrincipal.edtFetchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=VK_RETURN then
  begin
    Paginar_Dados;
  end;
end;

procedure TfmPrincipal.edtFetchKeyPress(Sender: TObject; var Key: char);
begin
  if Pos(Key, '-0123456789')<=0 then
    Key:=#0;
end;

procedure TfmPrincipal.edtFetchSelect(Sender: TObject);
begin
  Paginar_Dados;
end;

procedure TfmPrincipal.edtFiltroKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=VK_RETURN then
  begin
     Executar_Filtro;
  end;
end;

procedure TfmPrincipal.edtFiltroSelect(Sender: TObject);
begin
  Executar_Filtro;
end;

procedure TfmPrincipal.FormCreate(Sender: TObject);
begin
  Caption:='Demo ZQuery';

  edtFetch.Items.Clear;
  edtFetch.Items.Add('0');
  edtFetch.Items.Add('-1');
  edtFetch.Items.Add('100');
  //
  edtFiltro.Items.Clear;
  edtFiltro.Items.Add('end_uf=''SP''  ');
  edtFiltro.Items.Add('id_cliente>100');
  edtFiltro.Items.Add('nome_alternativo like ''ak*''  ');
end;

procedure TfmPrincipal.FormShow(Sender: TObject);
begin
  if ZConnection1.Connected then
    Abrir_dados();
end;

procedure TfmPrincipal.Grade_DetalheMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  Col,
  Row : Integer;
  InTitle:Boolean;
begin
  Col := Grade_Detalhe.MouseCoord(X, Y).X;
  Row := Grade_Detalhe.MouseCoord(X, Y).Y;
  InTitle:=(Row=0);
  if InTitle then
    Grade_Detalhe.Cursor:=crHandPoint
  else
    Grade_Detalhe.Cursor:=crDefault;
end;

procedure TfmPrincipal.Grade_DetalheTitleClick(Column: TColumn);
begin
  if SameText(zqry_detalhe.IndexFieldNames,Column.FieldName+' DESC') then
    zqry_detalhe.IndexFieldNames:=Column.FieldName+' ASC'
  else
    zqry_detalhe.IndexFieldNames:=Column.FieldName+' DESC';
end;

procedure TfmPrincipal.Executar_Filtro;
begin
  if zqry_detalhe.Filtered then
    zqry_detalhe.Filtered:=false;
  zqry_detalhe.Filter:=edtFiltro.Text;
  zqry_detalhe.Filtered:=true;
  cBoxFiltro_Ativo.Checked:=zqry_detalhe.Filtered;
end;

procedure TfmPrincipal.Paginar_Dados;
begin
  zqry_detalhe.FetchRow:=StrToIntdef(edtFetch.Text, 0);
  zqry_detalhe.Close;
  zqry_detalhe.Open;

end;

procedure TfmPrincipal.Abrir_dados(ASQL_Extra: String='');
begin
  if zqry_detalhe.Active then
    zqry_detalhe.Close;

  zqry_detalhe.sql.clear;
  zqry_detalhe.sql.add('SELECT a.ID_CLIENTE, a.NOME_ALTERNATIVO, a.end_UF');
  zqry_detalhe.sql.add('FROM CLIENTES a ');
  zqry_detalhe.sql.add('WHERE (true)');
  if ASQL_Extra<>emptyStr then
    zqry_detalhe.sql.add(ASQL_Extra);
  zqry_detalhe.Open;

end;

end.

