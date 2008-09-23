object fmEditFieldDefs: TfmEditFieldDefs
  Left = 332
  Top = 177
  BorderStyle = bsDialog
  Caption = 'Edit Fields'
  ClientHeight = 168
  ClientWidth = 230
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  ShowHint = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 10
    Top = 5
    Width = 105
    Height = 14
    Caption = 'Pos. Size Align'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
  end
  object btUndo: TSpeedButton
    Left = 145
    Top = 138
    Width = 25
    Height = 25
    Hint = 'Undo changes'
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000130B0000130B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333FFFFF3333333333999993333333333F77777FFF333333999999999
      3333333777333777FF3333993333339993333377FF3333377FF3399993333339
      993337777FF3333377F3393999333333993337F777FF333337FF993399933333
      399377F3777FF333377F993339993333399377F33777FF33377F993333999333
      399377F333777FF3377F993333399933399377F3333777FF377F993333339993
      399377FF3333777FF7733993333339993933373FF3333777F7F3399933333399
      99333773FF3333777733339993333339933333773FFFFFF77333333999999999
      3333333777333777333333333999993333333333377777333333}
    NumGlyphs = 2
    OnClick = btUndoClick
  end
  object lbFld: TListBox
    Left = 5
    Top = 20
    Width = 136
    Height = 114
    Hint = 'Field'#39's list'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ItemHeight = 14
    ParentFont = False
    TabOrder = 0
    OnClick = lbFldClick
  end
  object btOk: TButton
    Left = 150
    Top = 5
    Width = 75
    Height = 25
    Hint = 'Confirm changes'
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 1
    OnClick = btOkClick
  end
  object btCancel: TButton
    Left = 150
    Top = 35
    Width = 75
    Height = 25
    Hint = 'Cancel changes'
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btAddFld: TButton
    Left = 150
    Top = 75
    Width = 75
    Height = 25
    Hint = 'Add new field'
    Caption = 'Add field'
    TabOrder = 3
    OnClick = btAddFldClick
  end
  object btDelFld: TButton
    Left = 150
    Top = 105
    Width = 75
    Height = 25
    Hint = 'Delete current field'
    Caption = 'Delete'
    TabOrder = 4
    OnClick = btDelFldClick
  end
  object iPos: TEdit
    Left = 5
    Top = 141
    Width = 33
    Height = 21
    Hint = 'New position'
    MaxLength = 4
    TabOrder = 5
    Text = '9999'
    OnKeyPress = iPosKeyPress
  end
  object iSiz: TEdit
    Left = 40
    Top = 141
    Width = 33
    Height = 21
    Hint = 'New size'
    MaxLength = 4
    TabOrder = 6
    Text = '9999'
    OnKeyPress = iPosKeyPress
  end
  object cbAlign: TComboBox
    Left = 75
    Top = 140
    Width = 66
    Height = 21
    Hint = 'New alignment'
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 7
    Items.Strings = (
      'left'
      'right'
      'center')
  end
end
