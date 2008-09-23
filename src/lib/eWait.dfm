object fmWait: TfmWait
  Left = 260
  Top = 166
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Wait....'
  ClientHeight = 78
  ClientWidth = 219
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDeactivate = FormDeactivate
  PixelsPerInch = 96
  TextHeight = 13
  object BitBtn1: TBitBtn
    Left = 75
    Top = 40
    Width = 75
    Height = 25
    TabOrder = 0
    OnClick = BitBtn1Click
    Kind = bkAbort
  end
  object PB: TProgressBar
    Left = 8
    Top = 8
    Width = 200
    Height = 17
    Smooth = True
    TabOrder = 1
  end
end
