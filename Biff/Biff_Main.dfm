object Form1: TForm1
  Left = 422
  Top = 130
  Width = 893
  Height = 667
  Caption = 'Biff v.3.01'
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
  object Memo1: TMemo
    Left = 432
    Top = 8
    Width = 441
    Height = 569
    ScrollBars = ssBoth
    TabOrder = 0
    OnKeyPress = Memo1KeyPress
  end
  object EditCapital: TEdit
    Left = 136
    Top = 24
    Width = 65
    Height = 21
    TabOrder = 1
    Text = '4000'
    OnKeyPress = NumericEditKeyPress
  end
  object Editrasxod: TEdit
    Left = 136
    Top = 56
    Width = 65
    Height = 21
    TabOrder = 2
    Text = '1'
    OnKeyPress = NumericEditKeyPress
  end
  object EditDays: TEdit
    Left = 136
    Top = 96
    Width = 65
    Height = 21
    TabOrder = 3
    Text = '2000'
    OnKeyPress = NumericEditKeyPress
  end
  object EditSims: TEdit
    Left = 136
    Top = 128
    Width = 65
    Height = 21
    TabOrder = 4
    Text = '20000'
    OnKeyPress = NumericEditKeyPress
  end
  object ButtonClearMemo: TButton
    Left = 136
    Top = 568
    Width = 65
    Height = 25
    Caption = 'Clear Memo'
    TabOrder = 5
    OnClick = ButtonClearMemoClick
  end
  object EditUPROPer: TEdit
    Left = 64
    Top = 304
    Width = 49
    Height = 21
    TabOrder = 6
    Text = '100'
    OnKeyPress = FloatEditKeyPress
  end
  object ButtonUPRO: TButton
    Left = 128
    Top = 304
    Width = 83
    Height = 25
    Caption = 'Calculate EV'
    TabOrder = 7
    OnClick = ButtonUPROClick
  end
  object CheckBoxBankruptcy: TCheckBox
    Left = 16
    Top = 200
    Width = 121
    Height = 17
    Caption = 'UPRO Daily Fail  1 / '
    Checked = True
    State = cbChecked
    TabOrder = 8
  end
  object EditMyBankr: TEdit
    Left = 136
    Top = 168
    Width = 65
    Height = 21
    TabOrder = 9
    Text = '10'
    OnKeyPress = FloatEditKeyPress
  end
  object EditUPROBankr: TEdit
    Left = 144
    Top = 200
    Width = 57
    Height = 21
    TabOrder = 10
    Text = '50000'
    OnKeyPress = NumericEditKeyPress
  end
  object ButtonBestRatio: TButton
    Left = 16
    Top = 344
    Width = 185
    Height = 25
    Caption = 'Find Best Ratio ( VOO / UPRO )'
    TabOrder = 11
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
    TabOrder = 13
  end
  object ProgressBar: TProgressBar
    Left = 432
    Top = 576
    Width = 441
    Height = 17
    Max = 1000
    TabOrder = 14
  end
  object ButtonStopFillTable: TButton
    Left = 16
    Top = 504
    Width = 185
    Height = 25
    Caption = 'Abort Fill Table Process'
    TabOrder = 15
  end
end
