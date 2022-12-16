program lazdemo_dll_consumer;

{$mode objfpc}{$H+}

uses
  // Sharemem não deve ser usado a menos que quem a consuma também use esta mesma unit.
  //   daí neste caso, você não conseguirá que a DLL seja consumida por outras
  //   linguagens. No caso de usá-la assim mesmo, lembre-se de que em ambos os
  //   projetos, tanto da DLL como do projeto que consome a DLL essa unit sharemem
  //   deve ser a primeira a ser declarada, como fizemos aqui:
  //Sharemem,
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  view.main
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

