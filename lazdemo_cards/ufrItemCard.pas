{
  ufrItemCard.pas
  -----------------
  Frame de Card para exibição de itens (produtos).
  Conceito: Migrando de DBGrid para Cards - Gladiston Santana
  https://gladiston.github.io/lazarus_guia_usando_cards.html

  Este Frame é o "molde" reutilizável: desenhe uma vez, use em vários
  formulários. Os dados são injetados via propriedades (desacoplamento).
}
unit ufrItemCard;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Dialogs, ComCtrls, Types;

type
  { TfrItemCard }
  TfrItemCard = class(TFrame)
    btnAplicar: TButton;
    Image1: TImage;
    lblCodigo: TLabel;
    lblDescricao: TLabel;
    lblDetalhesInfo: TLabel;
    lblEstoque: TLabel;
    lblMostrarMais: TLabel;
    lblValor: TLabel;
    lblVerFoto: TLabel;
    lblVerFotoVoltar: TLabel;
    PageControl1: TPageControl;
    pnlCabecalho: TPanel;
    pnlCard: TPanel;
    pnlConteudo: TPanel;
    pnlDetalhes: TPanel;
    pnlRodape: TPanel;
    TabFoto: TTabSheet;
    TabInicio: TTabSheet;
    procedure Foco_Nao(Sender: TObject);
    procedure Foco_Sim(Sender: TObject);
    procedure FrameMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure lblDescricaoClick(Sender: TObject);
    procedure lblMostrarMaisClick(Sender: TObject);
    procedure lblValorClick(Sender: TObject);
    procedure LabelMouseEnter(Sender: TObject);
    procedure LabelMouseLeave(Sender: TObject);
    procedure lblVerFotoClick(Sender: TObject);
    procedure lblVerFotoVoltarClick(Sender: TObject);
  private
    FCodigo: Integer;
    FDescricao: string;
    FValor: Currency;
    FEstoque: Double;
    procedure SetCodigo(const AValue: Integer);
    procedure SetDescricao(const AValue: string);
    procedure SetValor(const AValue: Currency);
    procedure SetEstoque(const AValue: Double);
  public
    procedure Loaded; override;
    property Codigo: Integer read FCodigo write SetCodigo;
    property Descricao: string read FDescricao write SetDescricao;
    property Valor: Currency read FValor write SetValor;
    property Estoque: Double read FEstoque write SetEstoque;
  end;

implementation
uses
  strUtils,
  Graphics;

{$R *.lfm}

const
  clMySelectionColor = clGradientInactiveCaption;  //clGradientInactiveCaption ou clInfoBK;

{ TfrItemCard }

procedure TfrItemCard.SetCodigo(const AValue: Integer);
begin
  if FCodigo = AValue then Exit;
  FCodigo := AValue;
  lblCodigo.Caption := '#' + IntToStr(FCodigo);
end;

procedure TfrItemCard.SetDescricao(const AValue: string);
begin
  if FDescricao = AValue then Exit;
  FDescricao := AValue;
  lblDescricao.Caption := FDescricao;
end;

procedure TfrItemCard.SetValor(const AValue: Currency);
begin
  if FValor = AValue then Exit;
  FValor := AValue;
  lblValor.Caption := FormatFloat('R$ #,##0.00', FValor);
end;

procedure TfrItemCard.SetEstoque(const AValue: Double);
begin
  if FEstoque = AValue then Exit;
  FEstoque := AValue;
  lblEstoque.Caption := 'Estoque: ' + FloatToStr(FEstoque);
  // Regra visual: estoque zerado ou negativo em destaque
  if FEstoque <= 0 then
  begin
    lblEstoque.Font.Color := clRed;
    lblEstoque.Font.Style := [fsBold];
  end
  else
  begin
    lblEstoque.Font.Color := clDefault;
    lblEstoque.Font.Style := [];
  end;
end;



procedure TfrItemCard.LabelMouseEnter(Sender: TObject);
begin
  // Efeito hyperlink: destaque ao passar o mouse (compartilhado por vários labels)
  if (Sender is TLabel) then
    with (Sender as TLabel) do
    begin
      Font.Style := Font.Style + [fsBold, fsUnderline];
      Font.Color := clBlue;
    end;
end;

procedure TfrItemCard.LabelMouseLeave(Sender: TObject);
begin
  if (Sender is TLabel) then
    with (Sender as TLabel) do
    begin
      Font.Style := Font.Style - [fsBold, fsUnderline];
      Font.Color := clDefault;
    end;
end;

procedure TfrItemCard.lblVerFotoClick(Sender: TObject);
begin
  PageControl1.ActivePage:=TabFoto;
end;



procedure TfrItemCard.lblVerFotoVoltarClick(Sender: TObject);
begin
  PageControl1.ActivePage:=TabInicio;
end;

procedure TfrItemCard.lblDescricaoClick(Sender: TObject);
var
  S, Antiga: string;
begin
  Antiga := Descricao;
  S := InputBox('Alterar descrição', 'Nova descrição:', Descricao);
  if (S <> '') and (S <> Antiga) then
  begin
    Descricao := S;
    btnAplicar.Enabled := True;
  end;
end;

procedure TfrItemCard.lblMostrarMaisClick(Sender: TObject);
begin
  if ContainsText(lblMostrarMais.Caption, 'mais') then
  begin
    pnlDetalhes.Visible := True;
    lblMostrarMais.Caption := 'Mostrar menos ▲';
  end
  else
  begin
    pnlDetalhes.Visible := False;
    lblMostrarMais.Caption := 'Ver mais ▼';
  end;
end;

procedure TfrItemCard.lblValorClick(Sender: TObject);
var
  S: string;
  V: Currency;
begin
  S := InputBox('Alterar valor', 'Novo valor (ex: 10,50):', FormatFloat('0.00', Valor));
  if TryStrToCurr(StringReplace(S, ',', FormatSettings.DecimalSeparator, []), V) and (V >= 0) and (V <> Valor) then
  begin
    Valor := V;
    btnAplicar.Enabled := True;
  end;
end;

procedure TfrItemCard.FrameMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  P: TWinControl;
  SB: TScrollBox;
begin
  // Repassa o scroll para o ScrollBox pai (evita foco preso nos cards)
  P := Parent;
  while Assigned(P) do
  begin
    if P is TScrollBox then
    begin
      SB := TScrollBox(P);
      SB.VertScrollBar.Position := SB.VertScrollBar.Position - WheelDelta;
      Handled := True;
      Exit;
    end;
    P := P.Parent;
  end;
end;

procedure TfrItemCard.Foco_Sim(Sender: TObject);
begin
  // Quando o card ganha foco, aplica a cor de seleção
  if Self.Color <> clMySelectionColor then
      Self.Tag := PtrInt(Self.Color);
  pnlCard.BorderStyle:=bsSingle;
  Self.Color := clMySelectionColor;
end;

procedure TfrItemCard.Foco_Nao(Sender: TObject);
begin
  // Quando o card perde o foco, restaura a cor que estava gravada na Tag
  Self.Color := TColor(Self.Tag);
  pnlCard.BorderStyle:=bsNone;
end;

procedure TfrItemCard.Loaded;
begin
  inherited Loaded;
  // Detalhes começam ocultos (revelamento progressivo)
  pnlDetalhes.Visible := False;
  btnAplicar.Enabled := False;
end;

end.
