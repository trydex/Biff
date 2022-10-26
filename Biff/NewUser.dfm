object FormNewUser: TFormNewUser
  Left = 188
  Top = 141
  Width = 797
  Height = 621
  Caption = 'New User'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 112
    Width = 48
    Height = 13
    Caption = 'Stocks ($)'
  end
  object Label2: TLabel
    Left = 16
    Top = 208
    Width = 102
    Height = 13
    Caption = 'Monthly Expences ($)'
  end
  object Label3: TLabel
    Left = 32
    Top = 248
    Width = 110
    Height = 13
    Caption = 'Investment Term (days)'
  end
  object Label4: TLabel
    Left = 16
    Top = 320
    Width = 105
    Height = 13
    Caption = 'Number of Simulations'
  end
  object Label6: TLabel
    Left = 16
    Top = 72
    Width = 132
    Height = 13
    Caption = 'Acceptable Risk of Ruin (%)'
  end
  object Label5: TLabel
    Left = 16
    Top = 8
    Width = 62
    Height = 13
    Caption = 'ScreenName'
  end
  object Label7: TLabel
    Left = 16
    Top = 40
    Width = 59
    Height = 13
    Caption = 'Date of Birth'
  end
  object Label8: TLabel
    Left = 16
    Top = 144
    Width = 37
    Height = 13
    Caption = 'Gold ($)'
  end
  object Label9: TLabel
    Left = 16
    Top = 176
    Width = 83
    Height = 13
    Caption = 'Total Bankroll  ($)'
  end
  object EditStocks: TEdit
    Left = 152
    Top = 112
    Width = 65
    Height = 21
    TabOrder = 0
    Text = '20000'
  end
  object EditMonthlyExpences: TEdit
    Left = 152
    Top = 208
    Width = 65
    Height = 21
    TabOrder = 1
    Text = '20'
  end
  object EditDaysLeft: TEdit
    Left = 152
    Top = 248
    Width = 65
    Height = 21
    TabOrder = 2
    Text = '2000'
  end
  object EditNumSim: TEdit
    Left = 152
    Top = 320
    Width = 65
    Height = 21
    Enabled = False
    TabOrder = 3
    Text = '25000'
  end
  object EditTargetRisk: TEdit
    Left = 152
    Top = 72
    Width = 65
    Height = 21
    TabOrder = 4
    Text = '5'
  end
  object CheckBoxBankruptcy: TCheckBox
    Left = 16
    Top = 352
    Width = 121
    Height = 17
    Caption = 'UPRO Daily Fail  1 / '
    Checked = True
    Enabled = False
    State = cbChecked
    TabOrder = 5
  end
  object EditUPROBankr: TEdit
    Left = 152
    Top = 352
    Width = 65
    Height = 21
    Enabled = False
    TabOrder = 6
    Text = '50000'
  end
  object EditScreenName: TEdit
    Left = 152
    Top = 8
    Width = 89
    Height = 21
    TabOrder = 7
    Text = 'User1'
  end
  object Button1: TButton
    Left = 16
    Top = 400
    Width = 75
    Height = 25
    Caption = 'Add Profile'
    TabOrder = 8
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 336
    Top = 5
    Width = 441
    Height = 569
    ScrollBars = ssBoth
    TabOrder = 9
  end
  object DateTimePicker1: TDateTimePicker
    Left = 152
    Top = 40
    Width = 89
    Height = 25
    Date = 28055.057939571760000000
    Time = 28055.057939571760000000
    DateMode = dmUpDown
    TabOrder = 10
  end
  object EditGold: TEdit
    Left = 152
    Top = 144
    Width = 65
    Height = 21
    TabOrder = 11
    Text = '2000'
  end
  object EditTotalCapital: TEdit
    Left = 152
    Top = 176
    Width = 65
    Height = 21
    Enabled = False
    TabOrder = 12
    Text = '0'
  end
  object CheckBoxAdvanced: TCheckBox
    Left = 16
    Top = 288
    Width = 121
    Height = 17
    Caption = 'I am advanced user'
    TabOrder = 13
    OnClick = CheckBoxAdvancedClick
  end
  object ButtonRefresh: TButton
    Left = 104
    Top = 400
    Width = 75
    Height = 25
    Caption = 'Refresh'
    TabOrder = 14
    OnClick = ButtonRefreshClick
  end
  object ButtoncalculateRisk: TButton
    Left = 24
    Top = 448
    Width = 185
    Height = 25
    Caption = 'Calculate Daily Risks'
    TabOrder = 15
    OnClick = ButtoncalculateRiskClick
  end
  object Button2: TButton
    Left = 72
    Top = 496
    Width = 75
    Height = 25
    Caption = 'Calculate EV'
    TabOrder = 16
    OnClick = Button2Click
  end
end
