unit view.main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ActnList,
  ComCtrls, StdCtrls, Buttons;

type

  { TfmMAIN }

  TfmMAIN = class(TForm)
    actCustumers: TAction;
    actClose: TAction;
    actRepresentatives: TAction;
    actSupplyers: TAction;
    ActionList1: TActionList;
    Button1: TSpeedButton;
    Button2: TSpeedButton;
    Button3: TSpeedButton;
    Button4: TSpeedButton;
    ImageList1: TImageList;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    procedure actCloseExecute(Sender: TObject);
    procedure actCustumersExecute(Sender: TObject);
    procedure actRepresentativesExecute(Sender: TObject);
    procedure actSupplyersExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public
    function FindFormInTab(AForm: TForm): Integer;
  end;

var
  fmMAIN: TfmMAIN;

implementation

uses view.custumers, view.representatives, view.supplyers;

{$R *.lfm}

{ TfmMAIN }

procedure TfmMAIN.actSupplyersExecute(Sender: TObject);
var
  i:Integer;
begin
  if not Assigned(fmSupplyers) then
  begin
    fmSupplyers:=TfmSupplyers.Create(Self);
    fmSupplyers.ManualDock(PageControl1);
    fmSupplyers.Show;
    i:=Pred(PageControl1.PageCount);  // last one
  end
  else
  begin
    i:=FindFormInTab(fmSupplyers);
  end;
  if i>=0 then
    PageControl1.ActivePageIndex:=i; //Pred(PageControl1.PageCount);
end;

procedure TfmMAIN.actCustumersExecute(Sender: TObject);
var
  i:Integer;
begin
  i:=FindFormInTab(fmCustumers);
  //if not Assigned(fmCustumers) then  // not run in second time
  if i<0 then
  begin
    fmCustumers:=TfmCustumers.Create(Self);
    fmCustumers.ManualDock(PageControl1);
    fmCustumers.Show;
    i:=Pred(PageControl1.PageCount);  // last one
  end
  else
  begin
    i:=FindFormInTab(fmCustumers);
  end;
  if i>=0 then
    PageControl1.ActivePageIndex:=i; //Pred(PageControl1.PageCount);
end;

procedure TfmMAIN.actCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TfmMAIN.actRepresentativesExecute(Sender: TObject);
var
  i:Integer;
begin
  if not Assigned(fmRepresentatives) then
  begin
    fmRepresentatives:=TfmRepresentatives.Create(Self);
    fmRepresentatives.ManualDock(PageControl1);
    fmRepresentatives.Show;
    i:=Pred(PageControl1.PageCount);  // last one
  end
  else
  begin
    i:=FindFormInTab(fmRepresentatives);
  end;
  if i>=0 then
    PageControl1.ActivePageIndex:=i; //Pred(PageControl1.PageCount);
end;

procedure TfmMAIN.FormCreate(Sender: TObject);
begin
  // The Pagecontrol must be a dock site
  PageControl1.DockSite:=true;
  PageControl1.ShowTabs:=false;
end;

function TfmMAIN.FindFormInTab(AForm: TForm): Integer;
var
  i:Integer;
  iPageCount:Integer;
  //j:Integer;
  curPage:TTabSheet;
begin
  Result:=-1;
  iPageCount:=PageControl1.PageCount;
  i:=0;
  while (i<=Pred(iPageCount)) and (Result<0) do
  begin
    curPage:=PageControl1.Pages[i];
    if curPage.Controls[0] is TForm then
    begin
      if curPage.Controls[0] = AForm then
      begin
        Result:=i;  // find it
        break;
      end;
    end;
    // only if is possible to put another form inside other
    {for j:=0 to Pred(curPage.ControlCount) do
    begin
      if curPage.Controls[j] is TForm then
      begin
        if curPage.Controls[j] = AForm then
        begin
          Result:=i;  // find it
          break;
        end;
      end;
    end;
    }
    Inc(i);
  end;
end;

end.

