library lazdemo_dll_servidor;

{$mode objfpc}{$H+}

uses
  // Sharemem não deve ser usado a menos que quem a consuma também use esta mesma unit.
  //   daí neste caso, você não conseguirá que a DLL seja consumida por outras
  //   linguagens. No caso de usá-la assim mesmo, lembre-se de que em ambos os
  //   projetos, tanto da DLL como do projeto que consome a DLL essa unit sharemem
  //   deve ser a primeira a ser declarada, como fizemos aqui:
  //Sharemem,
  Classes,
  Interfaces,
  lazdemo_dll_servidor_reg;

exports
  DLL_Proc,
  DLL_WhoAmI,
  DLL_Echo;


begin
  ;
end.
