object Form1: TForm1
  Left = 56
  Top = 157
  BorderStyle = bsSingle
  Caption = 'Biff v.1.20'
  ClientHeight = 629
  ClientWidth = 674
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
  object Label1: TLabel
    Left = 16
    Top = 24
    Width = 74
    Height = 13
    Caption = 'Initial Money ($)'
  end
  object Label2: TLabel
    Left = 16
    Top = 56
    Width = 87
    Height = 13
    Caption = 'Daily Expenses ($)'
  end
  object Label3: TLabel
    Left = 16
    Top = 96
    Width = 110
    Height = 13
    Caption = 'Investment Term (days)'
  end
  object Label4: TLabel
    Left = 16
    Top = 128
    Width = 105
    Height = 13
    Caption = 'Number of Simulations'
  end
  object Label5: TLabel
    Left = 16
    Top = 304
    Width = 42
    Height = 13
    Caption = 'UPRO %'
  end
  object Label6: TLabel
    Left = 16
    Top = 168
    Width = 75
    Height = 13
    Caption = 'Risk of Ruin (%)'
  end
  object Label7: TLabel
    Left = 16
    Top = 456
    Width = 51
    Height = 13
    Caption = 'Total Days'
  end
  object Label8: TLabel
    Left = 72
    Top = 456
    Width = 49
    Height = 13
    Caption = 'Step Days'
  end
  object Memo1: TMemo
    Left = 224
    Top = 8
    Width = 441
    Height = 569
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object EditCapital: TEdit
    Left = 136
    Top = 24
    Width = 65
    Height = 21
    TabOrder = 1
    Text = '4000'
  end
  object Editrasxod: TEdit
    Left = 136
    Top = 56
    Width = 65
    Height = 21
    TabOrder = 2
    Text = '1'
  end
  object EditDays: TEdit
    Left = 136
    Top = 96
    Width = 65
    Height = 21
    TabOrder = 3
    Text = '2000'
  end
  object EditSims: TEdit
    Left = 136
    Top = 128
    Width = 65
    Height = 21
    TabOrder = 4
    Text = '20000'
  end
  object ButtonTest: TButton
    Left = 232
    Top = 528
    Width = 185
    Height = 25
    Caption = '100% VOO or 100% UPRO'
    TabOrder = 5
    Visible = False
    OnClick = ButtonTestClick
  end
  object ButtonClearMemo: TButton
    Left = 136
    Top = 568
    Width = 65
    Height = 25
    Caption = 'Clear Memo'
    TabOrder = 6
    OnClick = ButtonClearMemoClick
  end
  object EditUPROPer: TEdit
    Left = 64
    Top = 304
    Width = 49
    Height = 21
    TabOrder = 7
    Text = '100'
  end
  object ButtonUPRO: TButton
    Left = 120
    Top = 304
    Width = 83
    Height = 25
    Caption = 'Calculate EV'
    TabOrder = 8
    OnClick = ButtonUPROClick
  end
  object CheckBoxRebalance: TCheckBox
    Left = 232
    Top = 504
    Width = 153
    Height = 17
    Caption = 'Rebalance after +- %'
    TabOrder = 9
    Visible = False
  end
  object EditRePerc: TEdit
    Left = 392
    Top = 504
    Width = 33
    Height = 21
    TabOrder = 10
    Text = '2'
    Visible = False
  end
  object CheckBoxBankruptcy: TCheckBox
    Left = 16
    Top = 200
    Width = 121
    Height = 17
    Caption = 'UPRO Daily Fail  1 / '
    Checked = True
    State = cbChecked
    TabOrder = 11
  end
  object EditMyBankr: TEdit
    Left = 136
    Top = 168
    Width = 65
    Height = 21
    TabOrder = 12
    Text = '10'
  end
  object EditUPROBankr: TEdit
    Left = 144
    Top = 200
    Width = 57
    Height = 21
    TabOrder = 13
    Text = '50000'
  end
  object ButtonBestRatio: TButton
    Left = 16
    Top = 344
    Width = 185
    Height = 25
    Caption = 'Find Best Ratio ( VOO / UPRO )'
    TabOrder = 14
    OnClick = ButtonBestRatioClick
  end
  object ButtonFillRatio: TButton
    Left = 16
    Top = 416
    Width = 185
    Height = 25
    Caption = 'Fill One Row Table'
    TabOrder = 15
    OnClick = ButtonFillRatioClick
  end
  object EditTotalDay: TEdit
    Left = 16
    Top = 472
    Width = 41
    Height = 21
    TabOrder = 16
    Text = '5000'
  end
  object EditStepDay: TEdit
    Left = 72
    Top = 472
    Width = 49
    Height = 21
    TabOrder = 17
    Text = '1000'
  end
  object ButtonFillTable: TButton
    Left = 128
    Top = 472
    Width = 73
    Height = 25
    Caption = 'Fill Table'
    TabOrder = 18
    OnClick = ButtonFillTableClick
  end
  object CheckBoxAdv: TCheckBox
    Left = 240
    Top = 464
    Width = 73
    Height = 17
    Caption = 'Advanced'
    TabOrder = 19
    Visible = False
  end
  object CheckBoxInflation: TCheckBox
    Left = 16
    Top = 568
    Width = 113
    Height = 17
    Caption = 'Adjust for Inflation?'
    TabOrder = 20
    OnClick = CheckBoxInflationClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 610
    Width = 674
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
  object ButtonOpenTable: TButton
    Left = 16
    Top = 520
    Width = 89
    Height = 25
    Caption = 'Open Table'
    TabOrder = 22
    OnClick = ButtonOpenTableClick
  end
  object ButtonConvertTable: TButton
    Left = 112
    Top = 520
    Width = 89
    Height = 25
    Caption = 'Show Table'
    TabOrder = 23
    OnClick = ButtonConvertTableClick
  end
  object RadioGroupBiff: TRadioGroup
    Left = 16
    Top = 232
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
    TabOrder = 24
    OnClick = RadioGroupBiffClick
  end
  object ProgressBar: TProgressBar
    Left = 224
    Top = 576
    Width = 441
    Height = 17
    Max = 1000
    TabOrder = 25
  end
  object OpenDialog1: TOpenDialog
    Filter = 'table|*.biff'
    Left = 288
    Top = 16
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 248
    Top = 16
  end
end
