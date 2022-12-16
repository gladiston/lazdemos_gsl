object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
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
    Alignment = taLeftJustify
    Caption = '    Call DLL function...'
    TabOrder = 0
    ExplicitLeft = 228
    ExplicitTop = 220
    ExplicitWidth = 185
    object btnEcho: TBitBtn
      Left = 493
      Top = 1
      Width = 130
      Height = 39
      Align = alRight
      Caption = 'Echo'
      TabOrder = 0
      OnClick = btnEchoClick
      ExplicitLeft = 548
    end
    object btnMetodo: TBitBtn
      Left = 233
      Top = 1
      Width = 130
      Height = 39
      Align = alRight
      Caption = 'Proc'
      TabOrder = 1
      OnClick = btnMetodoClick
      ExplicitLeft = 288
    end
    object btnWhoAmI: TBitBtn
      Left = 363
      Top = 1
      Width = 130
      Height = 39
      Align = alRight
      Caption = 'WhoAmI'
      TabOrder = 2
      OnClick = btnWhoAmIClick
      ExplicitLeft = 418
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 624
    Height = 400
    Align = alClient
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
    ExplicitLeft = 118
    ExplicitTop = 124
    ExplicitWidth = 185
    ExplicitHeight = 89
  end
end
