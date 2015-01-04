(* GPL > 3.0
Copyright (C) 1996-2015 eIrOcA Enrico Croce & Simona Burzio

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
unit eReportPreview;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, StdCtrls, Buttons, ExtCtrls, eReport, eLibVCL;

const
  MinZoom =  0;
  MaxZoom = 11;
  ZoomSize: array[MinZoom..MaxZoom] of integer = (5, 6, 7, 8, 9, 10, 12, 14, 16, 20, 24, 30);

type
  TeLineReportPreview = class(TForm)
    pnCmnd: TPanel;
    dgOutput: TDrawGrid;
    btZoomIn: TSpeedButton;
    btZoomOut: TSpeedButton;
    lbSize: TLabel;
    btPrior: TSpeedButton;
    btNext: TSpeedButton;
    btLast: TSpeedButton;
    btFirst: TSpeedButton;
    lbPag: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btZoomClick(Sender: TObject);
    procedure dgOutputDrawCell(Sender: TObject; Col, Row: Longint;
      Rect: TRect; State: TGridDrawState);
    procedure btMoveClick(Sender: TObject);
    procedure btLastClick(Sender: TObject);
    procedure btFirstClick(Sender: TObject);
  private
    { Private declarations }
    procedure ShowPage(p: integer);
  public
    { Public declarations }
    Dev: TOutputStrings;
    CurPag: integer;
    Zoom: integer;
    function  ShowIt(aDev: TOutputStrings): TModalResult;
    procedure SetZoomLevel;
  end;

function ShowReport(Dev: TOutputStrings): TModalResult;

implementation

{$R *.DFM}

function ShowReport(Dev: TOutputStrings): TModalResult;
var
  fmEicLineReportPreview: TeLineReportPreview;
begin
  fmEicLineReportPreview:= TeLineReportPreview.Create(nil);
  try
    Result:= fmEicLineReportPreview.ShowIt(Dev);
  finally
    fmEicLineReportPreview.Free;
  end;
end;

procedure TeLineReportPreview.FormCreate(Sender: TObject);
begin
  Rescale(Self, 96);
  dgOutput.Align:= alClient;
  lbSize.Visible:= false;
  lbSize.Caption:= 'gfpQ9';
  lbSize.Font:= dgOutput.Font;
end;

function TeLineReportPreview.ShowIt(aDev: TOutputStrings): TModalResult;
begin
  Dev:= aDev;
  if Dev.PageCount=0 then begin
    MessageDlg('No Report to show', mtInformation, [mbOk], 0);
    Result:= mrCancel;
    exit;
  end;
  Caption:= 'Anteprima del report '+Dev.Report.ReportName;
  ShowPage(0);
  Zoom:= (MaxZoom+MinZoom) div 2;
  Result:= ShowModal;
end;

procedure TeLineReportPreview.ShowPage(p: integer);
  procedure SetEnabled(b: TSpeedButton; e: boolean);
  begin
    if b.Enabled <> e then b.Enabled:= e;
  end;
begin
  if P<0 then P:= 0;
  if P>=Dev.PageCount then P:= Dev.PageCount-1;
  CurPag:= P;
  lbPag.Caption:= Format('%d/%d', [CurPag+1, Dev.PageCount]);
  SetEnabled(btFirst, CurPag<>0);
  SetEnabled(btPrior, CurPag<>0);
  SetEnabled(btNext, CurPag<Dev.PageCount-1);
  SetEnabled(btLast, CurPag<Dev.PageCount-1);
  dgOutput.RowCount:= Dev.Page[P].Count;
  dgOutput.Invalidate;
end;

procedure TeLineReportPreview.FormShow(Sender: TObject);
begin
  SetZoomLevel;
end;

procedure TeLineReportPreview.btZoomClick(Sender: TObject);
begin
  if Sender = btZoomIn then inc(Zoom)
  else dec(Zoom);
  SetZoomLevel;
end;

procedure TeLineReportPreview.SetZoomLevel;
begin
  if Zoom >= MaxZoom then begin
    Zoom:= MaxZoom;
    btZoomIn.Enabled:= false;
  end
  else btZoomIn.Enabled:= true;
  if Zoom <= MinZoom then begin
    Zoom:= MinZoom;
    btZoomOut.Enabled:= false;
  end
  else btZoomOut.Enabled:= true;
  dgOutput.Font.Size:= ZoomSize[Zoom];
  lbSize.Font.Size:= dgOutput.Font.Size;
  dgOutput.DefaultRowHeight:= lbSize.Height+3;
end;

procedure TeLineReportPreview.dgOutputDrawCell(Sender: TObject; Col,
  Row: Longint; Rect: TRect; State: TGridDrawState);
var
  Str: string;
begin
  if (Row >= 0) and (Row < Dev.Page[CurPag].Count) then Str:= Dev.Page[CurPag][Row]
  else Str:= '';
  dgOutput.Canvas.TextRect(Rect, Rect.Left, Rect.Top, Str);
end;

procedure TeLineReportPreview.btMoveClick(Sender: TObject);
var
  sgn: integer;
begin
  if Sender=btNext then sgn:= 1
  else sgn:= -1;
  ShowPage(CurPag+sgn);
end;

procedure TeLineReportPreview.btLastClick(Sender: TObject);
begin
  ShowPage(Dev.PageCount-1);
end;

procedure TeLineReportPreview.btFirstClick(Sender: TObject);
begin
  ShowPage(0);
end;

end.

