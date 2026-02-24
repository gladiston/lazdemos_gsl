{
  umain.pas - Formulário principal
  ---------------------------------
  Demonstração: Cards com TFlowPanel + TScrollBox (sem banco de dados).
  Dados em memória via TBufDataset (FPC). Referência:
  https://gladiston.github.io/lazarus_guia_usando_cards.html
}
unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  BufDataset, db, ufrItemCard;

const
  NOME_ARQUIVO_CSV = 'dados.csv';

type
  TFormMain = class(TForm)
    btnCarregar: TButton;
    FlowPanel1: TFlowPanel;
    Panel1: TPanel;
    ScrollBox1: TScrollBox;
    procedure btnAplicarClick(Sender: TObject);
    procedure btnCarregarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FMemTable: TBufDataset;
    function CaminhoCSV: string;
    procedure CarregarCards;
    procedure CarregarDoCSV;
    procedure CriarEstruturaMemTable;
    procedure CriarOuCarregarCSV;
    procedure PopularDados;
    procedure SalvarCSV;
  public
  end;

var
  FormMain: TFormMain;

implementation

{$R *.lfm}

function TFormMain.CaminhoCSV: string;
begin
  Result := ExtractFilePath(Application.ExeName) + NOME_ARQUIVO_CSV;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  Randomize;
  FMemTable := TBufDataset.Create(Self);
  CriarEstruturaMemTable;
  CriarOuCarregarCSV;
  CarregarCards;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  { FMemTable é owned por Self, não precisa Free }
end;

procedure TFormMain.CriarEstruturaMemTable;
begin
  with FMemTable do
  begin
    FieldDefs.Clear;
    FieldDefs.Add('ID', ftInteger);
    FieldDefs.Add('NOME', ftString, 80);
    FieldDefs.Add('PRECO', ftCurrency);
    FieldDefs.Add('SALDO', ftFloat);
    CreateDataset;
    Open;
  end;
end;

procedure TFormMain.PopularDados;
const
  { Mais de 50 itens para demonstração - dados fictícios }
  NOMES: array[1..55] of string = (
    'Caneta esferográfica azul', 'Lápis grafite HB', 'Borracha branca',
    'Régua 30cm', 'Caderno universitário 96fl', 'Estojo escolar',
    'Cola branca 90g', 'Tesoura sem ponta', 'Apontador duplo',
    'Marca-texto amarelo', 'Clips metálicos cx 100', 'Grampeador pequeno',
    'Envelope branco A4', 'Papel sulfite A4 500fl', 'Pasta catálogo',
    'Fita adesiva 18mm', 'Post-it amarelo', 'Organizador de mesa',
    'Calculadora básica', 'Pen drive 32GB', 'Pilha alcalina AA',
    'Lanterna LED', 'Abridor de latas', 'Garrafa térmica 500ml',
    'Copo plástico descartável', 'Guardanapo papel', 'Sabonete líquido',
    'Papel toalha 2 rolos', 'Detergente 500ml', 'Esponja de aço',
    'Álcool 70% 500ml', 'Desinfetante 1L', 'Vassoura', 'Rodo',
    'Balde 10L', 'Luvas descartáveis', 'Sacola plástica',
    'Arroz tipo 1 5kg', 'Feijão carioca 1kg', 'Óleo soja 900ml',
    'Açúcar refinado 1kg', 'Café torrado 500g', 'Leite UHT 1L',
    'Macarrão espaguete 500g', 'Molho tomate 340g', 'Sal refinado 1kg',
    'Farinha trigo 1kg', 'Biscoito água e sal', 'Sabão em pó 1kg',
    'Amaciante 1L', 'Lustra-móveis 500ml', 'Água sanitária 1L',
    'Shampoo 200ml', 'Condicionador 200ml', 'Escova dental'
  );
var
  i: Integer;
begin
  FMemTable.DisableControls;
  try
    for i := Low(NOMES) to High(NOMES) do
    begin
      FMemTable.Append;
      FMemTable.FieldByName('ID').AsInteger := i;
      FMemTable.FieldByName('NOME').AsString := NOMES[i];
      FMemTable.FieldByName('PRECO').AsCurrency := 1.50 + Random(5000) / 100;
      FMemTable.FieldByName('SALDO').AsFloat := Random(500) - 10;
      FMemTable.Post;
    end;
  finally
    FMemTable.EnableControls;
  end;
  FMemTable.First;
end;

procedure TFormMain.CriarOuCarregarCSV;
begin
  if not FileExists(CaminhoCSV) then
  begin
    PopularDados;
    SalvarCSV;
  end
  else
    CarregarDoCSV;
end;

procedure TFormMain.CarregarDoCSV;
var
  L: TStringList;
  i, j: Integer;
  Linha: string;
  Partes: TStringArray;
  NomeCampo: string;
begin
  L := TStringList.Create;
  try
    L.LoadFromFile(CaminhoCSV, TEncoding.UTF8);
    if L.Count < 2 then Exit;
    FMemTable.DisableControls;
    try
      for i := 1 to L.Count - 1 do
      begin
        Linha := L[i];
        Partes := Linha.Split([#9]);
        if Length(Partes) >= 4 then
        begin
          NomeCampo := Trim(Partes[1]);
          for j := 2 to Length(Partes) - 3 do
            NomeCampo := NomeCampo + #9 + Trim(Partes[j]);
          FMemTable.Append;
          FMemTable.FieldByName('ID').AsInteger := StrToIntDef(Trim(Partes[0]), 0);
          FMemTable.FieldByName('NOME').AsString := NomeCampo;
          FMemTable.FieldByName('PRECO').AsCurrency := StrToCurrDef(StringReplace(Trim(Partes[Length(Partes)-2]), ',', FormatSettings.DecimalSeparator, []), 0);
          FMemTable.FieldByName('SALDO').AsFloat := StrToFloatDef(StringReplace(Trim(Partes[Length(Partes)-1]), ',', FormatSettings.DecimalSeparator, []), 0);
          FMemTable.Post;
        end;
      end;
    finally
      FMemTable.EnableControls;
    end;
    FMemTable.First;
  finally
    L.Free;
  end;
end;

procedure TFormMain.SalvarCSV;
var
  L: TStringList;
begin
  L := TStringList.Create;
  try
    L.Add('ID' + #9 + 'NOME' + #9 + 'PRECO' + #9 + 'SALDO');
    FMemTable.DisableControls;
    try
      FMemTable.First;
      while not FMemTable.EOF do
      begin
        L.Add(
          FMemTable.FieldByName('ID').AsString + #9 +
          StringReplace(FMemTable.FieldByName('NOME').AsString, #9, ' ', [rfReplaceAll]) + #9 +
          FormatFloat('0.00', FMemTable.FieldByName('PRECO').AsCurrency) + #9 +
          FormatFloat('0.00', FMemTable.FieldByName('SALDO').AsFloat)
        );
        FMemTable.Next;
      end;
    finally
      FMemTable.EnableControls;
    end;
    L.SaveToFile(CaminhoCSV, TEncoding.UTF8);
  finally
    L.Free;
  end;
end;

procedure TFormMain.CarregarCards;
var
  Card: TfrItemCard;
begin
  { Garante que o dataset foi criado, mesmo que FormCreate não tenha disparado }
  if FMemTable = nil then
  begin
    FMemTable := TBufDataset.Create(Self);
    CriarEstruturaMemTable;
    CriarOuCarregarCSV;
  end;

  FlowPanel1.DisableAlign;
  try
    while FlowPanel1.ControlCount > 0 do
      FlowPanel1.Controls[0].Free;

    FMemTable.First;
    while not FMemTable.EOF do
    begin
      Card := TfrItemCard.Create(Self);
      Card.Parent := FlowPanel1;
      Card.Name := 'Card_' + FMemTable.FieldByName('ID').AsString;
      Card.PageControl1.ShowTabs:=false;
      Card.PageControl1.ActivePageIndex:=0;

      { Efeito zebra: alternância de cores }
      if Odd(FlowPanel1.ControlCount) then
        Card.Color := $E9EFF5
      else
        Card.Color := $F7F9FB;

      { Injeção de dados via propriedades (desacoplamento) }
      Card.Codigo := FMemTable.FieldByName('ID').AsInteger;
      Card.Descricao := FMemTable.FieldByName('NOME').AsString;
      Card.Estoque := FMemTable.FieldByName('SALDO').AsFloat;
      Card.Valor := FMemTable.FieldByName('PRECO').AsCurrency;

      { O botão Aplicar é tratado pelo formulário: assim sabemos qual card disparou (artigo: Loop de Criação) }
      Card.btnAplicar.OnClick := @btnAplicarClick;

      FMemTable.Next;
    end;
  finally
    FlowPanel1.EnableAlign;
    FlowPanel1.Realign;
  end;
end;

procedure TFormMain.btnCarregarClick(Sender: TObject);
begin
  CarregarCards;
end;

procedure TFormMain.btnAplicarClick(Sender: TObject);
{ Encontra o card que disparou o clique e aplica Descricao/Valor no dataset (artigo: Loop de Criação) }
var
  MyControl: TControl;
  Card: TfrItemCard;
begin
  if not (Sender is TControl) then Exit;
  MyControl := TControl(Sender);
  Card := nil;
  while Assigned(MyControl) do
  begin
    if MyControl is TfrItemCard then
    begin
      Card := TfrItemCard(MyControl);
      Break;
    end;
    MyControl := MyControl.Parent;
  end;
  if (Card = nil) or (FMemTable = nil) or not FMemTable.Active then
    Exit;
  if not FMemTable.Locate('ID', Card.Codigo, []) then
    Exit;
  FMemTable.Edit;
  FMemTable.FieldByName('NOME').AsString := Card.Descricao;
  FMemTable.FieldByName('PRECO').AsCurrency := Card.Valor;
  FMemTable.Post;
  SalvarCSV;
  Card.btnAplicar.Enabled := False;
end;

end.
