unit fprincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, Forms, Controls, Graphics, Dialogs,
  Buttons, DBGrids, DB, Grids, DBCtrls, ExtCtrls, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    btnPreparada: TBitBtn;
    btnProcurar: TBitBtn;
    ds_mestre: TDataSource;
    Grade_Detalhe: TDBGrid;
    ds_detalhe: TDataSource;
    EDTid_cliente: TEdit;
    gb_procurar_por: TGroupBox;
    Grade_Master: TDBGrid;
    painel_dados: TPanel;
    Panel1: TPanel;
    Splitter1: TSplitter;
    ZConnection1: TZConnection;
    zqry_detalhe: TZQuery;
    zqry_detalheEND_UF: TStringField;
    zqry_detalheID_CLIENTE: TLargeintField;
    zqry_detalheNOME_ALTERNATIVO: TStringField;
    zqry_detalhetemp: TLongintField;
    zqry_mestre: TZQuery;
    zqry_mestreDESCRICAO: TStringField;
    zqry_mestreUF: TStringField;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure btnPreparadaClick(Sender: TObject);
    procedure btnProcurarClick(Sender: TObject);
    procedure Grade_DetalheTitleClick(Column: TColumn);
    procedure zqry_detalheCalcFields(DataSet: TDataSet);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  if zqry_mestre.Active then
    zqry_mestre.Close;
  zqry_mestre.sql.clear;
  zqry_mestre.sql.add('SELECT a.UF, a.DESCRICAO');
  zqry_mestre.sql.add('FROM ADMIN_UF a');
  zqry_mestre.Open;

  if zqry_detalhe.Active then
    zqry_detalhe.Close;

  zqry_detalhe.sql.clear;
  zqry_detalhe.sql.add('SELECT a.ID_CLIENTE, a.NOME_ALTERNATIVO, a.end_UF');
  zqry_detalhe.sql.add('FROM CLIENTES a ');
  zqry_detalhe.sql.add('WHERE a.END_UF=:UF');
  zqry_detalhe.Open;

end;

procedure TForm1.BitBtn2Click(Sender: TObject);
var
  i:Integer;
begin
  i:=zqry_detalhe.RecordCount;
  ShowMessage(IntToStr(i));
  zqry_detalhe.unPrepare;
end;

procedure TForm1.btnPreparadaClick(Sender: TObject);
begin
  TRY
    if zqry_detalhe.Prepared then
       ShowMessage('Preparada')
    else
    ShowMessage('Não preparada');
  finally

  end;
end;

procedure TForm1.btnProcurarClick(Sender: TObject);
begin
  if zqry_detalhe.Active then
    zqry_detalhe.Close;
  zqry_detalhe.sql.clear;
  zqry_detalhe.sql.add('SELECT a.ID_CLIENTE, a.NOME_ALTERNATIVO, a.end_UF');
  zqry_detalhe.sql.add('FROM CLIENTES a ');
  zqry_detalhe.sql.add('WHERE a.ID_CLIENTE=:P_ID_CLIENTE');
  zqry_detalhe.ParamByname('p_id_cliente').AsInteger:=StrToIntDef(EDTid_cliente.Text,0);
  zqry_detalhe.Open;  // .ExecSQL
end;

procedure TForm1.Grade_DetalheTitleClick(Column: TColumn);
begin
  if SameText(Column.FieldName,'nome_Alternativo') then
  begin
    if SameText(zqry_detalhe.IndexFieldNames,'NOME_ALTERNATIVO DESC') then
      zqry_detalhe.IndexFieldNames:='NOME_ALTERNATIVO ASC'
    else
      zqry_detalhe.IndexFieldNames:='NOME_ALTERNATIVO DESC';
  end;
end;

procedure TForm1.zqry_detalheCalcFields(DataSet: TDataSet);
begin
   //DataSet.FieldByName('temp').AsInteger:=
   //  DataSet.FieldbyName('id_cliente').AsInteger+1;
end;

end.

