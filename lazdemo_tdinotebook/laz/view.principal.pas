unit view.principal;

{$mode ObjFPC}{$H+}

interface

uses
  Classes,
  SysUtils,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  ComCtrls,
  Menus,
  ActnList,
  TDIClass;

type

  { TfmPrincipal }

  TfmPrincipal = class(TForm)
    actClientes: TAction;
    actFornecedores: TAction;
    ActionList1: TActionList;
    actMostrarTabs: TAction;
    actRepresentantes: TAction;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    TDINoteBook1: TTDINoteBook;
    procedure actClientesExecute(Sender: TObject);
    procedure actFornecedoresExecute(Sender: TObject);
    procedure actMostrarTabsExecute(Sender: TObject);
    procedure actRepresentantesExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FUseTabs: Boolean;
    procedure SetUseTabs(AValue: Boolean);

  public
  public
    property UseTabs:Boolean read FUseTabs write SetUseTabs;
  end;

var
  fmPrincipal: TfmPrincipal;

implementation
uses
  view.clientes,
  view.fornecedores,
  view.representantes;

{$R *.lfm}

{ TfmPrincipal }

procedure TfmPrincipal.actClientesExecute(Sender: TObject);
var
  i:Integer;
begin
  // O codigo abaixo é para ser didático
  i:=TDINoteBook1.FindFormInPages(fmClientes);
  if i<0 then  // não existe, então cria
    fmClientes:=TfmClientes.Create(Self);
  // e então mostra
  TDINoteBook1.ShowFormInPage(fmClientes, i);

end;

procedure TfmPrincipal.actFornecedoresExecute(Sender: TObject);
var
  i:Integer;
begin
  // O codigo abaixo é para ser didático
  i:=TDINoteBook1.FindFormInPages(fmFornecedores);
  if i<0 then  // não existe, então cria
    fmFornecedores:=TfmFornecedores.Create(Self);
  // e então mostra
  TDINoteBook1.ShowFormInPage(fmFornecedores, i);

end;

procedure TfmPrincipal.actMostrarTabsExecute(Sender: TObject);
begin
  UseTabs:=(not UseTabs)  ;
end;

procedure TfmPrincipal.actRepresentantesExecute(Sender: TObject);
var
  i:Integer;
begin
  // O codigo abaixo é para ser didático
  i:=TDINoteBook1.FindFormInPages(fmRepresentantes);
  if i<0 then  // não existe, então cria
    fmRepresentantes:=TfmRepresentantes.Create(Self);
  // e então mostra
  TDINoteBook1.ShowFormInPage(fmRepresentantes, i);

end;

procedure TfmPrincipal.FormCreate(Sender: TObject);
begin
  // Um TDINotebook não funciona sem um MainMenu para associar.
  // Isso é estranho, mas tenho que aceitar. A instrução abaixo
  // é inóqua, você tem de fazer a associação abaixo em tempo
  // de design
  TDINoteBook1.MainMenu:=MainMenu1;
  // TDINoteook cobrirá a área inteira, remova os comentários para
  // deixar sua aplicação não ter a cara de navegador de google chrome
  // caso contrário, ao deixá-las ficará pratico, mas com cara de google chrome
  TDINoteBook1.Align:=alClient;

  // Usar TDI mostrando as tabs?
  UseTabs:=false;
end;

procedure TfmPrincipal.SetUseTabs(AValue: Boolean);
begin
  //if FUseTabs=AValue then Exit;
  FUseTabs:=AValue;
  TDINoteBook1.CloseAllTabs;
  actMostrarTabs.Checked:=FUseTabs;
  if FUseTabs then
  begin
    // Se as suas janelas tiver um botão de fechar ou sair então é bom
    // esconder o botão de fechar "X" na tab com tbNone, caso contrário
    // use tbMenu ou tbButtom para representar uma opção ed fechamento
    TDINoteBook1.CloseTabButtom:=tbButtom;   // tbNone, tbMenu, tbButtom
    // nboHidePageListPopup: Não tem popup para mostrar as tabs(paginas)
    TDINoteBook1.Options:=TDINoteBook1.Options+[nboHidePageListPopup];
    // nboShowAddTabButton: Não mostra opção para adicionar nova tab
    TDINoteBook1.Options:=TDINoteBook1.Options+[nboShowAddTabButton];
    // nboShowCloseButtons: Botões de fechar não serão exibidos
    TDINoteBook1.Options:=TDINoteBook1.Options+[nboShowCloseButtons];
    // Mostra ou não as orelhinha nas tabs
    TDINoteBook1.ShowTabs:=true;
    // Como se trata de um aplicativo tabbed então alguns tabs/botões
    // seriam interessantes
    TDINoteBook1.TDIActions.CloseAllTabs.Visible:=true;
    TDINoteBook1.TDIActions.CloseTab.Visible:=false;
    TDINoteBook1.TDIActions.NextTab.Visible:=false;
    TDINoteBook1.TDIActions.PreviousTab.Visible:=false;
    TDINoteBook1.TDIActions.TabsMenu.Visible:=true;
  end
  else
  begin
    // Se as suas janelas tiver um botão de fechar ou sair então é bom
    // esconder o botão de fechar "X" na tab com tbNone, caso contrário
    // use tbMenu ou tbButtom para representar uma opção ed fechamento
    TDINoteBook1.CloseTabButtom:=tbNone;   // tbNone, tbMenu, tbButtom
    // nboHidePageListPopup: Não tem popup para mostrar as tabs(paginas)
    TDINoteBook1.Options:=TDINoteBook1.Options-[nboHidePageListPopup];
    // nboShowAddTabButton: Não mostra opção para adicionar nova tab
    TDINoteBook1.Options:=TDINoteBook1.Options-[nboShowAddTabButton];
    // nboShowCloseButtons: Botões de fechar não serão exibidos
    TDINoteBook1.Options:=TDINoteBook1.Options-[nboShowCloseButtons];
    // Mostra ou não as orelhinha nas tabs
    TDINoteBook1.ShowTabs:=false;
    // Como se trata de um aplicativo comercial e não um navegador então
    // é melhor esconder outros botões
    TDINoteBook1.TDIActions.CloseAllTabs.Visible:=false;
    TDINoteBook1.TDIActions.CloseTab.Visible:=false;
    TDINoteBook1.TDIActions.NextTab.Visible:=false;
    TDINoteBook1.TDIActions.PreviousTab.Visible:=false;
    TDINoteBook1.TDIActions.TabsMenu.Visible:=false;
  end;
end;

end.

