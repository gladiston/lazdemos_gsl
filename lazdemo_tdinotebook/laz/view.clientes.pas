unit view.clientes;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TfmClientes }

  TfmClientes = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  fmClientes: TfmClientes;

implementation

{$R *.lfm}

{ TfmClientes }

procedure TfmClientes.FormCreate(Sender: TObject);
begin
  memo1.text:='Formulario '+Self.Name+' criado em '+FormatDateTime('dd/mm/yyyy hh:nn:ss', now);
end;

end.

