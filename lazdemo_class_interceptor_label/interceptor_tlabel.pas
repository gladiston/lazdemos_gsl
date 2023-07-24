unit interceptor_TLabel;

// Esta é uma classe interceptadora que acrescenta a funcionalidade 'MakeAsLink' ao TLabel
// Basicamente voce coloca a unit interceptor_TLabel na uses de seu form e poderá fazer algo como
// Label1.MakeAsLink:=true
// e então o Label1 sofrerá algumas modificações, por exemplo, ao passar o mouse por cima
// o caption é visto como um link para ser clicado.
// Atenção, a ordem que declarará a unit é importante, ela deve ficar depois de Vcl.StdCtrls
//   na duvida, sempre jogue-a para o final.

{$mode ObjFPC}{$H+}

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls;

type
  TLabel = class (StdCtrls.TLabel)
  private
    FMakeAsLink: Boolean;
    FDoingMakeAsLink:Boolean;
    FOldColor:TColor;
    FOldStyle:TFontStyles;
    FOldCursor:TCursor;
    FOldLeft:Integer;
    FOldWidth:Integer;
    FOldTransparent:Boolean;
    procedure MouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure MouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure SetMakeAsLink(const Value: Boolean);
    procedure EnableEffects;
    procedure DisableEffects;
  protected
  public
    constructor Create(AOwner: TComponent); override;
    property MakeAsLink:Boolean read FMakeAsLink write SetMakeAsLink default false;
  end;

implementation

const
  nMorePixelForBold = 50;  // valor arbitrado por causa do Bold na letra

{ TLabel }
constructor TLabel.Create(AOwner: TComponent);
begin
  inherited ;
  FDoingMakeAsLink:=false;
  BringToFront;
end;


procedure TLabel.SetMakeAsLink(const Value: Boolean);
var
  nTextWidthSize:Integer;
begin
  if Value<>FMakeAsLink then
  begin
    FMakeAsLink := Value;
    if FMakeAsLink then
    begin
      FOldCursor:=Cursor;
      FOldColor:=Font.Color;
      FOldStyle:=Font.Style;
      FOldWidth:=Width;
      FOldLeft:=Left;
      FOldTransparent:=Transparent;
      Font.Color:=clBlue;
      Font.Style:=Font.Style+[fsUnderline];
      Transparent:=true;
      nTextWidthSize:=Canvas.textwidth(caption);
      nTextWidthSize:=nTextWidthSize+(nMorePixelForBold);
      if Width<nTextWidthSize then
      begin
        Left:=Left-(nMorePixelForBold div 2);
        Width:=nTextWidthSize;
      end;
    end
    else
    begin
      if (FDoingMakeAsLink) then
      begin
        DisableEffects;
        FDoingMakeAsLink:=false;
        Font.Style:=FOldStyle;
        Font.Color:=FOldColor;
        Cursor:=FOldCursor;
        Transparent:=FOldTransparent;
        Left:=FOldLeft;
        Width:=FOldWidth;
      end;
    end;
  end;
end;

procedure TLabel.DisableEffects;
begin
  Cursor:=crDefault;
  Font.Style:=Font.Style-[fsBold];
end;

procedure TLabel.EnableEffects;
begin
  Cursor:=crHandPoint;
  if not (fsBold in Font.Style ) then
  begin
    Font.Style:=Font.Style+[fsBold];
    FDoingMakeAsLink:=true;
  end;
end;

procedure TLabel.MouseEnter(var Message: TMessage);
begin
  inherited;
  if FMakeAsLink then
  begin
    EnableEffects;
  end;
end;


procedure TLabel.MouseLeave(var Message: TMessage);
begin
  inherited;
  if FMakeAsLink then
  begin
    if FDoingMakeAsLink then
    begin
      DisableEffects;
    end;
  end;
end;

end.

