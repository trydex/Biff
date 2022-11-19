object FormNewUser: TFormNewUser
  Left = 386
  Top = 165
  Width = 729
  Height = 607
  Caption = 'New User'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 120
    Width = 48
    Height = 13
    Caption = 'Stocks ($)'
  end
  object Label2: TLabel
    Left = 16
    Top = 216
    Width = 102
    Height = 13
    Caption = 'Monthly Expences ($)'
  end
  object Label3: TLabel
    Left = 16
    Top = 256
    Width = 90
    Height = 13
    Caption = 'Business Days Left'
  end
  object Label4: TLabel
    Left = 16
    Top = 384
    Width = 105
    Height = 13
    Caption = 'Number of Simulations'
  end
  object Label6: TLabel
    Left = 16
    Top = 80
    Width = 132
    Height = 13
    Caption = 'Acceptable Risk of Ruin (%)'
  end
  object Label5: TLabel
    Left = 16
    Top = 16
    Width = 62
    Height = 13
    Caption = 'ScreenName'
  end
  object Label7: TLabel
    Left = 16
    Top = 48
    Width = 59
    Height = 13
    Caption = 'Date of Birth'
  end
  object Label8: TLabel
    Left = 16
    Top = 152
    Width = 37
    Height = 13
    Caption = 'Gold ($)'
  end
  object Label9: TLabel
    Left = 16
    Top = 184
    Width = 83
    Height = 13
    Caption = 'Total Bankroll  ($)'
  end
  object Label10: TLabel
    Left = 16
    Top = 288
    Width = 127
    Height = 13
    Caption = 'Business Days before Gold'
  end
  object EditStocks: TEdit
    Left = 160
    Top = 120
    Width = 65
    Height = 21
    TabOrder = 0
    Text = '6000'
    OnKeyPress = NumericEditKeyPress
  end
  object EditMonthlyExpences: TEdit
    Left = 160
    Top = 216
    Width = 65
    Height = 21
    TabOrder = 1
    Text = '20'
    OnKeyPress = FloatEditKeyPress
  end
  object EditBusinessDaysLeft: TEdit
    Left = 160
    Top = 256
    Width = 65
    Height = 21
    Enabled = False
    TabOrder = 2
    Text = '2000'
  end
  object EditNumSim: TEdit
    Left = 160
    Top = 384
    Width = 65
    Height = 21
    Enabled = False
    TabOrder = 3
    Text = '100000'
    OnKeyPress = NumericEditKeyPress
  end
  object EditTargetRisk: TEdit
    Left = 160
    Top = 80
    Width = 65
    Height = 21
    TabOrder = 4
    Text = '5'
    OnKeyPress = FloatEditKeyPress
  end
  object CheckBoxBankruptcy: TCheckBox
    Left = 16
    Top = 416
    Width = 121
    Height = 17
    Caption = 'UPRO Daily Fail  1 / '
    Checked = True
    Enabled = False
    State = cbChecked
    TabOrder = 5
  end
  object EditUPROBankr: TEdit
    Left = 160
    Top = 416
    Width = 65
    Height = 21
    Enabled = False
    TabOrder = 6
    Text = '50000'
    OnKeyPress = NumericEditKeyPress
  end
  object EditScreenName: TEdit
    Left = 160
    Top = 16
    Width = 89
    Height = 21
    TabOrder = 7
    Text = 'User1'
  end
  object ButtonAddNewUser: TButton
    Left = 32
    Top = 488
    Width = 185
    Height = 25
    Caption = 'Add New User'
    TabOrder = 8
    Visible = False
    OnClick = ButtonAddNewUserClick
  end
  object Memo1: TMemo
    Left = 264
    Top = -3
    Width = 441
    Height = 524
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 9
  end
  object DateTimePicker1: TDateTimePicker
    Left = 160
    Top = 48
    Width = 89
    Height = 25
    Date = 28055.057939571760000000
    Time = 28055.057939571760000000
    DateMode = dmUpDown
    TabOrder = 10
  end
  object EditGold: TEdit
    Left = 160
    Top = 152
    Width = 65
    Height = 21
    TabOrder = 11
    Text = '0'
    OnKeyPress = NumericEditKeyPress
  end
  object EditTotalBankroll: TEdit
    Left = 160
    Top = 184
    Width = 65
    Height = 21
    Enabled = False
    TabOrder = 12
    Text = '0'
  end
  object CheckBoxAdvanced: TCheckBox
    Left = 16
    Top = 352
    Width = 121
    Height = 17
    Caption = 'I am advanced user'
    TabOrder = 13
    OnClick = CheckBoxAdvancedClick
  end
  object ButtonCalcRisk: TButton
    Left = 32
    Top = 496
    Width = 185
    Height = 25
    Caption = 'Calculate Daily Risks'
    Enabled = False
    TabOrder = 14
    Visible = False
    OnClick = ButtonCalcRiskClick
  end
  object ButtonGoMainForm: TButton
    Left = 32
    Top = 504
    Width = 185
    Height = 25
    Caption = 'Go to Main Window'
    Enabled = False
    TabOrder = 15
    Visible = False
    OnClick = ButtonGoMainFormClick
  end
  object EditTodayDayLeft: TEdit
    Left = 160
    Top = 288
    Width = 65
    Height = 21
    Enabled = False
    TabOrder = 16
    Text = '2000'
  end
  object CheckBoxShowCalculating: TCheckBox
    Left = 408
    Top = 528
    Width = 153
    Height = 17
    Caption = 'Show calculating process'
    Checked = True
    State = cbChecked
    TabOrder = 17
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 550
    Width = 713
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Width = 80
      end
      item
        Width = 50
      end>
  end
  object ButtonAddUser: TButton
    Left = 32
    Top = 464
    Width = 185
    Height = 25
    Caption = 'Add New User'
    TabOrder = 19
    OnClick = ButtonAddUserClick
  end
  object Timer1: TTimer
    Left = 632
    Top = 24
  end
end
