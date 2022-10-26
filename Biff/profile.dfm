object FormProfile: TFormProfile
  Left = 210
  Top = 152
  BorderStyle = bsDialog
  Caption = 'Choose Profile'
  ClientHeight = 153
  ClientWidth = 260
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonNewUser: TButton
    Left = 64
    Top = 24
    Width = 137
    Height = 33
    Caption = 'New User'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ModalResult = 6
    ParentFont = False
    TabOrder = 0
  end
  object ButtonLogin: TButton
    Left = 64
    Top = 88
    Width = 137
    Height = 33
    Caption = 'Login'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ModalResult = 1
    ParentFont = False
    TabOrder = 1
    OnClick = ButtonLoginClick
  end
end
