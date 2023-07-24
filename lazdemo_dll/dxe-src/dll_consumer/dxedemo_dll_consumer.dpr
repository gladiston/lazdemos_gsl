program dxedemo_dll_consumer;

uses
  Vcl.Forms,
  view.main in 'view.main.pas' {fmPrincipal},
  utils_dll in 'utils_dll.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmPrincipal, fmPrincipal);
  Application.Run;
end.
