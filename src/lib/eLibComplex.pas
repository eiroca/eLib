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
unit eLibComplex;

{$X+}

interface

uses
  SysUtils, Classes, Math, eLibCore, eLibMath;

type
  Polar = record
    Ma, An: double;
  end;

  PComplex = ^Complex;
  Complex = record
    public
     Re, Im: double;
    public
      class function  CompR (R: double): Complex; static;
      class function  CompRR(R, I: double): Complex; static;
      class function  CompMF(M, F: double): Complex; static;
      class function  CompLen(const C: Complex): double; static;
      class function  CompMod(const C: Complex): double; static;
      class function  CompFas(const C: Complex): double; static;
      class function  CompCon(const X: Complex): Complex; static;
      class function  ToPolar(const C: Complex): Polar; static;
      class function  ToComplex(const P: Polar): Complex; static;
      class procedure IncCC(var A: Complex; const B: Complex); static;
      class procedure IncCR(var A: Complex; Re: double); static;
      class function  AddCC(const A, B: Complex): Complex; static;
      class function  AddCR(const A: Complex; Re: double): Complex; static;
      class function  SubCC(const A, B: Complex): Complex; static;
      class function  SubCR(const A: Complex; Re: double): Complex; static;
      class function  SubRC(Re: double; const A: Complex): Complex; static;
      class function  MulCC(const A, B: Complex): Complex; static;
      class function  MulCR(const A: Complex; Re: double): Complex; static;
      class function  MulComCon(const C: Complex): double; static;
      class function  DivCC(const A, B: Complex): Complex; static;
      class function  DivCR(const A: Complex; Re: double): Complex; static;
      class function  DivRC(Re: double; const A: Complex): Complex; static;

      class function  AddMulCCC(const R: Complex; const A, B: Complex): Complex; static;
      class function  AddMulCCR(const R: Complex; const A: Complex; Re: double): Complex; static;
      class procedure IncMulCCC(var R: Complex; const A, B: Complex); static;
      class procedure IncMulCCR(var R: Complex; const A: Complex; Re: extended); static;
      class function  MulConCC(const A, B: Complex): Complex; static;

      class function  SqrC(const A: Complex): Complex; static;
      class function  InvC(const A: Complex): Complex; static;
      class function  NegC(const A: Complex): Complex; static;
      class function  MulCi(const A: Complex): Complex; static;
      class function  DivCi(const A: Complex): Complex; static;
      class function  ExpC(const Z: Complex): Complex; static;
      class function  LnC(const Z: Complex): Complex; static;
      class function  SqrtC(const Z: Complex): Complex; static;

      class function  CosC(const Z: Complex): Complex; static;
      class function  SinC(const Z: Complex): Complex; static;
      class function  TanC(const Z: Complex): Complex; static;
      class function  ArcCosC(const Z: Complex): Complex; static;
      class function  ArcSinC(const Z: Complex): Complex; static;
      class function  ArcTanC(const Z: Complex): Complex; static;
      class function  CosHC(const Z: Complex): Complex; static;
      class function  SinHC(const Z: Complex): Complex; static;
      class function  TanHC(const Z: Complex): Complex; static;
      class function  ArcCosHC(const Z: Complex): Complex; static;
      class function  ArcSinHC(const Z: Complex): Complex; static;
      class function  ArcTanHC(const Z: Complex): Complex; static;
  end;

const
  _i : Complex = (Re: 0.0; Im: 1.0);
  _0 : Complex = (Re: 0.0; Im: 0.0);

type
  PComplexArr = ^TComplexArr; TComplexArr = array[0..999999] of Complex;

  TCMatrix = class(TMatrix)
    protected
     function    DataRead(Row, Col: integer): Complex;
     procedure   DataWrite(Row, Col: integer; const vl: Complex);
     function    ItemRead(Row, Col: integer): Complex;
     procedure   ItemWrite(Row, Col: integer; const vl: Complex);
     function    GetElem: PComplexArr;
     procedure   ReadElem (R: TReader; P: pointer); override;
     procedure   WriteElem(W: TWriter; P: pointer); override;
     function  GetString(Row, Col: integer): string; override;
     procedure SetString(Row, Col: integer; const st: string); override;
    public
     property    Data[Row, Col: integer]: Complex read DataRead write DataWrite; default;
     property    Item[Row, Col: integer]: Complex read ItemRead write ItemWrite;
     property    Elem: PComplexArr read GetElem;
    public
     constructor Create(AOwner: TComponent); override;
     procedure   Setup(ARowMin, ARowCnt, AColMin, AColCnt: integer);
    published
     property Digit;
     property Decim;
  end;

  TCVector = class(TVector)
    protected
     function    DataRead(Row: integer): Complex;
     procedure   DataWrite(Row: integer; const vl: Complex);
     function    ItemRead(Row: integer): Complex;
     procedure   ItemWrite(Row: integer; const vl: Complex);
     function    GetElem: PComplexArr;
     procedure   ReadElem (R: TReader; P: pointer); override;
     procedure   WriteElem(W: TWriter; P: pointer); override;
     function    GetString(Row: integer): string; override;
     procedure   SetString(Row: integer; const st: string); override;
    public
     property    Data[Row: integer]: Complex read DataRead write DataWrite; default;
     property    Item[Row: integer]: Complex read ItemRead write ItemWrite;
     property    Elem: PComplexArr read GetElem;
    public
     constructor Create(AOwner: TComponent); override;
     procedure   Setup(ARowMin, ARowCnt: integer);
    published
     property Digit;
     property Decim;
  end;

type
  PCCElem = ^TCCElem;
  TCCElem = record
    Next: PCCElem;
    Data: Complex;
    R   : integer;
  end;

  PCRElem = ^TCRElem;
  TCRElem = record
    Next: PCRElem;
    Data: Complex;
    C   : integer;
  end;

  PCCols = ^TCCols;
  TCCols = array[0..255] of PCCElem;

  PCRows = ^TCRows;
  TCRows = array[0..255] of PCRElem;

  TCSpMatrC = class
    private
     function    GetAt (ARow, ACol: integer): Complex;
     function    GetAt0(ARow, ACol: integer): Complex;
     procedure   SetAt (ARow, ACol: integer; const Val: Complex);
     procedure   SetAt0(ARow, ACol: integer; const Val: Complex);
     function    TakeAt (ARow, ACol: integer): Complex;
     function    TakeAt0(ARow, ACol: integer): Complex;
     procedure   CheckIndex(Row, Col: integer);
    public
     Col: PCCols;
     Lst: PCCols;
     Row: PCols;
     Rows: integer;
     Cols: integer;
     Base: integer;
     constructor Create(ABase, ARow, ACol: integer);
     property    Data[ARow, ACol: integer]: Complex read GetAt write SetAt; default;
     property    Item[ARow, ACol: integer]: Complex read GetAt0 write SetAt0;
     property    Take[ARow, ACol: integer]: Complex read TakeAt write SetAt;
     property    Take0[ARow, ACol: integer]: Complex read TakeAt0 write SetAt0;
     function    IsZero (ARow, ACol: integer): boolean;
     function    IsZero0(ARow, ACol: integer): boolean;
     destructor  Destroy; override;
   end;

  TCSpMatrR = class
    private
     function    GetAt (ARow, ACol: integer): Complex;
     function    GetAt0(ARow, ACol: integer): Complex;
     procedure   SetAt (ARow, ACol: integer; const Val: Complex);
     procedure   SetAt0(ARow, ACol: integer; const Val: Complex);
     function    TakeAt (ARow, ACol: integer): Complex;
     function    TakeAt0(ARow, ACol: integer): Complex;
     procedure   CheckIndex(Row, Col: integer);
    public
     Col: PRows;
     Lst: PCRows;
     Row: PCRows;
     Rows: integer;
     Cols: integer;
     Base: integer;
     constructor Create(ABase, ARow, ACol: integer);
     property    Data[ARow, ACol: integer]: Complex read GetAt write SetAt; default;
     property    Item[ARow, ACol: integer]: Complex read GetAt0 write SetAt0;
     property    Take[ARow, ACol: integer]: Complex read TakeAt write SetAt;
     property    Take0[ARow, ACol: integer]: Complex read TakeAt0 write SetAt0;
     function    IsZero (ARow, ACol: integer): boolean;
     function    IsZero0(ARow, ACol: integer): boolean;
     destructor  Destroy; override;
   end;

implementation

class function Complex.CompR;
begin
  Result.Re:= R;
  Result.Im:= 0;
end;

class function Complex.CompRR;
begin
  Result.Re:= R;
  Result.Im:= I;
end;

class function Complex.CompMF;
begin
  Result.Re:= M*cos(F);
  Result.Im:= M*sin(F);
end;

class function Complex.CompCon;
begin
  Result.Re:= X.Re;
  Result.Im:= -X.Im;
end;

class function Complex.ToPolar;
begin
  Result.Ma:= sqrt(sqr(C.Re) + sqr(C.Im));
  Result.An:= arctan(C.Im / C.Re);
end;

class function Complex.ToComplex;
begin
  Result.Re:= P.Ma * cos(P.An);
  Result.Im:= P.Ma * sin(P.An);
end;

class function Complex.AddCC;
begin
  Result.Re:= A.Re + B.Re;
  Result.Im:= A.Im + B.Im;
end;

class function Complex.AddCR;
begin
  Result.Re:= A.Re + Re;
  Result.Im:= A.Im;
end;

class procedure Complex.IncCC;
begin
  A.Re:= A.Re + B.Re;
  A.Im:= A.Im + B.Im;
end;

class procedure Complex.IncCR;
begin
  A.Re:= A.Re + Re;
end;

class function Complex.SubCC;
begin
  Result.Re:= A.Re - B.Re;
  Result.Im:= A.Im - B.Im;
end;

class function Complex.SubCR;
begin
  Result.Re:= A.Re - Re;
  Result.Im:= A.Im;
end;

class function Complex.SubRC;
begin
  Result.Re:= Re - A.Re;
  Result.Im:= -A.Im;
end;

class function Complex.MulCC;
begin
  Result.Re:= A.Re * B.Re - A.Im * B.Im;
  Result.Im:= A.Re * B.Im + A.Im * B.Re;
end;

class function Complex.MulCR;
begin
  Result.Re:= A.Re * Re;
  Result.Im:= A.Im * Re;
end;

class function Complex.DivCC;
var
  tmp: double;
begin
  tmp:= sqr(B.Re) + sqr(B.Im);
  Result.Re:= (A.Re * B.Re + A.Im * B.Im) / tmp;
  Result.Im:= (A.Im * B.Re - A.Re * B.Im) / tmp;
end;

class function Complex.DivCR;
begin
  Result.Re:= A.Re / Re;
  Result.Im:= A.Im / Re;
end;

class function Complex.DivRC;
var
  tmp: double;
begin
  tmp:= sqr(A.Re) + sqr(A.Im);
  Result.Re:= A.Re * Re / tmp;
  Result.Im:= -A.Im * Re / tmp;
end;

class function Complex.MulComCon;
begin
  MulComCon:= sqr(C.Re)+sqr(C.Im);
end;

class function Complex.CompLen;
begin
  CompLen:= sqr(C.Re)+sqr(C.Im);
end;

class function Complex.CompMod;
begin
  CompMod:= sqrt(sqr(C.Re)+sqr(C.Im));
end;

class function Complex.CompFas;
var tmp: double;
begin
  if (abs(C.Re) < cZERO) and (abs(C.Im) < cZERO) then begin
    CompFas:= 0;
  end
  else if (abs(C.Re) < cZERO) then begin
    if C.Im < 0 then CompFas:= 1.5 * PI else CompFas:= 0.5 * PI;
  end
  else if (abs(C.Im) < cZERO) then begin
    if C.Re < 0 then CompFas:= PI else CompFas:= 0;
  end
  else begin
    tmp:= ArcTan(C.Im / C.Re);
    if C.Re < 0 then tmp:= tmp + PI
    else if C.Im < 0 then tmp:= tmp + 2*PI;
    CompFas:= tmp;
  end;
end;

class function Complex.AddMulCCC;
begin
  Result.Re:= R.Re + A.Re * B.Re - A.Im * B.Im;
  Result.Im:= R.Im + A.Re * B.Im + A.Im * B.Re;
end;

class function Complex.AddMulCCR;
begin
  Result.Re:= R.Re + A.Re * Re;
  Result.Im:= R.Im + A.Im * Re;
end;

class procedure Complex.IncMulCCC;
begin
  R.Re:= R.Re + A.Re * B.Re - A.Im * B.Im;
  R.Im:= R.Im + A.Re * B.Im + A.Im * B.Re;
end;

class procedure Complex.IncMulCCR;
begin
  R.Re:= R.Re + A.Re * Re;
  R.Im:= R.Im + A.Im * Re;
end;

class function Complex.MulConCC;
begin
  Result.Re:= A.Re * B.Re + A.Im * B.Im;
  Result.Im:= A.Im * B.Re - A.Re * B.Im;
end;

class function Complex.SqrC;
begin
  Result.Re:= sqr(A.Re) - sqr(A.Im);
  Result.Im:= 2*A.Re*A.Im;
end;

class function Complex.InvC;
var
  tmp: double;
begin
  tmp:= a.Re * a.Re + a.Im * a.Im;
  Result.Re:=   a.Re / tmp;
  Result.Im:= - a.Im / tmp;
end;

class function Complex.NegC;
begin
  Result.Re:= -a.Re;
  Result.Im:= -a.Im;
end;

class function Complex.MulCi;
begin
  Result.Re:= -a.Im;
  Result.Im:=  a.Re;
end;

class function Complex.DivCi;
begin
  Result.Re:=  a.Im;
  Result.Im:= -a.Re;
end;

class function Complex.ExpC(const z: Complex): Complex;
(* exponantielle: r:=exp(z) *)
(* exp(x + iy) = exp(x).exp(iy) = exp(x).[cos(y) + i sin(y)] *)
var expz: double;
begin
  expz:= exp(z.Re);
  Result.Re:= expz * cos(z.Im);
  Result.Im:= expz * sin(z.Im);
end;

class function Complex.LnC(const z: Complex): Complex;
(* logarithme naturel: r:=ln(z) *)
(* ln(p exp(i0)) = ln(p) + i0 + 2kpi *)
var modz: double;
begin
  modz:= sqr(Z.Re)+sqr(Z.Im);
  Result.Re:= ln(modz);
  Result.Im:= arctan2(z.Re, z.Im);
end;

class function Complex.sqrtC(const z: Complex): Complex;
(* racine carre: r:= sqrt(z) *)
var root, q: double;
begin
  if (z.Re <> 0.0) or (z.Im <> 0.0) then begin
    root:= sqrt(0.5 * (abs(z.Re) + CompMod(z)));
    q:= z.Im / (2.0 * root);
    if z.Re >= 0.0 then
      with Result do begin
        Re:= root;
        Im:= q
      end
    else if z.Im < 0.0 then
      with Result do begin
        Re:= -q;
        Im:= -root
      end
    else with Result do begin
      Re:= q;
      Im:= root
    end
  end
  else Result:= z;
end;

class function Complex.CosC(const z: Complex): Complex;
(* cosinus Complex *)
(* cos(x+iy) = cos(x).cos(iy) - sin(x).sin(iy) *)
(* cos(ix) = ch(x) et sin(ix) = i.sh(x) *)
begin
  Result.Re:=  cos(z.Re) * CosH(z.Im);
  Result.Im:= -sin(z.Re) * SinH(z.Im);
end;

class function Complex.SinC(const z: Complex): Complex;
(* sinus Complex *)
(* sin(x+iy) = sin(x).cos(iy) + cos(x).sin(iy) *)
(* cos(ix) = ch(x) et sin(ix) = i.sh(x) *)
begin
  Result.Re:= sin(z.Re) * CosH(z.Im);
  Result.Im:= cos(z.Re) * SinH(z.Im);
end;

class function Complex.TanC(const z: Complex): Complex;
(* tangente *)
begin
  Result:= DivCC(SinC(z), CosC(z));
end;

class function Complex.ArcCosHC(const z: Complex): Complex;
(*   arg cosinus hyperbolique    *)
(*                          _________  *)
(* argch(z) = -/+ ln(z + i.V 1 - z.z)  *)
var temp: Complex;
begin
  with temp do begin
    Re:=  1 - sqr(z.Re) + sqr(z.Im);
    Im:= -2 * z.Re * z.Im;
  end;
  Result:= NegC(LnC(AddCC(z, MulCi(SqrtC(temp)))));
end;

class function Complex.ArcSinHC(const z: Complex): Complex;
(*   arc sinus hyperbolique    *)
(*                    ________  *)
(* argsh(z) = ln(z + V 1 + z.z) *)
var temp: Complex;
begin
  with temp do begin
    Re:= 1 + sqr(z.Re) - sqr(z.Im);
    Im:= 2 * z.Re * z.Im;
  end;
  Result:= LnC(AddCC(z, SqrtC(temp)));
end;

class function Complex.ArcTanHC(const z: Complex): Complex;
(* arc tangente hyperbolique *)
(* argth(z) = 1/2 ln((z + 1) / (1 - z)) *)
var temp: Complex;
begin
  with temp do begin
    Re:= 1 + z.Re;
    Im:= z.Im;
  end;
  with Result do begin
    Re:= 1 - Re;
    Im:=   - Im;
  end;
  Result:= DivCC(temp, Result);
  with Result do begin
    Re:= 0.5 * Re;
    Im:= 0.5 * Im;
  end;
end;

class function Complex.ArcCosC(const z: Complex): Complex;
(* arc cosinus Complex *)
(* arccos(z) = -i.argch(z) *)
begin
  Result:= DivCi(ArcCosHC(z));
end;

class function Complex.ArcSinC(const z: Complex): Complex;
(* arc sinus Complex *)
(* arcsin(z) = -i.argsh(i.z) *)
begin
  Result:= DivCi(ArcSinHC(MulCi(z)));
end;

class function Complex.ArcTanC(const z: Complex): Complex;
(* arc tangente Complex *)
(* arctg(z) = -i.argth(i.z) *)
begin
  Result:= DivCi(ArcTanHC(MulCi(z)));
end;

(* fonctions trigonometriques hyperboliques *)

class function Complex.CosHC(const z: Complex): Complex;
(* cosinus hyperbolique *)
(* ch(x+iy) = ch(x).ch(iy) + sh(x).sh(iy) *)
(* ch(iy) = cos(y) et sh(iy) = i.sin(y) *)
begin
  Result.Re:= CosH(z.Re) * cos(z.Im);
  Result.Im:= SinH(z.Re) * sin(z.Im);
end;

class function Complex.SinHC(const z: Complex): Complex;
(* sinus hyperbolique *)
(* sh(x+iy) = sh(x).ch(iy) + ch(x).sh(iy) *)
(* ch(iy) = cos(y) et sh(iy) = i.sin(y) *)
begin
  Result.Re:= SinH(z.Re) * cos(z.Im);
  Result.Im:= CosH(z.Re) * sin(z.Im);
end;

class function Complex.TanHC(const z: Complex): Complex;
(* tangente hyperbolique Complex *)
(* th(x) = sh(x) / ch(x) *)
(* ch(x) > 1 qq x *)
begin
  Result:= DivCC(SinHC(z), CosHC(z));
end;

(*--------------------------------------------------------------------------*)

constructor TCMatrix.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSize:= SizeOf(Complex);
end;

function TCMatrix.GetString;
begin
  Result:= Format('%*.*f %*.*f', [Digit,Decim,Data[Row, Col].Re,Digit,Decim,Data[Row, Col].Im]);
end;

procedure TCMatrix.SetString(Row, Col: integer; const st: string);
var
  tmp: string;
  i: integer;
  c: Complex;
begin
  tmp:= Trim(st);
  i:= pos(' ', tmp);
  if i <> 0 then begin
    C.Re:= StrToFloat(Copy(tmp,1,i-1));
    C.Im:= StrToFloat(Trim(Copy(tmp,i,length(tmp))));
  end
  else begin
    C.Re:= StrToFloat(tmp);
    C.Im:= 0;
  end;
  Data[Row, Col]:= C;
end;

procedure TCMatrix.ReadElem (R: TReader; P: pointer);
begin
  PComplex(P)^.Re:= R.ReadFloat;
  PComplex(P)^.Im:= R.ReadFloat;
end;

procedure TCMatrix.WriteElem(W: TWriter; P: pointer);
begin
  W.WriteFloat(PComplex(P)^.Re);
  W.WriteFloat(PComplex(P)^.Im);
end;

procedure TCMatrix.Setup(ARowMin, ARowCnt, AColMin, AColCnt: integer);
begin
  inherited Setup(ARowMin, ARowCnt, AColMin, AColCnt, SizeOf(Complex));
end;

function TCMatrix.GetElem: PComplexArr;
begin
  Result:= PComplexArr(FData);
end;

function TCMatrix.DataRead(Row, Col: integer): Complex;
begin
  {$IFOPT R+}
  CheckIndex(Row, Col);
  {$ENDIF}
  Result:= PComplexArr(FData)^[(Col-ColMin)+ColCnt*(Row-RowMin)];
end;

procedure TCMatrix.DataWrite(Row, Col: integer; const vl: Complex);
begin
  {$IFOPT R+}
  CheckIndex(Row, Col);
  {$ENDIF}
  PComplexArr(FData)^[(Col-ColMin)+ColCnt*(Row-RowMin)]:= vl;
end;

function TCMatrix.ItemRead(Row, Col: integer): Complex;
begin
  {$IFOPT R+}
  CheckIndex(RowMin+Row, ColMin+Col);
  {$ENDIF}
  Result:= PComplexArr(FData)^[Col+ColCnt*Row];
end;

procedure TCMatrix.ItemWrite(Row, Col: integer; const vl: Complex);
begin
  {$IFOPT R+}
  CheckIndex(RowMin+Row, ColMin+Col);
  {$ENDIF}
  PComplexArr(FData)^[Col+ColCnt*Row]:= vl;
end;

(*--------------------------------------------------------------------------*)

constructor TCVector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSize:= SizeOf(Complex);
end;

function TCVector.GetString;
begin
  Result:= Format('%*.*f %*.*f', [Digit,Decim,Data[Row].Re,Digit,Decim,Data[Row].Im]);
end;

procedure TCVector.SetString(Row: integer; const st: string);
var
  tmp: string;
  i: integer;
  c: Complex;
begin
  tmp:= Trim(st);
  i:= pos(' ', tmp);
  if i <> 0 then begin
    C.Re:= StrToFloat(Copy(tmp,1,i-1));
    C.Im:= StrToFloat(Trim(Copy(tmp,i,length(tmp))));
  end
  else begin
    C.Re:= StrToFloat(tmp);
    C.Im:= 0;
  end;
  Data[Row]:= C;
end;

procedure TCVector.ReadElem (R: TReader; P: pointer);
begin
  PComplex(P)^.Re:= R.ReadFloat;
  PComplex(P)^.Im:= R.ReadFloat;
end;

procedure TCVector.WriteElem(W: TWriter; P: pointer);
begin
  W.WriteFloat(PComplex(P)^.Re);
  W.WriteFloat(PComplex(P)^.Im);
end;

procedure TCVector.Setup(ARowMin, ARowCnt: integer);
begin
  inherited Setup(ARowMin, ARowCnt, SizeOf(Complex));
end;

function TCVector.GetElem: PComplexArr;
begin
  Result:= PComplexArr(FData);
end;

function TCVector.DataRead(Row: integer): Complex;
begin
  {$IFOPT R+}
  CheckIndex(Row);
  {$ENDIF}
  Result:= PComplexArr(FData)^[(Row-RowMin)];
end;

procedure TCVector.DataWrite(Row: integer; const vl: Complex);
begin
  {$IFOPT R+}
  CheckIndex(Row);
  {$ENDIF}
  PComplexArr(FData)^[(Row-RowMin)]:= vl;
end;

function TCVector.ItemRead(Row: integer): Complex;
begin
  {$IFOPT R+}
  CheckIndex(RowMin+Row);
  {$ENDIF}
  Result:= PComplexArr(FData)^[Row];
end;

procedure TCVector.ItemWrite(Row: integer; const vl: Complex);
begin
  {$IFOPT R+}
  CheckIndex(RowMin+Row);
  {$ENDIF}
  PComplexArr(FData)^[Row]:= vl;
end;

constructor TCSpMatrC.Create(ABase, ARow, ACol: integer);
var
  c: integer;
begin
  Rows:= ARow;
  Cols:= ACol;
  Base:= ABase;
  GetMem(Col, ACol * SizeOf(PCCElem));
  GetMem(Lst, ACol * SizeOf(PCCElem));
  GetMem(Row, ACol * SizeOf(IndxSet));
  for c:= 0 to Cols-1 do begin
    Row^[c]:= [];
    Col^[c]:= nil;
    Lst^[c]:= nil;
  end;
end;

function TCSpMatrC.GetAt0(ARow, ACol: integer): Complex;
var
  Old, ps: PCCElem;
begin
  {$IFOPT R+}
  CheckIndex(Base+ARow, Base+ACol);
  {$ENDIF}
  if IsZero0(ARow, ACol) then GetAt0:= _0
  else begin
    ps:= Col^[ACol];
    old:= nil;
    while (ps <> nil) and (ps^.R <> ARow) do begin
      Old:= ps;
      ps:= ps^.Next;
    end;
    GetAt0:= ps^.Data;
    if Old <> nil then begin
      Lst^[ACol]^.Next:= Col^[ACol];
      Col^[ACol]:= ps;
      Old^.Next:= nil;
      Lst^[ACol]:= Old;
    end;
  end;
end;

function TCSpMatrC.GetAt(ARow, ACol: integer): Complex;
var
  Old, ps: PCCElem;
begin
  {$IFOPT R+}
  CheckIndex(ARow, ACol);
  {$ENDIF}
  Dec(ARow, Base);
  Dec(ACol, Base);
  if IsZero0(ARow, ACol) then GetAt:= _0
  else begin
    ps:= Col^[ACol];
    old:= nil;
    while (ps <> nil) and (ps^.R <> ARow) do begin
      Old:= ps;
      ps:= ps^.Next;
    end;
    GetAt:= ps^.Data;
    if Old <> nil then begin
      Lst^[ACol]^.Next:= Col^[ACol];
      Col^[ACol]:= ps;
      Old^.Next:= nil;
      Lst^[ACol]:= Old;
    end;
  end;
end;

procedure TCSpMatrC.CheckIndex(Row, Col: integer);
begin
end;

function TCSpMatrC.TakeAt0(ARow, ACol: integer): Complex;
var
  Old, ps: PCCElem;
begin
  {$IFOPT R+}
  CheckIndex(Base+ARow, Base+ACol);
  {$ENDIF}
  ps:= Col^[ACol];
  old:= nil;
  while (ps <> nil) and (ps^.R <> ARow) do begin
    Old:= ps;
    ps:= ps^.Next;
  end;
  if ps <> nil then TakeAt0:= ps^.Data else TakeAt0:= _0;
  if Old <> nil then begin
    Lst^[ACol]^.Next:= Col^[ACol];
    Col^[ACol]:= ps;
    Old^.Next:= nil;
    Lst^[ACol]:= Old;
  end;
end;

function TCSpMatrC.TakeAt(ARow, ACol: integer): Complex;
var
  Old, ps: PCCElem;
begin
  {$IFOPT R+}
  CheckIndex(Base+ARow, Base+ACol);
  {$ENDIF}
  dec(ARow, Base);
  dec(ACol, Base);
  ps:= Col^[ACol];
  old:= nil;
  while (ps <> nil) and (ps^.R <> ARow) do begin
    Old:= ps;
    ps:= ps^.Next;
  end;
  if ps <> nil then TakeAt:= ps^.Data else TakeAt:= _0;
  if Old <> nil then begin
    Lst^[ACol]^.Next:= Col^[ACol];
    Col^[ACol]:= ps;
    Old^.Next:= nil;
    Lst^[ACol]:= Old;
  end;
end;

procedure TCSpMatrC.SetAt(ARow, ACol: integer; const Val: Complex);
var
  tmp: PCCElem;
begin
  {$IFOPT R+}
  CheckIndex(ARow, ACol);
  {$ENDIF}
  Dec(ARow, Base);
  Dec(ACol, Base);
  Row^[ACol]:= Row^[ACol] + [ARow];
  New(tmp);
  with tmp^ do begin
    R:= ARow;
    Data:= Val;
    Next:= Col^[ACol];
  end;
  if Lst^[ACol] = nil then Lst^[ACol]:= tmp;
  Col^[ACol]:= tmp;
end;

procedure TCSpMatrC.SetAt0(ARow, ACol: integer; const Val: Complex);
var
  tmp: PCCElem;
begin
  {$IFOPT R+}
  CheckIndex(Base+ARow, Base+ACol);
  {$ENDIF}
  Row^[ACol]:= Row^[ACol] + [ARow];
  New(tmp);
  with tmp^ do begin
    R:= ARow;
    Data:= Val;
    Next:= Col^[ACol];
  end;
  if Lst^[ACol] = nil then Lst^[ACol]:= tmp;
  Col^[ACol]:= tmp;
end;

function TCSpMatrC.IsZero(ARow, ACol: integer): boolean;
begin
  {$IFOPT R+}
  CheckIndex(ARow, ACol);
  {$ENDIF}
  IsZero:= not ((ARow-Base) in Row^[ACol-Base]);
end;

function TCSpMatrC.IsZero0(ARow, ACol: integer): boolean;
begin
  {$IFOPT R+}
  CheckIndex(Base+ARow, Base+ACol);
  {$ENDIF}
  IsZero0:= not(ARow in Row^[ACol]);
end;

destructor TCSpMatrC.Destroy;
var
  old, ps: PCCElem;
  c: integer;
begin
  for c:= 0 to Cols-1 do begin
    ps:= Col^[c];
    while ps <> nil do begin
      old:= ps;
      ps:= ps^.Next;
      Dispose(old);
    end;
  end;
  FreeMem(Col, Cols * SizeOf(PCCElem));
  FreeMem(Lst, Cols * SizeOf(PCCElem));
  FreeMem(Row, Cols * SizeOf(IndxSet));
end;

constructor TCSpMatrR.Create(ABase, ARow, ACol: integer);
var
  c: integer;
begin
  Rows:= ARow;
  Cols:= ACol;
  Base:= ABase;
  GetMem(Row, Rows * SizeOf(PCCElem));
  GetMem(Lst, Rows * SizeOf(PCCElem));
  GetMem(Col, Rows * SizeOf(IndxSet));
  for c:= 0 to Rows-1 do begin
    Col^[c]:= [];
    Row^[c]:= nil;
    Lst^[c]:= nil;
  end;
end;

function TCSpMatrR.GetAt0(ARow, ACol: integer): Complex;
var
  Old, ps: PCRElem;
begin
  {$IFOPT R+}
  CheckIndex(Base+ARow, Base+ACol);
  {$ENDIF}
  if IsZero0(ARow, ACol) then GetAt0:= _0
  else begin
    ps:= Row^[ARow];
    old:= nil;
    while (ps <> nil) and (ps^.C <> ACol) do begin
      Old:= ps;
      ps:= ps^.Next;
    end;
    GetAt0:= ps^.Data;
    if Old <> nil then begin
      Lst^[ARow]^.Next:= Row^[ARow];
      Row^[ARow]:= ps;
      Old^.Next:= nil;
      Lst^[ARow]:= Old;
    end;
  end;
end;

function TCSpMatrR.GetAt(ARow, ACol: integer): Complex;
var
  Old, ps: PCRElem;
begin
  {$IFOPT R+}
  CheckIndex(ARow, ACol);
  {$ENDIF}
  Dec(ARow, Base);
  Dec(ACol, Base);
  if IsZero0(ARow, ACol) then GetAt:= _0
  else begin
    ps:= Row^[ARow];
    old:= nil;
    while (ps <> nil) and (ps^.C <> ACol) do begin
      Old:= ps;
      ps:= ps^.Next;
    end;
    GetAt:= ps^.Data;
    if Old <> nil then begin
      Lst^[ARow]^.Next:= Row^[ARow];
      Row^[ARow]:= ps;
      Old^.Next:= nil;
      Lst^[ARow]:= Old;
    end;
  end;
end;

procedure TCSpMatrR.CheckIndex(Row, Col: integer);
begin
end;

function TCSpMatrR.TakeAt0(ARow, ACol: integer): Complex;
var
  Old, ps: PCRElem;
begin
  {$IFOPT R+}
  CheckIndex(Base+ARow, Base+ACol);
  {$ENDIF}
  ps:= Row^[ARow];
  old:= nil;
  while (ps <> nil) and (ps^.C <> ACol) do begin
    Old:= ps;
    ps:= ps^.Next;
  end;
  if ps <> nil then TakeAt0:= ps^.Data else TakeAt0:= _0;
  if Old <> nil then begin
    Lst^[ARow]^.Next:= Row^[ARow];
    Row^[ARow]:= ps;
    Old^.Next:= nil;
    Lst^[ARow]:= Old;
  end;
end;

function TCSpMatrR.TakeAt(ARow, ACol: integer): Complex;
var
  Old, ps: PCRElem;
begin
  {$IFOPT R+}
  CheckIndex(Base+ARow, Base+ACol);
  {$ENDIF}
  dec(ARow, Base);
  dec(ACol, Base);
  ps:= Row^[ARow];
  old:= nil;
  while (ps <> nil) and (ps^.C <> ACol) do begin
    Old:= ps;
    ps:= ps^.Next;
  end;
  if ps <> nil then TakeAt:= ps^.Data else TakeAt:= _0;
  if Old <> nil then begin
    Lst^[ARow]^.Next:= Row^[ARow];
    Row^[ARow]:= ps;
    Old^.Next:= nil;
    Lst^[ARow]:= Old;
  end;
end;

procedure TCSpMatrR.SetAt(ARow, ACol: integer; const Val: Complex);
var
  tmp: PCRElem;
begin
  {$IFOPT R+}
  CheckIndex(ARow, ACol);
  {$ENDIF}
  Dec(ARow, Base);
  Dec(ACol, Base);
  Col^[ARow]:= Col^[ARow] + [ACol];
  New(tmp);
  with tmp^ do begin
    C:= ACol;
    Data:= Val;
    Next:= Row^[ARow];
  end;
  if Lst^[ARow] = nil then Lst^[ARow]:= tmp;
  Row^[ARow]:= tmp;
end;

procedure TCSpMatrR.SetAt0(ARow, ACol: integer; const Val: Complex);
var
  tmp: PCRElem;
begin
  {$IFOPT R+}
  CheckIndex(Base+ARow, Base+ACol);
  {$ENDIF}
  Col^[ARow]:= Col^[ARow] + [ACol];
  New(tmp);
  with tmp^ do begin
    C:= ACol;
    Data:= Val;
    Next:= Row^[ARow];
  end;
  if Lst^[ARow] = nil then Lst^[ARow]:= tmp;
  Row^[ARow]:= tmp;
end;

function TCSpMatrR.IsZero(ARow, ACol: integer): boolean;
begin
  {$IFOPT R+}
  CheckIndex(ARow, ACol);
  {$ENDIF}
  IsZero:= not ((ACol-Base) in Col^[ARow-Base]);
end;

function TCSpMatrR.IsZero0(ARow, ACol: integer): boolean;
begin
  {$IFOPT R+}
  CheckIndex(Base+ARow, Base+ACol);
  {$ENDIF}
  IsZero0:= not(ACol in Col^[ARow]);
end;

destructor TCSpMatrR.Destroy;
var
  old, ps: PCRElem;
  c: integer;
begin
  for c:= 0 to Rows-1 do begin
    ps:= Row^[c];
    while ps <> nil do begin
      old:= ps;
      ps:= ps^.Next;
      Dispose(old);
    end;
  end;
  FreeMem(Row, Rows * SizeOf(PCCElem));
  FreeMem(Lst, Rows * SizeOf(PCCElem));
  FreeMem(Col, Rows * SizeOf(IndxSet));
end;

initialization
  RegisterClass(TCMatrix);
  RegisterClass(TCVector);
end.

