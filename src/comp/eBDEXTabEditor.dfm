object XTabEditorDlg: TXTabEditorDlg
  Left = 163
  Top = 173
  BorderStyle = bsDialog
  Caption = 'cwXTab Property Editor'
  ClientHeight = 198
  ClientWidth = 617
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = [fsBold]
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 8
    Width = 513
    Height = 57
    Shape = bsFrame
  end
  object Label1: TLabel
    Left = 16
    Top = 40
    Width = 61
    Height = 13
    Caption = 'Row Field:'
  end
  object Label2: TLabel
    Left = 304
    Top = 40
    Width = 77
    Height = 13
    Caption = 'Column Field:'
  end
  object Bevel2: TBevel
    Left = 8
    Top = 72
    Width = 513
    Height = 121
    Shape = bsFrame
  end
  object Label3: TLabel
    Left = 16
    Top = 80
    Width = 92
    Height = 13
    Caption = 'Summary Fields:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold, fsUnderline]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 15
    Top = 116
    Width = 32
    Height = 13
    Caption = 'Field:'
  end
  object Label5: TLabel
    Left = 15
    Top = 139
    Width = 92
    Height = 13
    Caption = 'Math Operation:'
  end
  object Label6: TLabel
    Left = 15
    Top = 164
    Width = 88
    Height = 13
    Caption = 'Display Format:'
  end
  object Bevel3: TBevel
    Left = 112
    Top = 104
    Width = 129
    Height = 81
  end
  object Bevel4: TBevel
    Left = 248
    Top = 104
    Width = 129
    Height = 81
  end
  object Bevel5: TBevel
    Left = 384
    Top = 104
    Width = 129
    Height = 81
  end
  object Label7: TLabel
    Left = 16
    Top = 16
    Width = 89
    Height = 13
    Caption = 'Heading Fields:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold, fsUnderline]
    ParentFont = False
  end
  object comboRow: TComboBox
    Left = 120
    Top = 36
    Width = 113
    Height = 21
    Style = csDropDownList
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object comboCol: TComboBox
    Left = 392
    Top = 36
    Width = 113
    Height = 21
    Style = csDropDownList
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
  end
  object BitBtn1: TBitBtn
    Left = 526
    Top = 8
    Width = 86
    Height = 29
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 2
  end
  object BitBtn2: TBitBtn
    Left = 526
    Top = 42
    Width = 86
    Height = 31
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 3
  end
  object comboSum1: TComboBox
    Left = 120
    Top = 112
    Width = 113
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
  end
  object comboMathOp1: TComboBox
    Left = 120
    Top = 135
    Width = 113
    Height = 21
    Style = csDropDownList
    TabOrder = 5
    Items.Strings = (
      'sum'
      'avg'
      'min'
      'max'
      'count')
  end
  object comboFormat1: TComboBox
    Left = 120
    Top = 160
    Width = 113
    Height = 21
    Style = csDropDownList
    TabOrder = 6
    Items.Strings = (
      'currency'
      'integer'
      'real')
  end
  object comboSum2: TComboBox
    Left = 256
    Top = 112
    Width = 113
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 7
  end
  object comboMathOp2: TComboBox
    Left = 256
    Top = 135
    Width = 113
    Height = 21
    Style = csDropDownList
    TabOrder = 8
    Items.Strings = (
      'sum'
      'avg'
      'min'
      'max'
      'count')
  end
  object comboFormat2: TComboBox
    Left = 256
    Top = 160
    Width = 113
    Height = 21
    Style = csDropDownList
    TabOrder = 9
    Items.Strings = (
      'currency'
      'integer'
      'real')
  end
  object comboSum3: TComboBox
    Left = 392
    Top = 112
    Width = 113
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 10
  end
  object comboMathOp3: TComboBox
    Left = 392
    Top = 135
    Width = 113
    Height = 21
    Style = csDropDownList
    TabOrder = 11
    Items.Strings = (
      'sum'
      'avg'
      'min'
      'max'
      'count')
  end
  object comboFormat3: TComboBox
    Left = 392
    Top = 160
    Width = 113
    Height = 21
    Style = csDropDownList
    TabOrder = 12
    Items.Strings = (
      'currency'
      'integer'
      'real')
  end
end
