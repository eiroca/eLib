(* GPL > 3.0
Copyright (C) 1996-2008 eIrOcA Enrico Croce & Simona Burzio

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
unit eDataPick;

interface

uses
  SysUtils, Classes, eCompUtil;

type
  TData = array of double; (* dynamic allocated! *)

  TListener = class
    public
     Proc: TNotifyEvent;
    public
     constructor Create(aProc: TNotifyEvent);
  end;

  TListenerList = class
    private
     FListener: TList;
    public
     constructor Create;
     procedure   Add(aProc: TNotifyEvent);
     procedure   Del(aProc: TNotifyEvent);
     procedure   Notify(Sender: TObject);
     destructor  Destroy; override;
  end;

type
  TDataPickerClass = class of TDataPicker;

  TDataPicker = class(TComponent)
    private
     FChangeListener: TListenerList;
     FOnChange: TNotifyEvent;
     FDesc: string;
    protected
     function  GetDim: integer; virtual; abstract;
     function  GetCount: integer; virtual; abstract;
     function  GetPattern(i: integer): TData; virtual; abstract;
     procedure SetPattern(i: integer; const vl: TData); virtual; abstract;
    protected
     procedure   Change; virtual;
    public
     constructor Create(AOwner: TComponent); override;
     procedure   Setup(aDim: integer; aCount: integer); virtual; abstract;
     destructor  Destroy; override;
    public
     property Dim  : integer read GetDim;
     property Count: integer read GetCount;
     property Pattern[i: integer]: TData read GetPattern write SetPattern; default;
     property ChangeListener: TListenerList read FChangeListener;
    published
     property Desc : string read FDesc write FDesc;
     property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

type
  TDataList = class(TDataPicker)
    private
     FDim: integer;
     Data: array of TData;
     FRawMode: boolean;
     FullSave: boolean;
     procedure FreeData;
    protected
     function  GetDim: integer; override;
     function  GetCount: integer; override;
     procedure SetDim(vl: integer); virtual;
     procedure SetCount(vl: integer); virtual;
     function  GetPattern(i: integer): TData; override;
     procedure SetPattern(i: integer; const vl: TData); override;
     procedure DefineProperties(Filer: TFiler); override;
    public
     constructor Create(AOwner: TComponent); override;
     procedure   Setup(aDim: integer; aCount: integer); override;
     procedure   Assign(Source: TPersistent); override;
     procedure   SaveToFile(const OutPath: string);
     procedure   LoadFromFile(const InPath: string);
     procedure   SaveToStream(S: TStream); virtual;
     procedure   LoadFromStream(S: TStream); virtual;
     procedure   SaveToWriter(W: TWriter); virtual;
     procedure   LoadFromReader(R: TReader); virtual;
     procedure   Add(const Ptn: TData); virtual;
     procedure   Insert(i: integer; const Ptn: TData); virtual;
     procedure   Delete(i: integer); virtual;
     destructor  Destroy; override;
    published
     property Dim  : integer read GetDim write SetDim;
     property Count: integer read GetCount write SetCount;
     property RawMode: boolean read FRawMode write FRawMode default true;
  end;

type
  TPatternKind = (pkInput, pkOutput);

  TDataPattern = class(TDataList)
    private
     FPatternKind: TPatternKind;
     FPath: string;
     FAutoLoad: boolean;
     FNeedLoad: boolean;
     FLoadListener: TListenerList;
    protected
     procedure SetPatternKind(vl: TPatternKind);
     procedure SetPath(vl: string);
     procedure SetAutoLoad(vl: boolean);
    public
     constructor Create(AOwner: TComponent); override;
     procedure Loaded; override;
     procedure Load; virtual;
     destructor Destroy; override;
    public
     property LoadListener: TListenerList read FLoadListener;
    published
     property PatternKind: TPatternKind read FPatternKind write SetPatternKind;
     property FileName   : string read FPath write SetPath;
     property AutoLoad   : boolean read FAutoLoad write SetAutoLoad;
  end;

procedure LoadPattern(const Path: string; var iP, oP: TDataList);
function  FindPosMax(const p: TData): integer;

//Computes Sum of Error squares, and sqr(Max) component error
//@param N  Number of elements
//@param YC Estimated vector
//@param Y  Output vector
//@returns sum(YC-Y)^2
function  SumSqr(N: integer; const YC, Y: TData): double;

//Computes Sum of Error squares, and sqr(Max) component error
//@param Number of elements
//@param Estimated vector
//@param Output vector
//@param Sum of error squares
//@param Max squares erorr
procedure SumSqrMax(N: integer; const YC, Y: TData; var Sum, Max: double);


procedure Register;

implementation

constructor TListener.Create(aProc: TNotifyEvent);
begin
  Proc:= aProc;
end;

constructor TListenerList.Create;
begin
  inherited Create;
  FListener:= TList.Create;
end;

procedure TListenerList.Add(aProc: TNotifyEvent);
begin
  FListener.Add(TListener.Create(aProc));
end;

procedure TListenerList.Del(aProc: TNotifyEvent);
var
  i: integer;
begin
  with FListener do begin
    for i:= 0 to Count-1 do begin
      if (@TListener(Items[i]).Proc = @aProc) then begin
        Delete(i);
        Pack;
        break;
      end;
    end;
  end;
end;

procedure TListenerList.Notify(Sender: TObject);
var
  i: integer;
begin
  with FListener do begin
    for i:= 0 to Count-1 do begin
      TListener(Items[i]).Proc(Sender);
    end;
  end;
end;

destructor TListenerList.Destroy;
begin
  FListener.Free;
  inherited Destroy;
end;

constructor TDataPicker.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FChangeListener:= TListenerList.Create;
  Desc:= '';
end;

destructor  TDataPicker.Destroy;
begin
  FChangeListener.Free;
  inherited Destroy;
end;

procedure TDataPicker.Change;
begin
  ChangeListener.Notify(Self);
  if Assigned(FOnChange) then OnChange(Self);
end;

constructor TDataList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDim:= 0;
  setLength(Data, FDim);
  FRawMode:= true;
  FullSave:= true;
end;

function  TDataList.GetDim: integer;
begin
  Result:= FDim;
end;

procedure TDataList.SetDim(vl: integer);
var
  i: integer;
begin
  if vl <> FDim then begin
    for i:= Low(Data) to High(Data) do begin
      SetLength(Data[i], vl);
    end;
    FDim:= vl;
    Change;
  end;
end;

function  TDataList.GetCount: integer;
begin
  Result:= High(Data)-Low(data)+1;
end;

procedure TDataList.SetCount(vl: integer);
var
  i: integer;
  N: integer;
begin
  N:= GetCount;
  if (vl<>N) then begin
    SetLength(Data, vl);
    if vl > N then begin
      for i:= N to vl-1 do begin
        SetLength(Data[i], Dim);
      end;
    end;
    Change;
  end;
end;

function  TDataList.GetPattern(i: integer): TData;
begin
  Result:= Data[i];
end;

procedure TDataList.SetPattern(i: integer; const vl: TData);
begin
  Data[i]:= vl;
end;

procedure TDataList.SetUp(aDim: integer; aCount: integer);
begin
  Dim:= aDim;
  Count:= aCount;
end;

procedure TDataList.SaveToStream(S: TStream);
var
  i, j, tmp: integer;
begin
  if FullSave then begin
    tmp:= Count;
    S.Write(FDim, SizeOf(FDim));
    S.Write(tmp,  SizeOf(tmp));
    S.Write(FRawMode, SizeOf(FRawMode));
    tmp:= length(Desc);
    S.Write(tmp, SizeOf(tmp));
    S.Write(PChar(FDesc)^, tmp);
  end;
  if (Dim>0) and (Count>0) then begin
    for i:= 0 to Count-1 do begin
      for j:= 0 to Dim-1 do begin
        S.Write(Data[i][j], SizeOf(double));
      end;
    end;
  end;
end;

procedure TDataList.LoadFromStream(S: TStream);
var
  i, j, tmp: integer;
begin
  if FullSave then begin
    S.Read(tmp, SizeOf(tmp)); Dim:= tmp;
    S.Read(tmp, SizeOf(tmp)); Count:= tmp;
    S.Read(FRawMode, SizeOf(FRawMode));
    S.Read(tmp, SizeOf(tmp));
    SetString(FDesc, PChar(nil), tmp);
    S.Read(PChar(FDesc)^, tmp);
  end;
  if (Dim>0) and (Count>0) then begin
    for i:= 0 to Count-1 do begin
      for j:= 0 to Dim-1 do begin
        S.Read(Data[i][j], SizeOf(double));
      end;
    end;
  end;
end;

procedure TDataList.SaveToWriter(W: TWriter);
var
  i, j: integer;
begin
  if FullSave then begin
    W.WriteListBegin;
    W.WriteInteger(Dim);
    W.WriteInteger(Count);
    W.WriteBoolean(RawMode);
    W.WriteString(Desc);
  end;
  W.WriteListBegin;
  for i:= 0 to Count-1 do begin
    W.WriteListBegin;
    for j:= 0 to Dim-1 do begin
      W.WriteFloat(Data[i][j]);
    end;
    W.WriteListEnd;
  end;
  W.WriteListEnd;
  if FullSave then begin
    W.WriteListEnd;
  end;
end;

procedure TDataList.LoadFromReader(R: TReader);
var
  i, j: integer;
begin
  if FullSave then begin
    R.ReadListBegin;
    Dim:= R.ReadInteger;
    Count:= R.ReadInteger;
    RawMode:= R.ReadBoolean;
    Desc:= R.ReadString;
  end;
  R.ReadListBegin;
  for i:= 0 to Count-1 do begin
    R.ReadListBegin;
    for j:= 0 to Dim-1 do begin
      Data[i][j]:= R.ReadFloat;
    end;
    R.ReadListEnd;
  end;
  R.ReadListEnd;
  if FullSave then begin
    R.ReadListEnd;
  end;
end;

procedure TDataList.SaveToFile(const OutPath: string);
var
  f: text;
  i, j: integer;
begin
  AssignFile(f, OutPath);
  ReWrite(f);
  try
    try
      Writeln(f, Desc);
      Writeln(f, Count, ' ',Dim);
      for i:= 0 to Count-1 do begin
        for j:= 0 to Dim-1 do Write(f, FloatToStr(Pattern[i][j]),' ');
        Writeln(f);
      end;
    finally
      Close(f);
    end;
  except
    Erase(f);
    raise;
  end;
end;

procedure TDataList.LoadFromFile(const InPath: string);
var
  f: text;
  i, j: integer;
  aDesc: string;
  aCount, aDim: integer;
begin
  AssignFile(f, InPath);
  Reset(f);
  try
    Readln(f, aDesc);
    Readln(f, aCount, aDim);
    Desc := aDesc;
    Dim  := aDim;
    Count:= aCount;
    for i:= 0 to Count-1 do begin
      for j:= 0 to Dim-1 do Read(f, Pattern[i][j]);
      readln(f);
    end;
  finally
    Close(f);
  end;
end;

procedure TDataList.DefineProperties(Filer: TFiler);
begin
  FullSave:= false;
  try
    if RawMode then begin
      Filer.DefineBinaryProperty('RawData', LoadFromStream, SaveToStream, Count>0);
    end
    else begin
      Filer.DefineProperty('Data', LoadFromReader, SaveToWriter, Count>0);
    end;
  finally
    FullSave:= true;
  end;
  inherited DefineProperties(Filer);
end;

procedure TDataList.Assign(Source: TPersistent);
var
  DL: TDataList;
  i: integer;
begin
  if Source is TDataList then begin
    DL:= TDataList(Source);
    Dim:= DL.Dim;
    Count:= DL.Count;
    Desc:= DL.Desc;
    RawMode:= DL.RawMode;
    for i:= 0 to Count-1 do begin
      Data[i]:= DL.Data[i];
    end;
  end
  else inherited Assign(Source);
end;

procedure TDataList.Add(const Ptn: TData);
var
  N: integer;
begin
  N:= SizeOf(data);
  SetLength(Data, N+1);
  Data[N]:= Ptn;
end;

procedure TDataList.Insert(i: integer; const Ptn: TData);
var
  p, N: integer;
begin
  N:= SizeOf(data);
  SetLength(Data, N+1);
  for p:= N-1 downto i do begin
    Data[p+1]:= Data[p];
  end;
  Data[i]:= Ptn;
end;

procedure TDataList.Delete(i: integer);
var
  p, N: integer;
begin
  N:= SizeOf(data);
  for p:= i to N-2  do begin
    Data[p]:= Data[p+1];
  end;
  SetLength(Data, N-1);
end;

procedure TDataList.FreeData;
var
  i: integer;
begin
  for i:= High(Data) downto Low(Data) do begin
    SetLength(Data[i], 0);
  end;
  SetLength(Data, 0);
end;

destructor  TDataList.Destroy;
begin
  FreeData;
  inherited Destroy;
end;

constructor TDataPattern.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPatternKind:= pkInput;
  FPath:= '';
  FNeedLoad:= false;
  FAutoLoad:= true;
  FLoadListener:= TListenerList.Create;
end;

procedure TDataPattern.Loaded;
begin
  inherited Loaded;
  if FNeedLoad and (FPath<>'') then Load;
end;

procedure TDataPattern.SetPatternKind(vl: TPatternKind);
begin
  FPatternKind:= vl;
  if AutoLoad then begin
    if csLoading in ComponentState then FNeedLoad:= true
    else if FPath <> '' then Load;
  end;
end;

procedure TDataPattern.SetAutoLoad(vl: boolean);
begin
  FAutoLoad:= vl;
  if AutoLoad then begin
    if csLoading in ComponentState then FNeedLoad:= true
    else if FPath <> '' then Load;
  end;
end;

procedure TDataPattern.SetPath(vl: string);
begin
  FPath:= vl;
  if AutoLoad then begin
    if csLoading in ComponentState then FNeedLoad:= true
    else if FPath <> '' then Load;
  end;
end;

procedure TDataPattern.Load;
var
  f: text;
  tmps: string;
  NP, InDim, OutDim: integer;
  i, j: integer;
  tmp: double;
begin
  AssignFile(f, FileName);
  Reset(f);
  try
    Readln(f, tmps);
    Desc:= tmps;
    Readln(f, np, InDim, OutDim);
    Count:= np;
    case PatternKind of
      pkInput : if  InDim > 0 then Dim:= InDim;
      pkOutput: if OutDim > 0 then Dim:= OutDim;
    end;
    for i:= 0 to np-1 do begin
      if InDim > 0 then begin
        if PatternKind = pkInput then begin
          for j:= 0 to InDim-1 do Read(f, Pattern[i][j]);
        end
        else begin
          for j:= 0 to InDim-1 do Read(f, tmp);
        end;
      end;
      if OutDim > 0 then begin
        if PatternKind = pkOutput then begin
          for j:= 0 to OutDim-1 do Read(f, Pattern[i][j]);
        end
        else begin
          for j:= 0 to OutDim-1 do Read(f, tmp);
        end;
      end;
      Readln(f);
    end;
    FLoadListener.Notify(Self);
  finally
    Close(f);
  end;
end;

destructor TDataPattern.Destroy;
begin
  FLoadListener.Free;
  inherited Destroy;
end;

procedure LoadPattern(const Path: string; var iP, oP: TDataList);
var
  f: text;
  i, j: integer;
  pp: TData;
  aDesc: string;
  aCount, iDim, oDim: integer;
begin
  AssignFile(f, Path);
  Reset(f);
  try
    Readln(f, aDesc);
    Readln(f, aCount, iDim, oDim);
    ip:= TDataList.Create(nil);
    ip.Desc:= aDesc;
    ip.Dim:= iDim;
    ip.Count:= aCount;
    op:= TDataList.Create(nil);
    op.Desc:= aDesc;
    op.Dim:= oDim;
    op.Count:= aCount;
    for i:= 0 to aCount-1 do begin
      pp:= ip.Pattern[i];
      for j:= 0 to iDim-1 do Read(f, pp[j]);
      pp:= op.Pattern[i];
      for j:= 0 to oDim-1 do Read(f, pp[j]);
      readln(f);
    end;
  finally
    CloseFile(f);
  end;
end;

function FindPosMax(const p: TData): integer;
var
  mx: double;
  i: integer;
begin
  Result:= 0;
  mx:= p[0];
  for i := 1 to High(p) do begin
    if (p[i]>mx) then begin
      Result:= i;
      mx:= p[i];
    end;
  end;
end;

function SumSqr(N: integer; const YC, Y: TData): double;
var
  I: integer;
begin
  Result:= 0.0;
  for I:= 0 to N-1 do begin
    Result:= Result + sqr((YC[I]-Y[I]));
  end;
end;

procedure SumSqrMax(N: integer; const YC, Y: TData; var Sum, Max: double);
var
  I: integer;
  tmp: double;
begin
  Sum:= 0.0;
  Max:= 0.0;
  for I:= 0 to N-1 do begin
    tmp:= sqr((YC[I]-Y[I]));
    Sum:= Sum + tmp;
    if tmp > Max then Max:= tmp;
  end;
end;

procedure Register;
begin
  RegisterComponents(eCompPage, [TDataList, TDataPattern]);
end;

begin
  RegisterClass(TDataPicker);
  RegisterClass(TDataList);
  RegisterClass(TDataPattern);
end.

