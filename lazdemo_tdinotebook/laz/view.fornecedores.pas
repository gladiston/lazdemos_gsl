unit view.fornecedores;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TfmFornecedores }

  TfmFornecedores = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  fmFornecedores: TfmFornecedores;

implementation

{$R *.lfm}

{ TfmFornecedores }

procedure TfmFornecedores.FormCreate(Sender: TObject);
begin
  memo1.text:='Formulario '+Self.Name+' criado em '+FormatDateTime('dd/mm/yyyy hh:nn:ss', now);
end;

end.

