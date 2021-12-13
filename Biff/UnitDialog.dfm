object FormDialog: TFormDialog
  Left = 609
  Top = 158
  BorderStyle = bsDialog
  Caption = 'Fill Table'
  ClientHeight = 395
  ClientWidth = 211
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label4: TLabel
    Left = 16
    Top = 128
    Width = 105
    Height = 13
    Caption = 'Number of Simulations'
  end
  object Label6: TLabel
    Left = 16
    Top = 160
    Width = 75
    Height = 13
    Caption = 'Risk of Ruin (%)'
  end
  object Label7: TLabel
    Left = 40
    Top = 288
    Width = 51
    Height = 13
    Caption = 'Total Days'
  end
  object Label8: TLabel
    Left = 104
    Top = 288
    Width = 49
    Height = 13
    Caption = 'Step Days'
  end
  object ButtonOk: TButton
    Left = 24
    Top = 360
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object ButtonCancel: TButton
    Left = 112
    Top = 360
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object EditSims: TEdit
    Left = 136
    Top = 128
    Width = 65
    Height = 21
    TabOrder = 2
    Text = '20000'
  end
  object EditMyBankr: TEdit
    Left = 136
    Top = 160
    Width = 65
    Height = 21
    TabOrder = 3
    Text = '10'
  end
  object CheckBoxBankruptcy: TCheckBox
    Left = 16
    Top = 192
    Width = 121
    Height = 17
    Caption = 'UPRO Daily Fail  1 / '
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object EditUPROBankr: TEdit
    Left = 144
    Top = 192
    Width = 57
    Height = 21
    TabOrder = 5
    Text = '50000'
  end
  object CheckBoxAdv: TCheckBox
    Left = 120
    Top = 336
    Width = 73
    Height = 17
    Caption = 'Advanced'
    Checked = True
    State = cbChecked
    TabOrder = 6
    Visible = False
  end
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 193
    Height = 81
    TabOrder = 7
    object Label1: TLabel
      Left = 24
      Top = 8
      Width = 144
      Height = 13
      Caption = 'Carefully check all parameters.'
    end
    object Label5: TLabel
      Left = 40
      Top = 32
      Width = 117
      Height = 13
      Caption = 'It may spend a lot of time'
    end
    object Label2: TLabel
      Left = 42
      Top = 52
      Width = 103
      Height = 13
      Caption = ' to calculate full table.'
    end
  end
  object EditTotalDay: TEdit
    Left = 40
    Top = 304
    Width = 49
    Height = 21
    TabOrder = 8
    Text = '5000'
  end
  object EditStepDay: TEdit
    Left = 104
    Top = 304
    Width = 49
    Height = 21
    TabOrder = 9
    Text = '1000'
  end
  object CheckBoxInflation: TCheckBox
    Left = 56
    Top = 336
    Width = 65
    Height = 17
    Caption = 'Inflation'
    TabOrder = 10
  end
  object RadioGroupBiff: TRadioGroup
    Left = 16
    Top = 224
    Width = 185
    Height = 49
    Caption = 'Biff'
    Columns = 4
    ItemIndex = 0
    Items.Strings = (
      '1.0'
      '1.5'
      '2.0'
      '3.0')
    TabOrder = 11
  end
end
