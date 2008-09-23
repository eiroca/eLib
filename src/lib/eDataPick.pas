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
  PPattern = ^TPattern;
  TPattern = array[0..9999] of double; (* dynamic allocated! *)

  TPatternKind = (pkInput, pkOutput);

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

  TDataPickerClass = class of TDataPicker;

  TDataPicker = class(TComponent)
    private
     FChangeListener: TListenerList;
     FOnChange: TNotifyEvent;
     FDesc: string;
    protected
     function  GetDim: integer; virtual; abstract;
     function  GetCount: integer; virtual; abstract;
     function  GetPattern(i: integer): PPattern; virtual; abstract;
     procedure SetPattern(i: integer; vl: PPattern); virtual; abstract;
    protected
     procedure   Change; virtual;
    public
     constructor Create(AOwner: TComponent); override;
     procedure   Setup(aDim: integer; aCount: integer); virtual; abstract;
     destructor  Destroy; override;
    public
     property Dim  : integer read GetDim;
     property Count: integer read GetCount;
     property Pattern[i: integer]: PPattern read GetPattern write SetPattern; default;
     property ChangeListener: TListenerList read FChangeListener;
    published
     property Desc : string read FDesc write FDesc;
     property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TDataList = class(TDataPicker)
    private
     FDim: integer;
     Data: TList;
     FRawMode: boolean;
     FullSave: boolean;
     procedure FreeData;
    protected
     function  GetDim: integer; override;
     function  GetCount: integer; override;
     procedure SetDim(vl: integer); virtual;
     procedure SetCount(vl: integer); virtual;
     function  GetPattern(i: integer): PPattern; override;
     procedure SetPattern(i: integer; vl: PPattern); override;
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
     procedure   Add(Ptn: PPattern); virtual;
     procedure   Insert(i: integer; Ptn: PPattern); virtual;
     procedure   Delete(i: integer); virtual;
     destructor  Destroy; override;
    published
     property Dim  : integer read GetDim write SetDim;
     property Count: integer read GetCount write SetCount;
     property RawMode: boolean read FRawMode write FRawMode default true;
  end;

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

function  AllocPattern(Dim: integer): PPattern;
function  ReallocPattern(pt: PPattern; OldDim, NewDim: integer): PPattern;
procedure DisposePattern(pt: PPattern);

procedure Register;

implementation

type
  PByte = ^byte;


function AllocPattern(Dim: integer): PPattern;
begin
  Result:= nil;
  if Dim <> 0 then begin
    Dim:= Dim*SizeOf(double);
    ReallocMem(Result, Dim);
    FillChar(Result^, Dim, 0);
  end;
end;

function ReallocPattern(Pt: PPattern; OldDim, NewDim: integer): PPattern;
var
  p: PByte;
begin
  NewDim:= NewDim*SizeOf(double);
  OldDim:= OldDim*SizeOf(double);
  if NewDim < OldDim then begin
    ReallocMem(Pt, NewDim);
  end
  else begin
    ReallocMem(Pt, NewDim);
    p:= PByte(Pt);
    inc(p, OldDim);
    FillChar(p^, NewDim-OldDim, 0); 
  end;
  Result:= Pt;
end;

procedure DisposePattern(pt: PPattern);
begin
  ReallocMem(Pt, 0);
end;

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
  Data:= TList.Create;
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
    for i:= 0 to Data.Count-1 do begin
      Data[i]:= ReallocPattern(Data[i], FDim, vl);
    end;
    FDim:= vl;
    Change;
  end;
end;

function  TDataList.GetCount: integer;
begin
  Result:= Data.Count;
end;

procedure TDataList.SetCount(vl: integer);
var
  i: integer;
begin
  if vl < Data.Count then begin
    for i:= Data.Count-1 downto vl do begin
      Delete(i);
    end;
    Change;
  end
  else if vl > Data.Count then begin
    for i:= Data.Count to vl-1 do begin
      Add(AllocPattern(Dim));
    end;
    Change;
  end;
end;

function  TDataList.GetPattern(i: integer): PPattern;
begin
  Result:= PPattern(Data[i]);
end;

procedure TDataList.SetPattern(i: integer; vl: PPattern);
begin
  Move(PPattern(Data[i])^, vl^, FDim*SizeOf(double));
end;

procedure TDataList.SetUp(aDim: integer; aCount: integer);
begin
  Dim:= aDim;
  Count:= aCount;
end;

procedure TDataList.SaveToStream(S: TStream);
var
  i, tmp: integer;
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
      S.Write(Data[i]^, Dim * SizeOf(double));
    end;
  end;
end;

procedure TDataList.LoadFromStream(S: TStream);
var
  i, tmp: integer;
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
      S.Read(Data[i]^, Dim * SizeOf(double));
    end;
  end;
end;

procedure TDataList.SaveToWriter(W: TWriter);
var
  i, j: integer;
  P: PPattern;
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
    P:= Data[i];
    W.WriteListBegin;
    for j:= 0 to Dim-1 do begin
      W.WriteFloat(P^[j]);
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
  P: PPattern;
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
    P:= Data[i];
    R.ReadListBegin;
    for j:= 0 to Dim-1 do begin
      P^[j]:= R.ReadFloat;
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
  pp: PPattern;
begin
  AssignFile(f, OutPath);
  ReWrite(f);
  try
    try
      Writeln(f, Desc);
      Writeln(f, Count, ' ',Dim);
      for i:= 0 to Count-1 do begin
        pp:= Pattern[i];
        for j:= 0 to Dim-1 do Write(f, FloatToStr(pp^[j]),' ');
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
  pp: PPattern;
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
      pp:= Pattern[i];
      for j:= 0 to Dim-1 do Read(f, pp^[j]);
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
  pi, po: PPattern;
  i: integer;
begin
  if Source is TDataList then begin
    DL:= TDataList(Source);
    Dim:= DL.Dim;
    Count:= DL.Count;
    Desc:= DL.Desc;
    RawMode:= DL.RawMode;
    for i:= 0 to Count-1 do begin
      pi:= DL.Data[i];
      po:=    Data[i];
      Move(pi^, po^, Dim*SizeOf(double));
    end;
  end
  else inherited Assign(Source);
end;

procedure TDataList.Add(Ptn: PPattern);
begin
  Data.Add(Ptn);
end;

procedure TDataList.Insert(i: integer; Ptn: PPattern); 
begin
  Data.Insert(i, Ptn);
end;

procedure TDataList.Delete(i: integer);
begin
  DisposePattern(PPattern(Data[i]));
  Data.Delete(i);
end;

procedure TDataList.FreeData;
var
  i: integer;
begin
  for i:= Data.Count-1 downto 0 do begin
    DisposePattern(PPattern(Data[i]));
    Data.Delete(i);
  end;
end;

destructor  TDataList.Destroy;
begin
  FreeData;
  Data.Free;
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
  pp: PPattern;
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
          pp:= Pattern[i];
          for j:= 0 to InDim-1 do Read(f, pp^[j]);
        end
        else begin
          for j:= 0 to InDim-1 do Read(f, tmp);
        end;
      end;
      if OutDim > 0 then begin
        if PatternKind = pkOutput then begin
          pp:= Pattern[i];
          for j:= 0 to OutDim-1 do Read(f, pp^[j]);
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

procedure Register;
begin
  RegisterComponents(eCompPage, [TDataList, TDataPattern]);
end;

begin
  RegisterClass(TDataPicker);
  RegisterClass(TDataList);
  RegisterClass(TDataPattern);
end.

