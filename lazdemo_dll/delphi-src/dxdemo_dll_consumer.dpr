program dxdemo_dll_consumer;

uses
  Vcl.Forms,
  view.main in 'view.main.pas' {Form1},
  utils_dll in 'utils_dll.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
