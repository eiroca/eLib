object eLineReportPreview: TeLineReportPreview
  Left = 200
  Top = 99
  Caption = 'eLineReportPreview'
  ClientHeight = 416
  ClientWidth = 492
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
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnCmnd: TPanel
    Left = 0
    Top = 0
    Width = 492
    Height = 33
    Align = alTop
    TabOrder = 0
    object btZoomIn: TSpeedButton
      Left = 110
      Top = 5
      Width = 25
      Height = 23
      Hint = 
        'Aumenta il livello di zoom ingrandendo '#13#10'la dimensione dei carat' +
        'teri'
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000130B0000130B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        33033333333333333F7F3333333333333000333333333333F777333333333333
        000333333333333F777333333333333000333333333333F77733333333333300
        033333333FFF3F777333333700073B703333333F7773F77733333307777700B3
        33333377333777733333307F8F8F7033333337F333F337F3333377F8F9F8F773
        3333373337F3373F3333078F898F870333337F33F7FFF37F333307F99999F703
        33337F377777337F3333078F898F8703333373F337F33373333377F8F9F8F773
        333337F3373337F33333307F8F8F70333333373FF333F7333333330777770333
        333333773FF77333333333370007333333333333777333333333}
      NumGlyphs = 2
      ParentShowHint = False
      ShowHint = True
      OnClick = btZoomClick
    end
    object btZoomOut: TSpeedButton
      Left = 135
      Top = 5
      Width = 25
      Height = 23
      Hint = 
        'Diminuisce il livello di zoom riducendo '#13#10'la dimensione dei cara' +
        'tteri'
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000130B0000130B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        33033333333333333F7F3333333333333000333333333333F777333333333333
        000333333333333F777333333333333000333333333333F77733333333333300
        033333333FFF3F777333333700073B703333333F7773F77733333307777700B3
        333333773337777333333078F8F87033333337F3333337F33333778F8F8F8773
        333337333333373F333307F8F8F8F70333337F33FFFFF37F3333078999998703
        33337F377777337F333307F8F8F8F703333373F3333333733333778F8F8F8773
        333337F3333337F333333078F8F870333333373FF333F7333333330777770333
        333333773FF77333333333370007333333333333777333333333}
      NumGlyphs = 2
      ParentShowHint = False
      ShowHint = True
      OnClick = btZoomClick
    end
    object lbSize: TLabel
      Left = 225
      Top = 10
      Width = 28
      Height = 13
      Caption = 'lbSize'
    end
    object btPrior: TSpeedButton
      Left = 30
      Top = 5
      Width = 25
      Height = 23
      Hint = 'Pagina precedente'
      Glyph.Data = {
        36010000424D360100000000000076000000280000001E0000000C0000000100
        040000000000C000000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777887777
        7887777778877777880077777008777700877777878777787800777700087770
        0087777877877787780077700008770000877787778778777800770000087000
        0087787777878777780070000008000000878777777877777800F000000F0000
        008F777777F777777800FF00000FF000008F777777F7777778007FF00008FF00
        0087FF77778FF777780077FF00087FF000877FF77787FF777800777FF00877FF
        008777FF77877FF778007777FFF7777FFF77777FFF7777FFF700}
      NumGlyphs = 2
      ParentShowHint = False
      ShowHint = True
      OnClick = btMoveClick
    end
    object btNext: TSpeedButton
      Left = 55
      Top = 5
      Width = 25
      Height = 23
      Hint = 'Prossima pagina'
      Glyph.Data = {
        36010000424D360100000000000076000000280000001E0000000C0000000100
        040000000000C000000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00788777778877
        77778877777887777700F008777F0087777F778777F778777700F000877F0008
        777F777877F777877700F000087F0000877F777787F777787700F000008F0000
        087F777778F777778700F00000080000008F7777778777777800F000000F0000
        007F777778F777778700F000007F0000077F777787F777787700F000077F0000
        777F777877F777877700F000777F0007777F778777F778777700F007777F0077
        777F787777F787777700FF77777FF777777FF77777FF77777700}
      NumGlyphs = 2
      ParentShowHint = False
      ShowHint = True
      OnClick = btMoveClick
    end
    object btLast: TSpeedButton
      Left = 80
      Top = 5
      Width = 25
      Height = 23
      Hint = 'Va all'#39'ultima pagina'
      Glyph.Data = {
        36010000424D360100000000000076000000280000001E0000000C0000000100
        040000000000C000000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00778877777888
        877778877777788887007F008777F0008777F7787777F77787007F000877F000
        8777F7778777F77787007F000087F0008777F7777877F77787007F000008F000
        8777F7777787F77787007F00000080008777F7777778F77787007F000000F000
        8777F7777787F77787007F000007F0008777F7777877F77787007F000077F000
        8777F7778777F77787007F000777F0008777F7787777F77787007F007777F000
        8777F7877777F77787007FF77777FFFF7777FF777777FFFF7700}
      NumGlyphs = 2
      ParentShowHint = False
      ShowHint = True
      OnClick = btLastClick
    end
    object btFirst: TSpeedButton
      Left = 5
      Top = 5
      Width = 25
      Height = 23
      Hint = 'Va alla prima pagina'
      Glyph.Data = {
        36010000424D360100000000000076000000280000001E0000000C0000000100
        040000000000C000000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777888777777
        887777888777777887007F00087777700877F7778777778787007F0008777700
        0877F7778777787787007F00087770000877F7778777877787007F0008770000
        0877F7778778777787007F00087000000877F7778787777787007F0008F00000
        0877F7778F77777787007F0008FF00000877F7778F77777787007F00087FF000
        0877F77787FF777787007F000877FF000877F777877FF77787007F0008777FF0
        0877F7778777FF7787007FFFF77777FFF777FFFF77777FFF7700}
      NumGlyphs = 2
      ParentShowHint = False
      ShowHint = True
      OnClick = btFirstClick
    end
    object lbPag: TLabel
      Left = 170
      Top = 10
      Width = 49
      Height = 14
      Hint = 'Indicatore della posizione'#13#10'della pagina'
      Caption = '###/###'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
    end
  end
  object dgOutput: TDrawGrid
    Left = 0
    Top = 33
    Width = 492
    Height = 228
    Align = alTop
    ColCount = 1
    DefaultColWidth = 1000
    DefaultRowHeight = 20
    FixedCols = 0
    FixedRows = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    Options = []
    ParentFont = False
    TabOrder = 1
    OnDrawCell = dgOutputDrawCell
  end
end
