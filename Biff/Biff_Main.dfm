object Form1: TForm1
  Left = 917
  Top = 137
  Width = 893
  Height = 667
  Caption = 'Biff v.3.03'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
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
  object Label6: TLabel
    Left = 16
    Top = 80
    Width = 132
    Height = 13
    Caption = 'Acceptable Risk of Ruin (%)'
  end
  object Label1: TLabel
    Left = 16
    Top = 120
    Width = 48
    Height = 13
    Caption = 'Stocks ($)'
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
  object Label10: TLabel
    Left = 16
    Top = 288
    Width = 78
    Height = 13
    Caption = 'Today Days Left'
  end
  object Label4: TLabel
    Left = 16
    Top = 384
    Width = 105
    Height = 13
    Caption = 'Number of Simulations'
  end
  object Memo1: TMemo
    Left = 432
    Top = 8
    Width = 441
    Height = 569
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    OnKeyPress = Memo1KeyPress
  end
  object ButtonClearMemo: TButton
    Left = 136
    Top = 568
    Width = 65
    Height = 25
    Caption = 'Clear Memo'
    TabOrder = 1
    OnClick = ButtonClearMemoClick
  end
  object ButtonBestRatio: TButton
    Left = 16
    Top = 480
    Width = 185
    Height = 25
    Caption = 'Find Best Ratio ( VOO / UPRO )'
    TabOrder = 2
    OnClick = ButtonBestRatioClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 610
    Width = 877
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
  object ProgressBar: TProgressBar
    Left = 432
    Top = 576
    Width = 441
    Height = 17
    Max = 1000
    TabOrder = 4
  end
  object ButtonStopFillTable: TButton
    Left = 16
    Top = 520
    Width = 185
    Height = 25
    Caption = 'Abort Fill Table Process'
    TabOrder = 5
  end
  object EditScreenName: TEdit
    Left = 152
    Top = 16
    Width = 89
    Height = 21
    TabOrder = 6
    Text = 'User1'
  end
  object DateTimePicker1: TDateTimePicker
    Left = 152
    Top = 48
    Width = 89
    Height = 25
    Date = 28055.057939571760000000
    Time = 28055.057939571760000000
    DateMode = dmUpDown
    TabOrder = 7
  end
  object EditTargetRisk: TEdit
    Left = 152
    Top = 80
    Width = 65
    Height = 21
    TabOrder = 8
    Text = '5'
    OnKeyPress = FloatEditKeyPress
  end
  object EditStocks: TEdit
    Left = 152
    Top = 120
    Width = 65
    Height = 21
    TabOrder = 9
    Text = '20000'
    OnKeyPress = NumericEditKeyPress
  end
  object EditGold: TEdit
    Left = 152
    Top = 152
    Width = 65
    Height = 21
    TabOrder = 10
    Text = '2000'
  end
  object EditTotalCapital: TEdit
    Left = 152
    Top = 184
    Width = 65
    Height = 21
    Enabled = False
    TabOrder = 11
    Text = '0'
  end
  object EditMonthlyExpences: TEdit
    Left = 152
    Top = 216
    Width = 65
    Height = 21
    TabOrder = 12
    Text = '20'
    OnKeyPress = FloatEditKeyPress
  end
  object EditBusinessDaysLeft: TEdit
    Left = 152
    Top = 256
    Width = 65
    Height = 21
    Enabled = False
    TabOrder = 13
    Text = '2000'
  end
  object EditTodayDayLeft: TEdit
    Left = 152
    Top = 288
    Width = 65
    Height = 21
    Enabled = False
    TabOrder = 14
    Text = '2000'
  end
  object CheckBoxAdvanced: TCheckBox
    Left = 16
    Top = 352
    Width = 121
    Height = 17
    Caption = 'I am advanced user'
    TabOrder = 15
  end
  object EditNumSim: TEdit
    Left = 152
    Top = 384
    Width = 65
    Height = 21
    Enabled = False
    TabOrder = 16
    Text = '25000'
    OnKeyPress = NumericEditKeyPress
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
    TabOrder = 17
  end
  object EditUPROBankr: TEdit
    Left = 152
    Top = 416
    Width = 65
    Height = 21
    Enabled = False
    TabOrder = 18
    Text = '50000'
    OnKeyPress = NumericEditKeyPress
  end
end
