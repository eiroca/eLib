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
unit eLibStat;

interface

uses
  SysUtils, Classes, eLib, eHashList, eLibMath;

type
  TIgnoreMode = (imNone, imLowerThan);

  TRandKind = record
    Kind: integer;
    Alea: double;
    Parm: double;
  end;

  TStat = record
    MinTag: integer;
    MaxTag: integer;
    Min: double;
    Max: double;
    Med: double;
    Vrz: double;
  end;

type

  TStatistic = class
    private
     function getAverage: double;
     function getVariance: double;
    public
     Dsc: string;
     Num : integer;
     Min: double;
     Max: double;
     SumX: double;
     SumX2: double;
    public
     constructor Create;
     procedure Reset;
     procedure Update(x: double);
    public
     property Average: double read getAverage;
     property Variance: double read getVariance;
  end;

  TStatistics = class
    private
     stat: THashList;
    protected
     function getStat(name: string): TStatistic;
     procedure setStat(name: string; s: TStatistic);
    public
     constructor Create;
     procedure Iterate(AUserData: Pointer; AIterateFunc: TIterateFunc);
     destructor Destroy; override;
    public
     property Statistic[name: string]: TStatistic read getStat write setStat; default;
  end;

type
  TErrorSet = class;

  TError = class(TPersistent)
    private
     FOwner: TErrorSet;
     FID    : integer;
     FErrAbs: TStat;
     FErrRel: TStat;
     FNum   : integer;
    protected
     function    Ignore(Tag: integer; Pred, Targ: double): boolean;
    public
     constructor Create(AOwner: TErrorSet; AID: integer);
     procedure   Assign(Source: TPersistent); override;
     procedure   LoadFromStream(S: TStream);
     procedure   SaveToStream(S: TStream);
     procedure   BeginCalc;
     procedure   EndCalc;
     procedure   ResumeCalc;
     procedure   Update(Tag: integer; Pred, Targ: double);
     destructor  Destroy; override;
    public
     property Owner: TErrorSet read FOwner;
     property ID: integer read FID;
     property ErrAbs: TStat read FErrAbs;
     property ErrRel: TStat read FErrRel;
     property Num   : integer read FNum;
  end;

  TErrorSet = class(TComponent)
    private
     FIgnoreParam: double;
     FIgnoreMode : TIgnoreMode;
     FNumUpd: integer;
     FNumAnl: integer;
     Errors: TList;
    private
     procedure ReadData(Stream: TStream);
     procedure WriteData(Stream: TStream);
    protected
     procedure   SetIgnoreMode(vl: TIgnoreMode);
     procedure   SetIgnoreParam(vl: double);
     procedure   AddError(Err: TError);
     procedure   DelError(Err: TError);
    public
     constructor Create(AOwner: TComponent); override;
     procedure   DefineProperties(Filer: TFiler); override;
     procedure   Setup(aIgnoreMode: TIgnoreMode; aIgnoreParam: double);
     procedure   BeginCalc;
     procedure   EndCalc;
     procedure   ResumeCalc;
     procedure   Update(AID: integer; ATag: integer; Pred, Targ: double);
     procedure   Analyze(ATag: integer; Dim: integer; const PreP, OutP: array of double);
     procedure   Report(Log: TStrings);
     function    Find(AID: integer): TError;
     destructor  Destroy; override;
    published
     property NumUpdate : integer read FNumUpd;
     property NumAnalyze: integer read FNumAnl;
     property IgnoreMode : TIgnoreMode read FIgnoreMode  write SetIgnoreMode;
     property IgnoreParam: double      read FIgnoreParam write SetIgnoreParam;
  end;

  Randomizer = class
   private
    class var
     glinext: integer;
     glinextp: integer;
     glma: array[1..55] of double;
     class function rand(idum: integer): double; static;
    public
     class function Val(Mode: TRandKind): double; static;
     class procedure Init(idum: integer); static;
     class function  IRand(Mdl: integer): integer; static;
     class function  DRand: double; static;
  end;

implementation

const
   mbig=1000000000;
   mseed=161803398;
   mz=0;
   fac=1.0e-9;

class function Randomizer.rand(idum: integer): double;
var
  mj: double;
begin
  glinext := glinext+1;
  if (glinext = 56) then glinext := 1;
  glinextp := glinextp+1;
  if (glinextp = 56) then glinextp := 1;
  mj := glma[glinext]-glma[glinextp];
  if (mj < mz) then mj := mj+mbig;
  glma[glinext]:= mj;
  rand:= mj*fac;
end;

class procedure Randomizer.Init(idum: integer);
var
  i, ii, k: integer;
  mj, mk: double;
  Hour, Minute, Second, Sec100: Word;
begin
  if idum = 0 then exit;
  if idum = -1 then begin
    DecodeTime(Now, Hour, Minute, Second, Sec100);
    idum:= (Minute+Second)*10+Sec100;
  end;
  idum:= -idum;
  mj := mseed+idum;
  (* The following if block is mj := mj MOD mbig; for double variables. *)
  if mj>=0.0 then mj := mj-mbig*trunc(mj/mbig)
  else mj := mbig-abs(mj)+mbig*trunc(abs(mj)/mbig);
  glma[55]:= mj;
  mk := 1;
  for i := 1 to 54 do begin
    ii := 21*i mod 55;
    glma[ii]:= mk;
    mk := mj-mk;
    if (mk < mz) then mk := mk+mbig;
    mj := glma[ii];
  end;
  for k := 1 TO 4 do begin
    for i := 1 TO 55 do begin
      glma[i]:= glma[i]-glma[1+((i+30) mod 55)];
      if (glma[i] < mz) then glma[i]:= glma[i]+mbig;
    end;
  end;
  glinext := 0;
  glinextp := 31;
end;

class function Randomizer.DRand: double;
begin
  DRand:= Rand(1);
end;

class function Randomizer.IRand(Mdl: integer): integer;
begin
  IRand:= trunc(Rand(1) * Mdl);
end;

class function Randomizer.Val(Mode: TRandKind): double;
(*  Genera un numero casuale,
     Mode.Kind
      0 = Uniforme(-VarAlea,+VarAlea)
      1 = Normale(0, VarAlea)
      2 = Triangolare(-VarAlea,+VarAlea)
*)
var
  R1, R2: double;
begin
  with Mode do begin
    R1:= DRand;
    R2:= DRand;
    case Kind of
      0: Result:= Alea*(2*R1-1);
      1: Result:= (cos(2 * PI * R2) * sqrt(-ln(R1)))*Alea;
      2: Result:= (R1+R2-1)*Alea;
      else Result:= 0;
    end;
  end;
end;

constructor TStatistic.Create;
begin
  Dsc:= '';
  Reset;
end;

procedure TStatistic.Reset;
begin
  SumX:= 0;
  SumX2:= 0;
  Max:= 0;
  Min:= 0;
  Num:= 0;
end;

procedure TStatistic.update(x: double);
begin
  SumX:= SumX + X;
  SumX2:= SumX2 + sqr(X);
  inc(Num);
  if (Num=1) then begin
    Max:= x;
    Min:= x;
  end
  else begin
    if (x>Max) then Max:= x
    else if (x<Min) then Min:= x;
  end;
end;

function TStatistic.getAverage: double;
begin
  if (Num>0) then begin
    Result:= SumX / Num;
  end
  else begin
    Result:= 0;
  end;
end;

function TStatistic.getVariance: double;
begin
  if (Num>0) then begin
    Result:= SumX2 / Num - sqr(SumX/Num);
  end
  else begin
    Result:= 0;
  end;
end;

constructor TStatistics.Create;
begin
  stat:= THashList.Create(1000, nil, nil);
end;

function TStatistics.getStat(name: string): TStatistic;
begin
  Result:= stat[name];
  if (Result=nil) then begin
    Result:= TStatistic.Create;
    stat.Add(name, Result);
  end;
end;

procedure TStatistics.setStat(name: string; s: TStatistic);
begin
  stat[name]:= s;
end;

procedure TStatistics.Iterate(AUserData: Pointer; AIterateFunc: TIterateFunc);
begin
  stat.Iterate(aUserData, AIterateFunc);
end;

destructor TStatistics.Destroy;
begin
  stat.Iterate(nil, Iterate_FreeObjects);
  stat.Free;
end;

constructor TError.Create(AOwner: TErrorSet; AID: integer);
begin
  FOwner:= AOwner;
  FID:= AID;
  BeginCalc;
  if Owner <> nil then Owner.AddError(Self);
end;

procedure TError.Assign(Source: TPersistent);
var
  E: TError;
begin
  if Source is TError then begin
    E:= TError(Source);
    FID    := E.ID;
    FErrAbs:= E.ErrAbs;
    FErrRel:= E.ErrRel;
    FNum   := E.Num;
  end
  else begin
    inherited Assign(Source);
  end;
end;

procedure TError.LoadFromStream(S: TStream);
begin                                             
  S.ReadBuffer(FID, SizeOf(FID));
  S.ReadBuffer(FNum, SizeOf(FNum));
  S.ReadBuffer(FErrAbs, SizeOf(FErrAbs));
  S.ReadBuffer(FErrRel, SizeOf(FErrRel));
end;

procedure TError.SaveToStream(S: TStream);
begin
  S.WriteBuffer(FID, SizeOf(FID));
  S.WriteBuffer(FNum, SizeOf(FNum));
  S.WriteBuffer(FErrAbs, SizeOf(FErrAbs));
  S.WriteBuffer(FErrRel, SizeOf(FErrRel));
end;

procedure TError.BeginCalc;
begin
  FErrAbs.MinTag:= -1;
  FErrAbs.MaxTag:= -1;
  FErrAbs.Min:=  cINF;
  FErrAbs.Max:= -cINF;
  FErrAbs.Med:= 0;
  FErrAbs.Vrz:= 0;
  FErrRel.MinTag:= -1;
  FErrRel.MaxTag:= -1;
  FErrRel.Min:=  cINF;
  FErrRel.Max:= -cINF;
  FErrRel.Med:= 0;
  FErrRel.Vrz:= 0;
  FNum:= 0;
end;

procedure TError.EndCalc;
begin
  if Num = 0 then begin
    FErrAbs.Med:= 0;
    FErrRel.Med:= 0;
    FErrAbs.Vrz:= 0;
    FErrRel.Vrz:= 0;
  end
  else begin
    FErrAbs.Med:= FErrAbs.Med / Num;
    FErrRel.Med:= FErrRel.Med / Num;
    FErrAbs.Vrz:= FErrAbs.Vrz / Num - sqr(FErrAbs.Med);
    FErrRel.Vrz:= FErrRel.Vrz / Num - sqr(FErrRel.Med);
  end;
end;

procedure TError.ResumeCalc;
begin
  if Num <= 0 then BeginCalc
  else begin
    FErrAbs.Med:= FErrAbs.Med * Num;
    FErrRel.Med:= FErrRel.Med * Num;
    FErrAbs.Vrz:= (FErrAbs.Vrz + sqr(FErrAbs.Med)) * Num;
    FErrRel.Vrz:= (FErrRel.Vrz + sqr(FErrRel.Med)) * Num;
  end;
end;

function TError.Ignore(Tag: integer; Pred, Targ: double): boolean;
begin
  Ignore:= abs(Pred-Targ) < Owner.IgnoreParam;
end;

procedure TError.Update(Tag: integer; Pred, Targ: double);
var
  tmp1, tmp2: double;
begin
  tmp1:= abs(Pred-Targ);
  if abs(Targ) > cZERO then tmp2:= abs(tmp1/Targ) else tmp2:= 0;
  case Owner.IgnoreMode of
    imNone: ;
    imLowerThan: begin
      if Ignore(Tag, Pred, Targ) then exit;
    end;
  end;
  if tmp1 < FErrAbs.Min then begin
    FErrAbs.Min:= tmp1;
    FErrAbs.MinTag:= Tag;
  end
  else if tmp1 > FErrAbs.Max then begin
    FErrAbs.Max:= tmp1;
    FErrAbs.MaxTag:= Tag;
  end;
  if tmp2 < FErrRel.Min then begin
    FErrRel.Min:= tmp2;
    FErrRel.MinTag:= Tag;
  end
  else if tmp2 > FErrRel.Max then begin
    FErrRel.Max:= tmp2;
    FErrRel.MaxTag:= Tag;
  end;
  FErrAbs.Med:= FErrAbs.Med + tmp1;
  FErrRel.Med:= FErrRel.Med + tmp2;
  FErrAbs.Vrz:= FErrAbs.Vrz + sqr(tmp1);
  FErrRel.Vrz:= FErrRel.Vrz + sqr(tmp2);
  inc(FNum);
end;

destructor  TError.Destroy;
begin
  if Owner <> nil then Owner.DelError(Self);
  inherited Destroy;
end;

constructor TErrorSet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Errors:= TList.Create;
  Setup(imNone, 0.0);
end;

procedure TErrorSet.ReadData(Stream: TStream);
var
  i: integer;
  Cnt: integer;
  Err: TError;
begin
  Stream.ReadBuffer(FNumUpd, SizeOf(FNumUpd));
  Stream.ReadBuffer(FNumAnl, SizeOf(FNumAnl));
  Stream.ReadBuffer(Cnt, SizeOf(Cnt));
  for i:= 0 to Cnt-1 do begin
    Err:= TError.Create(Self, -1);
    Err.LoadFromStream(Stream);
  end;
end;

procedure TErrorSet.WriteData(Stream: TStream);
var
  i: integer;
  Cnt: integer;
begin
  Stream.WriteBuffer(FNumUpd, SizeOf(FNumUpd));
  Stream.WriteBuffer(FNumAnl, SizeOf(FNumAnl));
  Cnt:= Errors.Count;
  Stream.WriteBuffer(Cnt, SizeOf(Cnt));
  for i:= 0 to Cnt-1 do begin
    TError(Errors[i]).SaveToStream(Stream);
  end;
end;

procedure TErrorSet.DefineProperties(Filer: TFiler);
begin
  Filer.DefineBinaryProperty('ErrorData', ReadData, WriteData, true);
end;

procedure TErrorSet.Setup(aIgnoreMode: TIgnoreMode; aIgnoreParam: double);
begin
  IgnoreMode := aIgnoreMode;
  IgnoreParam:= aIgnoreParam;
  BeginCalc;
end;

procedure TErrorSet.SetIgnoreMode(vl: TIgnoreMode);
begin
  if vl <> FIgnoreMode then begin
    FIgnoreMode:= vl;
    if not(csLoading in ComponentState) then BeginCalc;
  end;
end;

procedure TErrorSet.SetIgnoreParam(vl: double);
begin
  if (vl <> FIgnoreParam) then begin
    FIgnoreParam:= vl;
    if (IgnoreMode<>imNone) and (not(csLoading in ComponentState)) then BeginCalc;
  end;
end;

procedure TErrorSet.AddError(Err: TError);
begin
  if Err <> nil then Errors.Add(Err);
end;

procedure TErrorSet.DelError(Err: TError);
var
  ps: integer;
begin
  ps:= Errors.IndexOf(Err);
  if ps <> -1 then begin
    Errors.Delete(ps);
  end;
end;

procedure TErrorSet.Update(AID: integer; ATag: integer; Pred, Targ: double);
var
  i: integer;
  Err: TError;
  flg: boolean;
begin
  flg:= false;
  inc(FNumUpd);
  with Errors do begin
    for i:= 0 to Count-1 do begin
      Err:= TError(Items[i]);
      if Err.ID = AID then begin
        flg:= true;
        Err.Update(ATag, Pred, Targ);
        break;
      end;
    end;
  end;
  if not flg then begin
    Err:= TError.Create(Self, AID);
    i:= Errors.IndexOf(Err);
    TError(Errors.Items[i]).Update(ATag, Pred, Targ);
  end;
end;

procedure TErrorSet.BeginCalc;
var
  i: integer;
  Err: TError;
begin
  FNumUpd:= 0;
  FNumAnl:= 0;
  with Errors do begin
    for i:= 0 to Count-1 do begin
      Err:= TError(Items[i]);
      Err.BeginCalc;
    end;
  end;
end;

procedure TErrorSet.EndCalc;
var
  i: integer;
  Err: TError;
begin
  with Errors do begin
    for i:= 0 to Count-1 do begin
      Err:= TError(Items[i]);
      Err.EndCalc;
    end;
  end;
end;

procedure TErrorSet.ResumeCalc;
var
  i: integer;
  Err: TError;
begin
  with Errors do begin
    for i:= 0 to Count-1 do begin
      Err:= TError(Items[i]);
      Err.ResumeCalc;
    end;
  end;
end;

function TErrorSet.Find(AID: integer): TError;
var
  i: integer;
  Err: TError;
begin
  Find:= nil;
  with Errors do begin
    for i:= 0 to Count-1 do begin
      Err:= TError(Items[i]);
      if Err.ID = AID then begin
        Find:= Err;
        break;
      end;
    end;
  end;
end;

procedure TErrorSet.Analyze(ATag: integer; Dim: integer; const PreP, OutP: array of double);
var
  i: integer;
begin
  inc(FNumAnl);
  for i:= 0 to Dim-1 do begin
    Update(i+1, ATag, PreP[i], OutP[i]);
    Update(0,   ATag, PreP[i], OutP[i]);
  end;
end;

procedure TErrorSet.Report(Log: TStrings);
var
  AErr: TError;
  i: integer;
begin
  if Log <> nil then begin
    AErr:= Find(0);
    if AErr <> nil then begin
      with StrUtil, AErr do begin
        Log.Add(' Absolute Error (Global)');
        Log.Add('   Minimum  = '+OutFloat(ErrAbs.Min,12,8)+' Tag: '+IntToStr(ErrAbs.MinTag));
        Log.Add('   Maximum  = '+OutFloat(ErrAbs.Max,12,8)+' Tag: '+IntToStr(ErrAbs.MaxTag));
        Log.Add('   Average  = '+OutFloat(ErrAbs.Med,12,8));
        Log.Add('   Variance = '+OutFloat(ErrAbs.Vrz,12,8));
        Log.Add('');
        Log.Add(' Relative Error (Global)');
        Log.Add('   Minimum  = '+OutFloat(ErrRel.Min,12,8)+' Tag: '+IntToStr(ErrRel.MinTag));
        Log.Add('   Maximum  = '+OutFloat(ErrRel.Max,12,8)+' Tag: '+IntToStr(ErrRel.MaxTag));
        Log.Add('   Average  = '+OutFloat(ErrRel.Med,12,8));
        Log.Add('   Variance = '+OutFloat(ErrRel.Vrz,12,8));
      end;
    end;
    Log.Add('');
    Log.Add('              Absolute errors');
    Log.Add(' ID    Average   Variance    Maximum  Tag');
    with Errors do begin
      for i:= 0 to Count-1 do begin
        AErr:= TError(Items[i]);
        with StrUtil, AErr do begin
          if ID = 0 then continue;
          Log.Add(OutFloat(ID,3,0)+' '+
            OutFloat(ErrAbs.Med,10,6)+' '+
            OutFloat(ErrAbs.Vrz,10,6)+' '+
            OutFloat(ErrAbs.Max,10,6)+' '+
            OutFloat(ErrAbs.MaxTag,4,0));
        end;
      end;
    end;
    Log.Add('');
    Log.Add('              Relative errors');
    Log.Add(' ID    Average   Variance    Maximum  Tag');
    with Errors do begin
      for i:= 0 to Count-1 do begin
        AErr:= TError(Items[i]);
        with StrUtil, AErr do begin
          if ID = 0 then continue;
          Log.Add(OutFloat(ID,3,0)+' '+
            OutFloat(ErrRel.Med,10,6)+' '+
            OutFloat(ErrRel.Vrz,10,6)+' '+
            OutFloat(ErrRel.Max,10,6)+' '+
            OutFloat(ErrRel.MaxTag,4,0));
        end;
      end;
    end;
    Log.Add('');
  end;
end;

destructor  TErrorSet.Destroy;
var
  i: integer;
begin
  for i:= Errors.Count-1 downto 0 do begin
    TError(Errors[i]).Free;
  end;
  Errors.Free;
  inherited Destroy;
end;

initialization
  RegisterClass(TErrorSet);
end.

