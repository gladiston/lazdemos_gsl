unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  Forms,
  Controls,
  Graphics,
  Dialogs, Buttons, StdCtrls,
  TypInfo;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnEnviar: TButton;
    btnLimpar: TButton;
    Edit1: TEdit;
    Edit10: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    edtFrase: TEdit;
    GroupBox1: TGroupBox;
    procedure btnEnviarClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure ClearEdits(const aContainer: TWinControl);
    procedure SetPropertiesText(
      const aContainer: TWinControl;
      ACompName:String;
      AValue:String);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }
procedure TForm1.ClearEdits(const aContainer: TWinControl);
var
  i: integer;
  PropInfo : PPropInfo;
  Component: TComponent;
begin
  // requer unit TypInfo
 for i := 0 to Pred(aContainer.ComponentCount) do
 begin
   Component := aContainer.Components[i];
   if (Component is TWinControl) then
   begin
     PropInfo := GetPropInfo(Component.ClassInfo, 'Text');
     if Assigned(PropInfo)  then
     begin
       if Assigned(PropInfo) then
       begin
         // agora que sabemos que tem a propriedade text,
         // decida o que fazer
         if Assigned(PropInfo) then // Verifica se a propriedade Text existe
           SetStrProp(Component, PropInfo, ''); // Define a propriedade Text como uma string vazia
       end;
     end;
   end;
 end;
end;

procedure TForm1.SetPropertiesText(
  const aContainer: TWinControl;
  ACompName:String;
  AValue:String);
var
  i: integer;
  PropInfo : PPropInfo;
  Component: TComponent;
  bDoit:Boolean;
begin
  for i := 0 to Pred(aContainer.ComponentCount) do
  begin
    Component := aContainer.Components[i];
    bDoit:=(ACompName='');
    if ((not bDoit) and (ACompName<>'')) then
    begin
      if (SameText(Component.Name,ACompName)) then
        bDoit:=true;
    end;
    if (Component is TWinControl) and (bDoit) then
    begin
      PropInfo := GetPropInfo(Component.ClassInfo, 'Text');
      if Assigned(PropInfo) then
        SetStrProp(Component, PropInfo, AValue);
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  edtFrase.Text:='Helo World';

end;

procedure TForm1.btnEnviarClick(Sender: TObject);
begin
  SetPropertiesText(Self, '', edtFrase.text);
end;

procedure TForm1.btnLimparClick(Sender: TObject);
begin
  ClearEdits(Self);
end;

end.

