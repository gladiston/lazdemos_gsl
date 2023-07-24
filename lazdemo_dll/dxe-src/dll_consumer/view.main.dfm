object fmPrincipal: TfmPrincipal
  Left = 0
  Top = 0
  Caption = 'fmPrincipal'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 400
    Width = 624
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    ExplicitLeft = 388
    ExplicitTop = 328
    ExplicitWidth = 185
    object Label1: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 112
      Height = 15
      Align = alClient
      Caption = '    Call DLL function...'
      Layout = tlCenter
    end
    object btnEcho: TButton
      AlignWithMargins = True
      Left = 501
      Top = 3
      Width = 120
      Height = 35
      Align = alRight
      Caption = 'Echo'
      TabOrder = 0
      OnClick = btnEchoClick
      ExplicitLeft = 484
    end
    object btnDLL_Proc: TButton
      AlignWithMargins = True
      Left = 249
      Top = 3
      Width = 120
      Height = 35
      Align = alRight
      Caption = 'Proc'
      TabOrder = 1
      OnClick = btnDLL_ProcClick
      ExplicitLeft = 484
    end
    object btnWhoAmI: TButton
      AlignWithMargins = True
      Left = 375
      Top = 3
      Width = 120
      Height = 35
      Align = alRight
      Caption = 'WhoAmI'
      TabOrder = 2
      OnClick = btnWhoAmIClick
      ExplicitLeft = 484
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 624
    Height = 400
    Align = alClient
    BorderStyle = bsNone
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
end
