(* TEicGauge Component
   Version 1.0
   (C) 1996, Glen Why. No rights reserved
   Modificato da Enrico Croce
*)
unit eGauge;

interface

uses
  SysUtils, Types, Classes, Windows, Messages, Controls, Graphics,
  eLibCore, eCompUtil;

type

  TeGauge = class(TCustomControl)
    private
     FMin  : integer;
     FMax  : integer;
     FLow  : integer;
     FHigh : integer;
     FValue: integer;
     FSeparator  : integer;
     FBlockHeight: integer;
     FGridWidth  : integer;
     FGridColor: TColor;
     FForeColor: TColor;
     FLowColor : TColor;
     FHighColor: TColor;
     FOnCHange : TNotifyEvent;
     FDrawGrid : boolean;
     procedure SetValue(V: integer);
     procedure SetSeparator(V: integer);
     procedure SetLow(V: integer);
     procedure SetHigh(V: integer);
     procedure SetMin(V: integer);
     procedure SetMax(V: integer);
     procedure SetForeColor(C: TColor);
     procedure SetLowColor(C: TColor);
     procedure SetHighColor(C: TColor);
     procedure SetGridColor(C: TColor);
     procedure SetBlockHeight(V: integer);
     procedure SetGridWidth(V: integer);
     procedure SetDrawGrid(V: boolean);
    protected
     procedure Change; virtual;
     procedure Paint; override;
    public
     constructor Create(anOwner: TComponent); override;
    published
     property BlockHeight: integer read FBlockHeight write SetBlockHeight;
     property Min: integer read FMin write SetMin;
     property Max: integer read FMax write SetMax;
     property Value: integer read FValue write SetValue;
     property Separator: integer read FSeparator write SetSeparator;
     property Low: integer read FLow write SetLow;
     property High: integer read FHigh write SetHigh;
     property ForeColor: TColor read FForeColor write SetForeColor;
     property LowColor: TColor read FLowColor write SetLowColor;
     property HighColor: TColor read FHighColor write SetHighColor;
     property GridColor: TColor read FGridColor write SetGridColor;
     property OnChange: TNotifyEvent read FOnCHange write FOnChange;
     property DrawGrid: boolean read FDrawGrid write SetDrawGrid;
     property GridWidth: integer read FGridWidth write SetGridWidth;
     property Color;
     property OnDblClick;
     property OnClick;
     property OnMouseMove;
     property OnMouseDown;
     property OnMouseUp;
  end;

procedure Register;

implementation

const
  DefGaugeWidth  =  50;
  DefGaugeHeight = 150;
  DefBlockHeight =  10;
  DefSeparator   =   1;
  DefGridWidth   =  10;

procedure RangeError;
begin
  raise ERangeError.CreateRes(SRangeError);
end;

constructor TeGauge.Create(anOwner: TComponent);
begin
  inherited Create(anOwner);
  Width:= DefGaugeWidth;
  Height:= DefGaugeHeight;
  FMin:= 0;
  FMax:= 100;
  FLow:= 10;
  FHigh:= 80;
  FValue:= 50;
  FForeColor:= clLime;
  FGridColor:= clLime;
  FHighColor:= clRed;
  FLowColor := clGreen;
  FBlockHeight:= DefBlockHeight;
  FSeparator:= DefSeparator;
  DrawGrid:= true;
  Color:= clBlack;
  GridWidth:= DefGridWidth;
end;

procedure TeGauge.SetValue(V: integer);
var
  R: TRect;
  C: integer;
begin
  if (csLoading in ComponentState) then FValue:= V
   else begin
     if (V > FMax) or (V < FMin) then RangeError;
     C:= round((height * (value - min)/(max - min)) / BlockHeight);
     if DrawGrid then R:= Rect(0, 0, ClientWidth - GridWidth, Height - C * BlockHeight)
     else R:= Rect(0, 0, ClientWidth, Height - C * BlockHeight);
     if C <> round((height * (v - min)/(max - min)) / BlockHeight) then
       InvalidateRect(Handle, @R, false);
     FValue:= V;
     Change;
   end;
end;

procedure TeGauge.SetSeparator(V: integer);
begin
  if (csLoading in ComponentState) then FSeparator:= V
  else begin
    if V > BlockHeight then v:= BlockHeight
    else if V < 0 then V:= 0;
    FSeparator:= V;
    Invalidate;
  end;
end;

procedure TeGauge.SetDrawGrid(V: boolean);
begin
  FDrawGrid:= V;
  if not (csLoading in ComponentState) then Invalidate;
end;

procedure TeGauge.SetLow(V: integer);
begin
  if (csLoading in ComponentState) then FLow:= V
  else begin
    if (V > FHigh) or (V < FMin) then RangeError;
    FLow:= V;
    Invalidate;
  end;
end;

procedure TeGauge.SetHigh(V: integer);
begin
  if (csLoading in ComponentState) then FHigh:= V
  else begin
    if (V < FLow) or (V > FMax) then RangeError;
    FHigh:= V;
    Invalidate;
  end;
end;

procedure TeGauge.SetMin(V: integer);
begin
  if (csLoading in ComponentState) then FMin:= V
  else begin
    if (V > FMax) or (FValue < V) then RangeError;
    FMin:= V;
    if (FLow < FMin) then FLow:= FMin;
    Invalidate;
  end;
end;

procedure TeGauge.SetMax(V: integer);
begin
  if (csLoading in ComponentState) then FMax:= V
  else begin
    if (V < FMin) or (FValue > V) then RangeError;
    FMax:= V;
    if (FHigh > FMax) then FHigh:= FMax;
    Invalidate;
  end;
end;

procedure TeGauge.SetForeColor(C: TColor);
begin
  FForeColor:= C;
  Invalidate;
end;

procedure TeGauge.SetLowColor(C: TColor);
begin
  FLowColor:= C;
  Invalidate;
end;

procedure TeGauge.SetHighColor(C: TColor);
begin
  FHighColor:= C;
  Invalidate;
end;

procedure TeGauge.SetGridColor(C: TColor);
begin
  FGridColor:= C;
  Invalidate;
end;

procedure TeGauge.SetBlockHeight(V: integer);
begin
  if (csLoading in ComponentState) then FBlockHeight:= V
  else begin
    if (V > ((FMax - FMin) div 4)) or (V <= 0) then RangeError;
    FBlockHeight:= V;
    Invalidate;
  end;
end;

procedure TeGauge.SetGridWidth(V: integer);
begin
  if (V < 3) then v:= 3;
  FGridWidth:= V;
  if not(csLoading in ComponentState) then Invalidate;
end;

procedure TeGauge.Change;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TeGauge.Paint;
var
  gw, h, w, c, b, t, g: integer;
  pp: array[0..3] of TPoint;
begin
  with Canvas do begin
    Brush.Color:= Color;
    FillRect(ClientRect);
    h:= ClientHeight;
    w:= ClientWidth;
    if DrawGrid then begin
      g:= w - GridWidth;
      gw:= GridWidth div 3;
      Pen.Color:= GridColor;
      pp[0]:= point(w, 0);
      pp[1]:= point(g + gw, 0);
      pp[2]:= point(g + gw, h - 1);
      pp[3]:= point(w, h - 1);
      PolyLine(pp);
      for t:= 1 to (h div BlockHeight) do begin
        b:= h - t * BlockHeight;
        MoveTo(g + gw, b);
        LineTo(w - gw, b);
      end;
    end
    else g:= w;
    c:= h - round((h * (value - min)/(max - min)) / BlockHeight) * BlockHeight;
    if (value > high) then begin
      t:= h - round((h * (high - min)/(max - min)) / BlockHeight) * BlockHeight;
      Brush.Color:= FHighColor;
      FillRect(rect(0, c, g, t));
    end
    else t:= c;
    if (value  > low) then begin
      b:= h - round((h * (low - min) / (max - min)) / BlockHeight) * BlockHeight;
      Brush.Color:= LowColor;
      FillRect(rect(0, b, g, h));
      Brush.Color:= ForeColor;
      FillRect(rect(0, t, g, b));
    end
    else begin
      b:= h;
      Brush.Color:= LowColor;
      FillRect(rect(0, t, g, b));
    end;
    if Separator > 0 then begin
      Brush.Color:= Color;
      b:= h;
      for t:= 1 to ((h - c) div BlockHeight) do begin
        dec(b, BlockHeight);
        FillRect(rect(0, b+Separator, g, b));
      end;
    end;
  end;
end;

procedure Register;
begin
  RegisterComponents(eCompPage, [TeGauge]);
end;

end.

