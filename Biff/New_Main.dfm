object Form3: TForm3
  Left = 345
  Top = 325
  Width = 809
  Height = 645
  Caption = 'Form3'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
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
  object Label6: TLabel
    Left = 16
    Top = 168
    Width = 75
    Height = 13
    Caption = 'Risk of Ruin (%)'
  end
  object ButtonBestRatio: TButton
    Left = 16
    Top = 344
    Width = 185
    Height = 25
    Caption = 'Find Best Ratio ( VOO / UPRO )'
    TabOrder = 0
    OnClick = ButtonBestRatioClick
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
  object EditMyBankr: TEdit
    Left = 136
    Top = 168
    Width = 65
    Height = 21
    TabOrder = 5
    Text = '10'
  end
  object CheckBoxBankruptcy: TCheckBox
    Left = 16
    Top = 200
    Width = 121
    Height = 17
    Caption = 'UPRO Daily Fail  1 / '
    Checked = True
    State = cbChecked
    TabOrder = 6
  end
  object EditUPROBankr: TEdit
    Left = 144
    Top = 200
    Width = 57
    Height = 21
    TabOrder = 7
    Text = '50000'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 588
    Width = 793
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
  object Memo1: TMemo
    Left = 349
    Top = 0
    Width = 441
    Height = 569
    ScrollBars = ssBoth
    TabOrder = 9
  end
  object ProgressBar: TProgressBar
    Left = 349
    Top = 528
    Width = 441
    Height = 17
    Max = 1000
    TabOrder = 10
  end
  object Button1: TButton
    Left = 40
    Top = 384
    Width = 75
    Height = 25
    Caption = 'Get Profiles'
    TabOrder = 11
    OnClick = Button1Click
  end
end
