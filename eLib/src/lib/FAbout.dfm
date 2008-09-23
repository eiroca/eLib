object fmAbout: TfmAbout
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'About'
  ClientHeight = 242
  ClientWidth = 364
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 348
    Height = 185
    Alignment = taCenter
    AutoSize = False
    Caption = 
      'Copyright (C) 1996-2008 eIrOcA Enrico Croce && Simona Burzio'#13#13'Th' +
      'is program is free software: you can redistribute it and/or modi' +
      'fy it under the terms of the GNU General Public License as publi' +
      'shed by the Free Software Foundation, either version 3 of the Li' +
      'cense, or (at your option) any later version.'#13#13'This program is d' +
      'istributed in the hope that it will be useful, but WITHOUT ANY W' +
      'ARRANTY; without even the implied warranty of MERCHANTABILITY or' +
      ' FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public L' +
      'icense for more details.'#13#13'You should have received a copy of the' +
      ' GNU General Public License along with this program.  If not, se' +
      'e <http://www.gnu.org/licenses/>.'
    WordWrap = True
  end
  object BitBtn1: TBitBtn
    Left = 147
    Top = 207
    Width = 70
    Height = 25
    TabOrder = 0
    Kind = bkOK
  end
end
