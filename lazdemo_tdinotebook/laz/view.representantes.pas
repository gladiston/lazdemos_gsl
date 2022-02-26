unit view.representantes;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TfmRepresentantes }

  TfmRepresentantes = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  fmRepresentantes: TfmRepresentantes;

implementation

{$R *.lfm}

{ TfmRepresentantes }

procedure TfmRepresentantes.FormCreate(Sender: TObject);
begin
  memo1.text:='Formulario '+Self.Name+' criado em '+FormatDateTime('dd/mm/yyyy hh:nn:ss', now);
end;

end.

