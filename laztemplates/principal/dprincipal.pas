unit dprincipal;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ZDataset, ZSqlProcessor, ZConnection, Controls, ActnList,
  Menus, BufDataset, DB;

type

  { Tdm }

  Tdm = class(TDataModule)
    actCalendarioNUtil: TAction;
    actFechar_janelas: TAction;
    actLista_CA: TAction;
    actLista_Colaboradores: TAction;
    actLista_EPI: TAction;
    actLista_Perfis: TAction;
    actLogin: TAction;
    actPreferencias: TAction;
    actRebuid_DayUse: TAction;
    actRebuild_Bag: TAction;
    actSair: TAction;
    actUpgrade_DB: TAction;
    ImageList1: TImageList;
    imagelist_colGrids16x16: TImageList;
    imagelist_colGrids24: TImageList;
    MemCesta: TBufDataset;
    db: TZConnection;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    Separator1: TMenuItem;
    ZQuery1: TZQuery;
    ZSQLProcessor1: TZSQLProcessor;
  private

  public

  end;

var
  dm: Tdm;

implementation

{$R *.lfm}

end.

