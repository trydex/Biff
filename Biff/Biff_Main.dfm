object Form1: TForm1
  Left = 925
  Top = 129
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Biff v.3.19'
  ClientHeight = 638
  ClientWidth = 874
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
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
    Width = 63
    Height = 13
    Caption = 'Today'#39's Date'
  end
  object Label6: TLabel
    Left = 16
    Top = 80
    Width = 78
    Height = 13
    Caption = 'Today'#39's Risk (%)'
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
    Width = 127
    Height = 13
    Caption = 'Business Days before Gold'
  end
  object Label4: TLabel
    Left = 16
    Top = 384
    Width = 105
    Height = 13
    Caption = 'Number of Simulations'
  end
  object Label11: TLabel
    Left = 376
    Top = 312
    Width = 143
    Height = 16
    Caption = 'Today'#39's Volatility Group'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label12: TLabel
    Left = 376
    Top = 376
    Width = 140
    Height = 16
    Caption = 'Today'#39's UPRO percent'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Memo1: TMemo
    Left = 528
    Top = 8
    Width = 345
    Height = 569
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    OnKeyPress = Memo1KeyPress
  end
  object ButtonClearMemo: TButton
    Left = 768
    Top = 592
    Width = 73
    Height = 25
    Caption = 'Clear Memo'
    TabOrder = 1
    OnClick = ButtonClearMemoClick
  end
  object ButtonBestRatio: TButton
    Left = 32
    Top = 512
    Width = 185
    Height = 25
    Caption = 'Find Best Ratio ( UPRO / VOO )'
    TabOrder = 2
    OnClick = ButtonBestRatioClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 619
    Width = 874
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
  object ButtonStopFillTable: TButton
    Left = 528
    Top = 584
    Width = 185
    Height = 25
    Caption = 'Abort Fill Table Process'
    TabOrder = 4
    Visible = False
  end
  object EditScreenName: TEdit
    Left = 160
    Top = 16
    Width = 89
    Height = 21
    Enabled = False
    TabOrder = 5
    Text = 'User1'
  end
  object DateTimePicker1: TDateTimePicker
    Left = 160
    Top = 48
    Width = 89
    Height = 25
    Date = 28055.057939571760000000
    Time = 28055.057939571760000000
    DateMode = dmUpDown
    TabOrder = 6
  end
  object EditTodayRisk: TEdit
    Left = 160
    Top = 80
    Width = 65
    Height = 21
    Enabled = False
    TabOrder = 7
    Text = '5'
    OnKeyPress = FloatEditKeyPress
  end
  object EditStocks: TEdit
    Left = 160
    Top = 120
    Width = 65
    Height = 21
    TabOrder = 8
    Text = '20000'
    OnKeyPress = NumericEditKeyPress
  end
  object EditGold: TEdit
    Left = 160
    Top = 152
    Width = 65
    Height = 21
    TabOrder = 9
    Text = '2000'
    OnKeyPress = NumericEditKeyPress
  end
  object EditTotalBankroll: TEdit
    Left = 160
    Top = 184
    Width = 65
    Height = 21
    Enabled = False
    TabOrder = 10
    Text = '0'
  end
  object EditMonthlyExpences: TEdit
    Left = 160
    Top = 216
    Width = 65
    Height = 21
    TabOrder = 11
    Text = '20'
    OnKeyPress = FloatEditKeyPress
  end
  object EditBusinessDaysLeft: TEdit
    Left = 160
    Top = 256
    Width = 65
    Height = 21
    Enabled = False
    TabOrder = 12
    Text = '2000'
  end
  object EditTodayDayLeft: TEdit
    Left = 160
    Top = 288
    Width = 65
    Height = 21
    Enabled = False
    TabOrder = 13
    Text = '2000'
  end
  object CheckBoxAdvanced: TCheckBox
    Left = 16
    Top = 352
    Width = 121
    Height = 17
    Caption = 'I am advanced user'
    TabOrder = 14
    OnClick = CheckBoxAdvancedClick
  end
  object EditNumSim: TEdit
    Left = 160
    Top = 384
    Width = 65
    Height = 21
    Enabled = False
    TabOrder = 15
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
    TabOrder = 16
  end
  object EditUPROBankr: TEdit
    Left = 160
    Top = 416
    Width = 65
    Height = 21
    Enabled = False
    TabOrder = 17
    Text = '50000'
    OnKeyPress = NumericEditKeyPress
  end
  object ButtonRefreshParameter: TButton
    Left = 528
    Top = 600
    Width = 185
    Height = 25
    Caption = 'Refresh Parameters'
    TabOrder = 18
    Visible = False
    OnClick = ButtonRefreshParameterClick
  end
  object ButtonCalculateRisk: TButton
    Left = 32
    Top = 464
    Width = 185
    Height = 25
    Caption = 'Recalculate Daily Risks'
    TabOrder = 19
    OnClick = ButtonCalculateRiskClick
  end
  object ListBoxVolGroup: TListBox
    Left = 256
    Top = 312
    Width = 113
    Height = 305
    ItemHeight = 13
    Items.Strings = (
      ' 1: '
      ' 2:'
      ' 3:'
      ' 4:'
      ' 5:'
      ' 6:'
      ' 7:'
      ' 8:'
      ' 9:'
      '10:'
      '11:'
      '12:'
      '13:'
      '14:'
      '15:'
      '16:'
      '17:'
      '18:'
      '19:'
      '20:'
      '21:'
      '22:'
      '23:')
    TabOrder = 20
  end
  object ButtonCalculateEV: TButton
    Left = 32
    Top = 560
    Width = 185
    Height = 25
    Caption = 'Calculate EV'
    TabOrder = 21
    OnClick = ButtonCalculateEVClick
  end
  object Panel1: TPanel
    Left = 256
    Top = 8
    Width = 265
    Height = 289
    Caption = 'Panel1'
    TabOrder = 22
    object StringGrid1: TStringGrid
      Left = 0
      Top = 40
      Width = 320
      Height = 249
      DefaultColWidth = 55
      DefaultRowHeight = 16
      RowCount = 14
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing]
      TabOrder = 0
      OnExit = StringGrid1Exit
      OnGetEditText = StringGrid1GetEditText
      OnKeyPress = StringGrid1KeyPress
      OnSelectCell = StringGrid1SelectCell
      OnSetEditText = StringGrid1SetEditText
    end
    object DateTimePicker2: TDateTimePicker
      Left = 8
      Top = 8
      Width = 97
      Height = 25
      Date = 0.071291145832219630
      Time = 0.071291145832219630
      DateMode = dmUpDown
      TabOrder = 1
    end
    object EditSNP500: TEdit
      Left = 112
      Top = 8
      Width = 65
      Height = 21
      TabOrder = 2
      Text = '0'
      OnKeyPress = FloatEditKeyPress
    end
    object ButtonAddDay: TButton
      Left = 184
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Add SnP 500'
      TabOrder = 3
      OnClick = ButtonAddDayClick
    end
  end
  object EditTodayGroup: TEdit
    Left = 392
    Top = 336
    Width = 113
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 23
    Text = '0'
  end
  object EditTodayUPRO: TEdit
    Left = 392
    Top = 400
    Width = 113
    Height = 37
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    ReadOnly = True
    TabOrder = 24
    Text = '0'
  end
  object ButtonTodayUPRO: TButton
    Left = 376
    Top = 448
    Width = 145
    Height = 33
    Caption = 'Show Today'#39's UPRO Ratio'
    TabOrder = 25
    OnClick = ButtonTodayUPROClick
  end
  object BtnCredits: TButton
    Left = 848
    Top = 592
    Width = 25
    Height = 25
    Caption = '?'
    TabOrder = 26
    OnClick = BtnCreditsClick
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 808
    Top = 24
  end
end
