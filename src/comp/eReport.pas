(* GPL > 3.0
Copyright (C) 1996-2019 eIrOcA Enrico Croce & Simona Burzio

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*)
(*
 @author(Enrico Croce)
*)
unit eReport;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  eComp;

resourcestring
  errNotInDoc = 'Document not began';
  errInDoc    = 'Document already began';
  errBadDev   = 'Invalid device';
  errBadDevSet= 'Unable to setup device';
  errSetProp  = 'Unable to change property file during printing';
  msgNoDevice = '<<no device>>';

type
  TReportField   = class;
  TReportLine    = class;
  TeLineReport = class;
  TOutputDevice  = class;

  TOutputDeviceClass = class of TOutputDevice;

  TReportNotify = procedure (Rep: TeLineReport) of object;
  TSetupDeviceNotify = procedure (Rep: TeLineReport; Dev: TOutputDevice) of object;

  EDeviceError = class(exception);
  EDeviceAbortedError = class(EDeviceError);

  TOutputDevice = class
    private
     InDoc: boolean;
     FReport: TeLineReport;
    public
     constructor Create(AReport: TeLineReport); virtual;
     procedure   BeginDoc; virtual;
     procedure   NewPage; virtual;
     procedure   EndDoc; virtual;
     procedure   AbortDoc; virtual;
     procedure   Write(const Str: string); virtual;
     procedure   WriteLn(const Str: string); virtual;
     destructor  Destroy; override;
     property Report: TeLineReport read FReport;
  end;

  TOutputTextFile = class(TOutputDevice)
    private
     OutFile: TextFile;
     FFileName: string;
     FAppend  : boolean;
    protected
     procedure SetFileName(vl: string);
    public
     constructor Create(AReport: TeLineReport); override;
     procedure   BeginDoc; override;
     procedure   EndDoc; override;
     procedure   AbortDoc; override;
     procedure   Write(const Str: string); override;
     procedure   WriteLn(const Str: string); override;
    public
     property FileName: string read FFileName write SetFileName;
     property Append: boolean read FAppend write FAppend;
  end;

  TOutputHTMLFile = class(TOutputTextFile)
    public
     procedure   BeginDoc; override;
     procedure   EndDoc; override;
  end;

  TOutputStrings = class(TOutputDevice)
    private
     FPages: TList;
     FFreeOnAbort: boolean;
     CurPag: TStrings;
     CurPos: integer;
     procedure FreePages;
     function  MakePage: TStrings;
    protected
     function GetPage(i: integer): TStrings;
     function GetPageCount: integer;
    public
     constructor Create(AReport: TeLineReport); override;
     procedure   BeginDoc; override;
     procedure   NewPage; override;
     procedure   EndDoc; override;
     procedure   AbortDoc; override;
     procedure   Write(const Str: string); override;
     procedure   WriteLn(const Str: string); override;
     destructor  Destroy; override;
    public
     property    Page[i: integer]: TStrings read GetPage;
     property    PageCount: integer read GetPageCount;
     property    FreeOnAbort: boolean read FFreeOnAbort write FFreeOnAbort;
  end;

  TOutputPreview = class(TOutputStrings)
    public
     procedure   EndDoc; override;
  end;

  TOutputPrinter = class(TOutputDevice)
    private
      FPrinterIndex: integer;
      HasFont : boolean;
      FFont   : TFont;
      HasBrush: boolean;
      FBrush  : TBrush;
      HasPen  : boolean;
      FPen    : TPen;
      CurRow  : integer;
      OldPrnt : integer;
      PageHeight: integer;
      PageWidth : integer;
      FOffTop   : integer;
      FOffBottom: integer;
      FOffLeft  : integer;
      FOffRight : integer;
    protected
      procedure ResetPrinter;
      procedure SetPrinter(vl: integer);
      procedure SetFont(vl: TFont);
      procedure SetBrush(vl: TBrush);
      procedure SetPen(vl: TPen);
    public
     constructor Create(AReport: TeLineReport); override;
     procedure   GetPrinterStyle;
     procedure   BeginDoc; override;
     procedure   NewPage; override;
     procedure   EndDoc; override;
     procedure   AbortDoc; override;
     procedure   Write(const Str: string); override;
     procedure   WriteLn(const Str: string); override;
     destructor  Destroy; override;
    public
     property OffTop   : integer read FOffTop    write FOffTop;
     property OffBottom: integer read FOffBottom write FOffBottom;
     property OffLeft  : integer read FOffLeft   write FOffLeft;
     property OffRight : integer read FOffRight  write FOffRight;
     property PrinterIndex: integer read FPrinterIndex write SetPrinter;
     property Pen: TPen read FPen write SetPen;
     property Brush: TBrush read FBrush write SetBrush;
     property Font: TFont read FFont write SetFont;
  end;

  TReportField = class
    private
     FIndex : integer;
     FPos   : integer;
     FCurPos: integer;
     FSiz   : integer;
     FCurSiz: integer;
     FAli   : TAlignment;
     FCurAli: TAlignment;
     FValue : string;
     procedure   SetValue(const vl: string);
     procedure   SetFillValue(const vl: string);
    public
     constructor Create(APos, ASiz: integer; AAli: TAlignment);
     procedure   Assign(RF: TReportField);
     procedure   Setup(aPos, aSize: integer; aAlign: TAlignment);
     procedure   Prepare;
    public
     property    Index: integer    read FIndex;
     property    Pos  : integer    read FCurPos write FCurPos;
     property    Size : integer    read FCurSiz write FCurSiz;
     property    Align: TAlignment read FCurAli write FCurAli;
     property    Value: string     read FValue  write SetValue;
     property    Fill : string     write SetFillValue;
  end;

  TReportLine = class
    private
     Owner: TeLineReport;
     Line : string;
     CurPs: integer;
    public
     constructor Create(AOwner: TeLineReport);
     procedure   Tab(ps: integer);
     procedure   Write(const S: string);
     procedure   WriteR(const S: string);
     procedure   WriteC(const S: string);
     procedure   WriteField(ps, sz: integer; const vl: string; Al: TAlignment);
     procedure   Print;
     destructor  Destroy; override;
  end;

  TeLineReport = class(TComponent)
    private
     FReporting: boolean;
     FCurPag: integer;
     FCurRow: integer;
     FFirstPage: boolean;
     FLastPage : boolean;
     FAutoCR: boolean;
     FPageH : longint;
     FPageW : longint;
     FHeaderEnd: longint;
     FFooterBgn: longint;
     FRepName: string;
     FDevice: TOutputDevice;
     FDeviceIndex: integer;
     FOnHeader: TReportNotify;
     FOnFooter: TReportNotify;
     FOnPageHeader: TReportNotify;
     FOnPageFooter: TReportNotify;
     FOnNewPage: TReportNotify;
     FOnBeginReport: TReportNotify;
     FOnEndReport: TReportNotify;
     FOnAbortReport: TReportNotify;
     FOnSetupDevice: TSetupDeviceNotify;
     function  GetPageH: longint;
     procedure SetPageH(H: longint);
     procedure SetPageW(W: longint);
     function  GetHeaderSize: integer;
     procedure SetHeaderSize(HS: integer);
     procedure SetFooterSize(FS: integer);
     function  GetFooterSize: integer;
     function  GetDeviceKind: string;
     procedure SetDeviceKind(const Dev: string);
    public
     property Reporting: boolean read FReporting;
     property CurPag   : integer read FCurPag;
     property CurRow   : integer read FCurRow;
     property FirstPage: boolean read FFirstPage;
     property LastPage : boolean read FLastPage;
     property Device   : TOutputDevice read FDevice;
    published
     property AutoCR    : boolean read FAutoCR write FAutoCR;
     property PageHeight: longint read GetPageH write SetPageH;
     property PageWidth : longint read FPageW write SetPageW;
     property HeaderSize: integer read GetHeaderSize write SetHeaderSize;
     property FooterSize: integer read GetFooterSize write SetFooterSize;
     property ReportName: string  read FRepName write FRepName;
     property DeviceKind: string  read GetDeviceKind write SetDeviceKind;
    published
     property OnHeader     : TReportNotify read FOnHeader write FOnHeader;
     property OnFooter     : TReportNotify read FOnFooter write FOnFooter ;
     property OnPageHeader : TReportNotify read FOnPageHeader write FOnPageHeader;
     property OnPageFooter : TReportNotify read FOnPageFooter write FOnPageFooter;
     property OnNewPage    : TReportNotify read FOnNewPage write FOnNewPage;
     property OnBeginReport: TReportNotify read FOnBeginReport write FOnBeginReport;
     property OnEndReport  : TReportNotify read FOnEndReport write FOnEndReport;
     property OnAbortReport: TReportNotify read FOnAbortReport write FOnAbortReport;
     property OnSetupDevice: TSetupDeviceNotify read FOnSetupDevice write FOnSetupDevice;
    private
     FPagFot: boolean;
    private
     procedure   BeginPageFooter;
     procedure   EndPageFooter;
    protected
     procedure   NewPage; virtual;
     procedure   Header; virtual;
     procedure   PageHeader; virtual;
     procedure   PageFooter; virtual;
     procedure   Footer; virtual;
     procedure   SetupDevice; virtual;
    public
     constructor Create(AOwner: TComponent); override;
     procedure   SetupPage(aPageWidth, aPageHeight: longint);
     procedure   BeginReport;
     procedure   FormFeed;
     procedure   LineFeed;
     procedure   Reserve(Lines: integer);
     procedure   WriteLine(str: string);
     procedure   WritePattern(const str: string);
     function    PrepareLine: TReportLine;
     procedure   EndReport;
     procedure   AbortReport;
     destructor  Destroy; override;
  end;

  TeLineFields = class(TComponent)
    private
     FFields: TList;
     FReport: TeLineReport;
     function    GetField(Index: integer): TReportField;
     procedure   SetField(Index: integer; RF: TReportField);
    protected
     procedure   ReadFields(Reader: TReader);
     procedure   WriteFields(Writer: TWriter);
    public
     constructor Create(AOwner: TComponent); override;
     procedure   Prepare;
     function    FieldsCount: integer;
     function    AddField(aPos, aSize: integer; anAlign: TAlignment): integer;
     procedure   DeleteAllFields;
     procedure   DeleteField(i: integer);
     procedure   Print;
     procedure   Write(LR: TReportLine);
     procedure   DefineProperties(Filer: TFiler); override;
     destructor  Destroy; override;
    public
     property    Field[i: integer]: TReportField read GetField write SetField; default;
    published
     property    Report: TeLineReport read FReport write FReport;
  end;

procedure GetOutputDevices(DevList: TStrings);
function _getOutputDevices: TStrings;

procedure RegisterOutputDevice(const Name: string; Dev: TOutputDeviceClass);
procedure Register;

implementation

uses
  eReportPreview, Printers;

var
  OutputDevices: TStrings;

function _getOutputDevices: TStrings;
begin
    Result:= OutputDevices;
end;

constructor TOutputDevice.Create(AReport: TeLineReport);
begin
  InDoc:= false;
  FReport:= AReport;
end;

procedure TOutputDevice.BeginDoc;
begin
  if InDoc then raise EDeviceError.Create(errInDoc);
  InDoc:= true;
end;

procedure TOutputDevice.AbortDoc;
begin
  if not InDoc then raise EDeviceError.Create(errNotInDoc);
  InDoc:= false;
end;

procedure TOutputDevice.NewPage;
begin
  if not InDoc then raise EDeviceError.Create(errNotInDoc);
end;

procedure TOutputDevice.EndDoc;
begin
  if not InDoc then raise EDeviceError.Create(errNotInDoc);
  InDoc:= false;
end;

procedure TOutputDevice.Write(const Str: string);
begin
  if not InDoc then raise EDeviceError.Create(errNotInDoc);
end;

procedure TOutputDevice.WriteLn(const Str: string);
begin
  if not InDoc then raise EDeviceError.Create(errNotInDoc);
end;

destructor TOutputDevice.Destroy;
begin
  if InDoc then AbortDoc;
  inherited Destroy;
end;

constructor TOutputTextFile.Create(AReport: TeLineReport);
begin
  inherited Create(AReport);
  FFileName:= '';
  FAppend:= false;
end;

procedure TOutputTextFile.SetFileName(vl: string);
begin
  if InDoc then raise EDeviceError.Create(errSetProp);
  FFileName:= vl;
end;

procedure TOutputTextFile.BeginDoc;
begin
  inherited BeginDoc;
  AssignFile(OutFile, FFileName);
  if FAppend then begin
    try
      System.Append(OutFile);
    except
      Rewrite(OutFile);
    end;
  end
  else begin
    Rewrite(OutFile);
  end;
end;

procedure TOutputTextFile.EndDoc;
begin
  inherited EndDoc;
  CloseFile(OutFile);
end;

procedure TOutputTextFile.AbortDoc;
begin
  inherited AbortDoc;
  CloseFile(OutFile);
  DeleteFile(FFileName);
end;

procedure TOutputTextFile.Write(const Str: string);
begin
  inherited Write(Str);
  System.Write(OutFile, Str);
end;

procedure TOutputTextFile.WriteLn(const Str: string);
begin
  inherited WriteLn(Str);
  System.Writeln(OutFile, Str);
end;

procedure TOutputHTMLFile.BeginDoc;
begin
  inherited BeginDoc;
  System.writeln(OutFile,'<head><title>'+Report.ReportName+'</title></head><body><pre>');
end;

procedure TOutputHTMLFile.EndDoc;
begin
  inherited EndDoc;
  System.Append(OutFile);
  System.writeln(OutFile,'</pre></body>');
  CloseFile(OutFile);
end;

constructor TOutputStrings.Create(AReport: TeLineReport);
begin
  inherited Create(AReport);
  FPages:= TList.Create;
  FFreeOnAbort:= true;
  CurPag:= nil;
  CurPos:= -1;
end;

procedure TOutputStrings.FreePages;
var
  i: integer;
begin
  for i:= FPages.Count-1 downto 0 do begin
    TStrings(FPages[i]).Free;
    FPages.Delete(i);
  end;
  FPages.Pack;
end;

function TOutputStrings.MakePage: TStrings;
begin
  Result:= TStringList.Create;
  FPages.Add(Result);
end;

function TOutputStrings.GetPage(i: integer): TStrings;
begin
  Result:= TStrings(FPages[i]);
end;

function TOutputStrings.GetPageCount: integer;
begin
  Result:= FPages.Count;
end;

procedure TOutputStrings.BeginDoc;
begin
  inherited BeginDoc;
  FreePages;
  CurPos:= -1;
  CurPag:= MakePage; 
  CurPag.BeginUpdate;
end;

procedure TOutputStrings.NewPage;
begin
  inherited NewPage;
  CurPag.EndUpdate;
  CurPag:= MakePage;
  CurPag.BeginUpdate;
  CurPos:= -1;
end;

procedure TOutputStrings.EndDoc;
begin
  inherited EndDoc;
  CurPag.EndUpdate;
end;

procedure TOutputStrings.AbortDoc;
begin
  inherited AbortDoc;
  CurPag.EndUpdate;
  if FreeOnAbort then FreePages;
end;

procedure TOutputStrings.Write(const Str: string);
begin
  inherited Write(Str);
  if CurPos = -1 then CurPos:= CurPag.Add(Str)
  else CurPag[CurPos]:= Str;
end;

procedure TOutputStrings.WriteLn(const Str: string);
begin
  if CurPos = -1 then CurPos:= CurPag.Add(Str)
  else CurPag[CurPos]:= Str;
  CurPos:= -1;
end;

destructor TOutputStrings.Destroy;
begin
  FreePages;
  FPages.Free;
  inherited Destroy;
end;

procedure TOutputPreview.EndDoc;
begin
  inherited EndDoc;
  ShowReport(Self);
end;

constructor TOutputPrinter.Create(AReport: TeLineReport);
begin
  inherited Create(AReport);
  FPrinterIndex:= Printer.PrinterIndex;
  FPen:= TPen.Create;
  FBrush:= TBrush.Create;
  FFont:= TFont.Create;
  GetPrinterStyle;
end;

procedure TOutputPrinter.GetPrinterStyle;
begin
  if FPrinterIndex <> -1 then begin
    Printer.PrinterIndex:= FPrinterIndex;
    FPen.Assign(Printer.Canvas.Pen);
    FBrush.Assign(Printer.Canvas.Brush);
    FFont.Assign(Printer.Canvas.Font);
    HasPen:= true;
    HasBrush:= true;
    HasFont := true;
  end;
end;

procedure TOutputPrinter.SetPrinter(vl: integer);
begin
  if InDoc then raise EDeviceError.Create(errSetProp);
  FPrinterIndex:= vl;
end;

procedure TOutputPrinter.SetFont(vl: TFont);
begin
  if InDoc then raise EDeviceError.Create(errSetProp);
  if vl <> nil then begin
    FFont.Assign(vl);
    HasFont:= true;
  end
  else begin
    HasFont:= false;
  end;
end;

procedure TOutputPrinter.SetBrush(vl: TBrush);
begin
  if InDoc then raise EDeviceError.Create(errSetProp);
  if vl <> nil then begin
    FBrush.Assign(vl);
    HasBrush:= true;
  end
  else begin
    HasBrush:= false;
  end;
end;

procedure TOutputPrinter.SetPen(vl: TPen);
begin
  if InDoc then raise EDeviceError.Create(errSetProp);
  if vl <> nil then begin
    FPen.Assign(vl);
    HasPen:= true;
  end
  else begin
    HasPen:= false;
  end;
end;

procedure TOutputPrinter.BeginDoc;
begin
  inherited BeginDoc;
  OldPrnt:= Printer.PrinterIndex;
  Printer.PrinterIndex:= FPrinterIndex;
  Printer.Title:= FReport.ReportName;
  Printer.BeginDoc;
  ResetPrinter;
  PageHeight:= Printer.Canvas.cliprect.Bottom-Printer.Canvas.Cliprect.Top-OffTop-OffBottom;
  PageWidth := Printer.Canvas.cliprect.Right-Printer.Canvas.Cliprect.Left-OffLeft-OffRight;
end;

procedure TOutputPrinter.ResetPrinter;
begin
  if HasFont  then Printer.Canvas.Font.Assign(FFont);
  if HasPen   then Printer.Canvas.Pen.Assign(FPen);
  if HasBrush then Printer.Canvas.Brush.Assign(FBrush);
  CurRow:= 0;
end;

procedure TOutputPrinter.NewPage;
begin
  inherited NewPage;
  Printer.NewPage;
  ResetPrinter;
end;

procedure   TOutputPrinter.EndDoc;
begin
  inherited EndDoc;
  Printer.EndDoc;
  Printer.PrinterIndex:= OldPrnt;
end;

procedure   TOutputPrinter.AbortDoc;
begin
  inherited AbortDoc;
  Printer.Abort;
  Printer.PrinterIndex:= OldPrnt;
end;

procedure TOutputPrinter.Write(const Str: string);
var
  VPos: longint;
begin
  inherited Write(Str);
  with Printer do begin
    VPos:= Canvas.Cliprect.Top+OffTop+MulDiv(CurRow, PageHeight, Report.PageHeight);
    Canvas.TextOut(Canvas.ClipRect.Left+OffLeft, VPos, Str);
  end;
end;

procedure  TOutputPrinter.WriteLn(const Str: string);
begin
  inherited WriteLn(Str);
  Write(str);
  inc(CurRow);
end;

destructor TOutputPrinter.Destroy;
begin
  FPen:= TPen.Create;
  FBrush:= TBrush.Create;
  FFont:= TFont.Create;
  inherited Destroy;
end;

constructor TReportField.Create(APos, ASiz: integer; AAli: TAlignment);
begin
  inherited Create;
  FIndex := -1;
  Setup(aPos, Asiz, aAli);
end;

procedure TReportField.Setup(aPos, aSize: integer; aAlign: TAlignment);
begin
  FPos:= aPos;
  FSiz:= aSize;
  FAli:= aAlign;
  Prepare;
end;

procedure TReportField.Assign(RF: TReportField);
begin
  Pos:= RF.Pos;
  Size:= RF.Pos;
  Align:= RF.Align;
  Prepare;
end;


procedure TReportField.Prepare;
begin
  FCurPos:= FPos;
  FCurSiz:= FSiz;
  FCurAli:= FAli;
  FValue := '';
end;

procedure TReportField.SetValue(const vl: string);
begin
  FValue:= vl;
end;

procedure TReportField.SetFillValue(const vl: string);
var
  tmp: string;
begin
  tmp:= vl;
  while length(tmp) < Size do tmp:= tmp + vl;
  SetLength(tmp, Size);
  FValue:= tmp;
end;

constructor TReportLine.Create(AOwner: TeLineReport);
var i: integer;
begin
  CurPs:= 1;
  SetLength(Line, 200);
  for i:= 1 to length(Line) do Line[i]:= ' ';
  Owner:= AOwner;
end;

procedure TReportLine.Tab(ps: integer);
begin
  CurPs:= ps;
end;

procedure TReportLine.Write(const S: string);
var
  i: integer;
begin
  i:= 1;
  while (i<=length(s)) and (CurPs<=length(Line)) do begin
    Line[CurPs]:= s[i];
    inc(i);
    inc(CurPs);
  end;
end;

procedure TReportLine.WriteR(const S: string);
var
  ps, i: integer;
begin
  i:= length(s);
  ps:= CurPs;
  while (i>=1) and (ps>=1) do begin
    Line[ps]:= s[i];
    dec(i);
    dec(ps);
  end;
end;

procedure TReportLine.WriteC(const S: string);
var
  i: integer;
begin
  CurPs:= CurPs - length(s) div 2;
  if CurPs < 1 then begin
    i:= -CurPs+1;
    CurPs:= 1;
  end
  else begin
    i:= 1;
  end;
  while (i<=length(s)) and (CurPs<=length(Line)) do begin
    Line[CurPs]:= S[i];
    inc(i);
    inc(CurPs);
  end;
end;

procedure TReportLine.WriteField(ps, sz: integer; const vl: string; Al: TAlignment);
var
  tmp: string;
  i, j: integer;
begin
  SetLength(tmp, Sz);
  case al of
    taLeftJustify: begin
      for i:= 1 to Sz do begin
        if i<=length(vl) then tmp[i]:= vl[i]
        else tmp[i]:= ' ';
      end;
    end;
    taRightJustify: begin
      j:= Sz-length(vl);
      for i:= 1 to Sz do begin
        if i > j then tmp[i]:= vl[i-j]
        else tmp[i]:= ' ';
      end;
    end
    else begin
      j:= length(vl);
      if j >= Sz then tmp:= Copy(vl, 1, Sz)
      else begin
        j:= (Sz-j) div 2;
        for i:= 1 to Sz do begin
          if i <= j then tmp[i]:= ' '
          else if i <=j+length(vl) then tmp[i]:= vl[i-j]
          else tmp[i]:= ' ';
        end;
      end;
    end;
  end;
  Tab(ps); Write(tmp);
end;

procedure  TReportLine.Print;
begin
  Line:= TrimRight(Line);
  if Owner <> nil then Owner.WriteLine(Line);
  Free;
end;

destructor TReportLine.Destroy;
begin
  inherited Destroy;
end;

constructor TeLineReport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FReporting:= false;
  FDeviceIndex:= -1;
  FAutoCR:= false;
  FPageH:= 66;
  FPageW:= 132;
  FHeaderEnd:= 0;
  FFooterBgn:= FPageH;
  FCurPag:=  0;
  FCurRow:= -1;
  FOnHeader:= nil;
  FOnFooter:= nil;
  FOnPageHeader:= nil;
  FOnPageFooter:= nil;
  FOnNewPage:= nil;
  FOnBeginReport:= nil;
  FOnEndReport:= nil;
  FOnAbortReport:= nil;
  FOnSetupDevice:= nil;
  FDevice:= nil;
end;

function TeLineReport.GetPageH: longint;
begin
  Result:= FPageH;
  if Result=maxlongint then Result:= -1;
end;

procedure TeLineReport.SetPageH(H: longint);
var
  MinH: integer;
begin
  if H<0 then begin
    H:= maxlongint;
    FFooterBgn:= maxlongint-1;
  end
  else begin
    MinH:= HeaderSize + FooterSize + 1;
    if H < MinH then H:= MinH;
    FFooterBgn:= H -( FPageH-FFooterBgn);
  end;
  FPageH:= H;
end;

procedure TeLineReport.SetPageW(W: longint);
begin
  if W < 1 then W:= 1;
  FPageW:= W;
end;

procedure TeLineReport.SetHeaderSize(HS: integer);
var
  MaxHS: integer;
begin
  MaxHS:= PageHeight-FooterSize;
  if HS >MaxHS then HS:= MaxHS;
  FHeaderEnd:= HS;
end;

procedure TeLineReport.SetFooterSize(FS: integer);
var
  MaxFS: integer;
begin
  MaxFS:= PageHeight-HeaderSize;
  if FS > MaxFS then FS:= MaxFS;
  FFooterBgn:= FPageH-FS;
end;

function  TeLineReport.GetFooterSize: integer;
begin
  Result:= FPageH - FFooterBgn;
end;

function  TeLineReport.GetHeaderSize: integer;
begin
  Result:= FHeaderEnd;
end;

function  TeLineReport.GetDeviceKind: string;
begin
  if FDeviceIndex=-1 then begin
    if FReporting then raise EDeviceError.Create(errBadDev)
    else Result:= msgNoDevice;
  end
  else begin
    Result:= OutputDevices[FDeviceIndex];
  end;
end;

procedure TeLineReport.SetDeviceKind(const Dev: string);
begin
  if FReporting then raise EDeviceError.Create(errSetProp);
  FDeviceIndex:= OutputDevices.IndexOf(Dev);
end;

procedure TeLineReport.SetupPage(aPageWidth, aPageHeight: longint);
begin
  PageHeight:= aPageHeight;
  PageWidth := aPageWidth;
end;

procedure TeLineReport.FormFeed;
begin
  if PageHeight > 0 then begin
    if CurRow <= FFooterBgn then begin
      while (CurRow<=FFooterBgn) do LineFeed;
    end
    else begin
      while CurRow <= FPageH do LineFeed;
    end;
  end;
end;

procedure TeLineReport.LineFeed;
begin
  WriteLine('');
end;

procedure TeLineReport.NewPage;
begin
  inc(FCurPag);
  if not FirstPage then begin
    FDevice.NewPage;
  end
  else begin
    FFirstPage:= false;
  end;
  FCurRow:= 1;
  if Assigned(FOnNewPage) then FOnNewPage(Self);
  PageHeader;
end;

procedure TeLineReport.WriteLine(str: string);
begin
  if (CurRow > FFooterBgn) and (not FPagFot) then BeginPageFooter;
  if (CurRow = -1) or (CurRow > FPageH) then NewPage;
  if length(str) > FPageW then SetLength(Str, FPageW);
  if (length(str) = FPageW) and FAutoCR then FDevice.Write(Str)
  else FDevice.Writeln(Str);
  inc(FCurRow);
end;

procedure TeLineReport.Reserve(Lines: integer);
begin
  if (CurRow <= FFooterBgn) then begin
    if ((CurRow + Lines - 1) > FFooterBgn) then begin
      FormFeed;
    end;
  end;
end;

procedure TeLineReport.WritePattern(const str: string);
var
  tmp: string;
begin
  if length(str) = 0 then tmp:= ''
  else begin
    tmp:= str;
    while length(tmp) <= FPageW do tmp:= tmp + str;
    SetLength(tmp, FPageW);
  end;
  WriteLine(tmp);
end;

procedure TeLineReport.SetupDevice;
begin
  if FDeviceIndex=-1 then raise EDeviceError.Create(errBadDev);
  if FDevice<>nil then FDevice.Free;
  FDevice:= TOutputDeviceClass(OutputDevices.Objects[FDeviceIndex]).Create(Self);
  try
    if Assigned(FOnSetupDevice) then FOnSetupDevice(Self, FDevice);
  except
    on E: Exception do raise EDeviceAbortedError.Create(E.Message);
  end;
end;

procedure TeLineReport.BeginReport;
begin
  try
    SetupDevice;
  except
    on EDeviceError do raise;
    else raise EDeviceError.Create(errBadDevSet);
  end;
  FReporting:= true;
  FPagFot:= false;
  FCurPag:=  0;
  FCurRow:= -1; (* forza cambio pagina *)
  FFirstPage:= true;
  FLastPage:= false;
  FDevice.BeginDoc;
  Header;
  if Assigned(FOnBeginReport) then FOnBeginReport(Self);
end;

procedure TeLineReport.Header;
begin
  if Assigned(FOnHeader) then FOnHeader(Self);
end;

procedure TeLineReport.PageHeader;
begin
  if Assigned(FOnPageHeader) then FOnPageHeader(Self);
  while (CurRow <= FHeaderEnd) do LineFeed;
end;

function TeLineReport.PrepareLine: TReportLine;
begin
  PrepareLine:= TReportLine.Create(Self);
end;

procedure TeLineReport.BeginPageFooter;
begin
  FPagFot:= true;
  PageFooter;
end;

procedure TeLineReport.PageFooter;
begin
  if Assigned(FOnPageFooter) then FOnPageFooter(Self);
  FormFeed;
  EndPageFooter;
end;

procedure TeLineReport.EndPageFooter;
begin
  FPagFot:= false;
end;

procedure TeLineReport.Footer;
begin
  if Assigned(FOnFooter) then FOnFooter(Self);
  FLastPage:= true;
end;

procedure TeLineReport.EndReport;
begin
  Footer;
  if FFooterBgn < FPageH then begin
    while (CurRow<=FFooterBgn) and (PageHeight>0) do LineFeed;
    BeginPageFooter;
  end;
  FDevice.EndDoc;
  FReporting:= false;
  if Assigned(FOnEndReport) then FOnEndReport(Self);
  FDevice.Free;
  FDevice:= nil;
end;

procedure TeLineReport.AbortReport;
begin
  FDevice.AbortDoc;
  FReporting:= false;
  if Assigned(FOnAbortReport) then FOnAbortReport(Self);
  FDevice.Free;
  FDevice:= nil;
end;

destructor TeLineReport.Destroy;
begin
  if Reporting then EndReport;
  inherited Destroy;
end;

constructor TeLineFields.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FReport:= nil;
  FFields:= TList.Create;
end;

function    TeLineFields.GetField(Index: integer): TReportField;
begin
  Result:= TReportField(FFields[Index]);
end;

procedure   TeLineFields.SetField(Index: integer; RF: TReportField);
begin
  TReportField(FFields[Index]).Assign(RF);
end;

procedure   TeLineFields.Prepare;
var
  i: integer;
begin
  for i:= 0 to FFields.Count-1 do begin
    Field[i].Prepare;
  end;
end;

function TeLineFields.FieldsCount: integer;
begin
  Result:= FFields.Count;
end;

function TeLineFields.AddField(aPos, aSize: integer; anAlign: TAlignment): integer;
var
  RF: TReportField;
begin
  if FFields <> nil then begin
    RF:= TReportField.Create(aPos, aSize, anAlign);
    RF.FIndex:= FFields.Add(RF);
    Result:= RF.FIndex;
  end
  else Result:= -1;
end;

procedure   TeLineFields.DeleteField(i: integer);
begin
  Field[i].Free;
  FFields.Delete(i);
  FFields.Pack;
end;

procedure   TeLineFields.Print;
var
  LR: TReportLine; 
begin
  if Report <> nil then begin
    LR:= Report.PrepareLine;
    Write(LR);
    LR.Print;
    Prepare;
  end;
end;

procedure   TeLineFields.Write(LR: TReportLine);
var
  i: integer;
begin
  for i:= 0 to FFields.Count-1 do begin
    with LR, Field[i] do begin
      WriteField(Pos, Size, Value, Align);
    end;
  end;
end;

procedure TeLineFields.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('FieldDefs', ReadFields, WriteFields, true);
end;

procedure TeLineFields.ReadFields(Reader: TReader);
var
  Vers: longint;
  Ps, Sz, Al: integer;
begin
  Vers:= Reader.ReadInteger;
  if Vers <> $0120 then EReadError.Create('Invalid field definitions');
  Reader.ReadListBegin;
  DeleteAllFields;
  while not Reader.EndOfList do begin
    Ps:= Reader.ReadInteger;
    Sz:= Reader.ReadInteger;
    Al:= Reader.ReadInteger;
    AddField(Ps, Sz, TAlignment(Al));
  end;
  Reader.ReadListEnd;
end;

procedure TeLineFields.WriteFields(Writer: TWriter);
var
  i: integer;
begin
  Writer.WriteInteger($0120);
  Writer.WriteListBegin;
  for i:= 0 to FFields.Count-1 do begin
    with Field[i] do begin
      Writer.WriteInteger(Pos);
      Writer.WriteInteger(Size);
      Writer.WriteInteger(ord(Align));
    end;
  end;
  Writer.WriteListEnd;
end;

procedure TeLineFields.DeleteAllFields;
var
  i: integer;
begin
  if FFields <> nil then begin
    for i:= FFields.Count-1 downto 0 do begin
      TReportField(FFields[i]).Free;
      FFields.Delete(i);
    end;
  end;
end;

destructor  TeLineFields.Destroy;
begin
  DeleteAllFields;
  FFields.Free;
  inherited Destroy;
end;

procedure GetOutputDevices(DevList: TStrings);
begin
  DevList.BeginUpdate;
  try
    DevList.Clear;
    DevList.AddStrings(OutputDevices);
  finally
    DevList.EndUpdate;
  end;
end;

procedure RegisterOutputDevice(const Name: string; Dev: TOutputDeviceClass);
begin
  if OutputDevices.IndexOf(Name) = -1 then begin
    OutputDevices.AddObject(Name, pointer(Dev));
  end;
end;

procedure Register;
begin
  RegisterComponents(eCompPage, [TeLineReport]);
  RegisterComponents(eCompPage, [TeLineFields]);
end;

initialization
  OutputDevices:= TStringList.Create;
  RegisterOutputDevice('TextFile', TOutputTextFile);
  RegisterOutputDevice('HTML',     TOutputHTMLFile);
  RegisterOutputDevice('Strings',  TOutputStrings);
  RegisterOutputDevice('Printer',  TOutputPrinter);
  RegisterOutputDevice('Preview',  TOutputPreview);
finalization
  OutputDevices.Free;
end.

