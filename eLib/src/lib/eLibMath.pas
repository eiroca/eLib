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
unit eLibMath;

interface

uses
  SysUtils, Classes, eLibCore;

const
  cZERO  : double = 1E-20; (* Number that could be assumed like to Zero *)
  cINF   : double = 1E+20; (* Number that could be assumed like to Infinite *)

type
  PByte = ^byte;
  PDouble = ^double;
  PInteger = ^integer;

  PDoubleArr  = ^TdoubleArr;  TDoubleArr  = array[0..999999] of double;
  PIntegerArr = ^TintegerArr; TIntegerArr = array[0..999999] of integer;

type
  TMatrix = class(TComponent)
    protected
     FRowMin : integer;
     FColMin : integer;
     FRowCnt : integer;
     FColCnt : integer;
     FSize   : integer;
     FData   : pointer;
     FDigit  : integer;
     FDecim  : integer;
     FRawMode: boolean;
    private
     procedure   MemResize;
    protected
     function  GetString(Row, Col: integer): string; virtual; abstract;
     procedure SetString(Row, Col: integer; const st: string); virtual; abstract;
     procedure SetSize(vl: integer); virtual;
     procedure SetRowCnt(vl: integer); virtual;
     procedure SetColCnt(vl: integer); virtual;
     function  GetAdr(Row, Col: integer): pointer; virtual;
     function  GetIdx(Row, Col: integer): pointer; virtual;
     procedure ReadElem (R: TReader; P: pointer); virtual;
     procedure WriteElem(W: TWriter; P: pointer); virtual;
     procedure ReadData (Reader: TReader);
     procedure WriteData(Writer: TWriter);
     procedure ReadBlock(S: TStream);
     procedure WriteBlock(S: TStream);
    public
     constructor Create(AOwner: TComponent); override;
     procedure   Setup(ARowMin, ARowCnt, AColMin, AColCnt, ASize: integer);
     procedure   CheckIndex(Row, Col: integer);
     procedure   Realloc(NewRowCnt, NewColCnt: integer);
     procedure   ClearData;
     destructor  Destroy; override;
    public
     procedure   SaveToText(x: string; s, c, d, Row, Col: integer);
     procedure   LoadFromText(x: string);
     procedure   Assign(Source: TPersistent); override;
    protected
     procedure   DefineProperties(Filer: TFiler); override;
    public
     property Data: pointer read FData;
     property Adr[Row, Col: integer]: pointer read GetAdr;
     property Idx[Row, Col: integer]: pointer read GetIdx;
     property Strings[Row, Col: integer]: string read GetString write SetString;
     property Digit : integer read FDigit  write FDigit default 9;
     property Decim : integer read FDecim  write FDecim default 4;
    published
     property RawMode: boolean read FRawMode write FRawMode default true;
     property Size   : integer read FSize write SetSize default 0;
     property RowMin : integer read FRowMin write FRowMin   default 0;
     property ColMin : integer read FColMin write FColMin   default 0;
     property RowCnt : integer read FRowCnt write SetRowCnt default 0;
     property ColCnt : integer read FColCnt write SetColCnt default 0;
  end;

  TDMatrix = class(TMatrix)
    protected
     function    DataRead(Row, Col: integer): double;
     procedure   DataWrite(Row, Col: integer; const vl: double);
     function    ItemRead(Row, Col: integer): double;
     procedure   ItemWrite(Row, Col: integer; const vl: double);
     function    GetElem: PDoubleArr;
     procedure   ReadElem (R: TReader; P: pointer); override;
     procedure   WriteElem(W: TWriter; P: pointer); override;
     function    GetString(Row, Col: integer): string; override;
     procedure   SetString(Row, Col: integer; const st: string); override;
    public
     property    Data[Row, Col: integer]: double read DataRead write DataWrite; default;
     property    Item[Row, Col: integer]: double read ItemRead write ItemWrite;
     property    Elem: PDoubleArr read GetElem;
    public
     constructor Create(AOwner: TComponent); override;
     procedure   Setup(ARowMin, ARowCnt, AColMin, AColCnt: integer);
    published
     property Digit;
     property Decim;
  end;

  TIMatrix = class(TMatrix)
    protected
     function    DataRead(Row, Col: integer): integer;
     procedure   DataWrite(Row, Col: integer; const vl: integer);
     function    ItemRead(Row, Col: integer): integer;
     procedure   ItemWrite(Row, Col: integer; const vl: integer);
     function    GetElem: PIntegerArr;
     procedure   ReadElem (R: TReader; P: pointer); override;
     procedure   WriteElem(W: TWriter; P: pointer); override;
     function  GetString(Row, Col: integer): string; override;
     procedure SetString(Row, Col: integer; const st: string); override;
    public
     property    Data[Row, Col: integer]: integer read DataRead write DataWrite; default;
     property    Item[Row, Col: integer]: integer read ItemRead write ItemWrite;
     property    Elem: PIntegerArr read GetElem;
    public
     constructor Create(AOwner: TComponent); override;
     procedure   Setup(ARowMin, ARowCnt, AColMin, AColCnt: integer);
    published
     property Digit;
  end;

type
  TVector = class(TComponent)
    protected
     FRowMin : integer;
     FRowCnt : integer;
     FSize   : integer;
     FData   : pointer;
     FDigit  : integer;
     FDecim  : integer;
     FRawMode: boolean;
    private
     procedure   MemResize;
    protected
     procedure SetSize(vl: integer); virtual;
     procedure SetRowCnt(vl: integer); virtual;
     function  GetAdr(Row: integer): pointer; virtual;
     function  GetIdx(Row: integer): pointer; virtual;
     procedure ReadElem (R: TReader; P: pointer); virtual;
     procedure WriteElem(W: TWriter; P: pointer); virtual;
     procedure ReadData (Reader: TReader);
     procedure WriteData(Writer: TWriter);
     procedure ReadBlock(S: TStream);
     procedure WriteBlock(S: TStream);
     function  GetString(Row: integer): string; virtual; abstract;
     procedure SetString(Row: integer; const st: string); virtual; abstract;
    public
     constructor Create(AOwner: TComponent); override;
     procedure   Setup(ARowMin, ARowCnt, ASize: integer);
     procedure   CheckIndex(Row: integer);
     procedure   Realloc(NewRowCnt: integer);
     procedure   ClearData;
     destructor  Destroy; override;
    public
     procedure   SaveToText(x: string; s, c, d, Row: integer);
     procedure   LoadFromText(x: string);
     procedure   Assign(Source: TPersistent); override;
    protected
     procedure   DefineProperties(Filer: TFiler); override;
    public
     property Data: pointer read FData;
     property Adr[Row: integer]: pointer read GetAdr;
     property Idx[Row: integer]: pointer read GetIdx;
     property Strings[Row: integer]: string read GetString write SetString;
     property Digit : integer read FDigit  write FDigit default 9;
     property Decim : integer read FDecim  write FDecim default 4;
    published
     property RawMode: boolean read FRawMode write FRawMode default true;
     property Size: integer read FSize write SetSize;
     property RowMin: integer read FRowMin write FRowMin default 0;
     property RowCnt: integer read FRowCnt write SetRowCnt default 0;
  end;

  TDVector = class(TVector)
    protected
     function    DataRead(Row: integer): double;
     procedure   DataWrite(Row: integer; const vl: double);
     function    ItemRead(Row: integer): double;
     procedure   ItemWrite(Row: integer; const vl: double);
     function    GetElem: PDoubleArr;
     procedure   ReadElem (R: TReader; P: pointer); override;
     procedure   WriteElem(W: TWriter; P: pointer); override;
     function    GetString(Row: integer): string; override;
     procedure   SetString(Row: integer; const st: string); override;
    public
     property    Data[Row: integer]: double read DataRead write DataWrite; default;
     property    Item[Row: integer]: double read ItemRead write ItemWrite;
     property    Elem: PDoubleArr read GetElem;
    public
     constructor Create(AOwner: TComponent); override;
     procedure   Setup(ARowMin, ARowCnt: integer);
    published
     property Digit;
     property Decim;
  end;

  TIVector = class(TVector)
    protected
     function    DataRead(Row: integer): integer;
     procedure   DataWrite(Row: integer; const vl: integer);
     function    ItemRead(Row: integer): integer;
     procedure   ItemWrite(Row: integer; const vl: integer);
     function    GetElem: PIntegerArr;
     procedure   ReadElem (R: TReader; P: pointer); override;
     procedure   WriteElem(W: TWriter; P: pointer); override;
     function    GetString(Row: integer): string; override;
     procedure   SetString(Row: integer; const st: string); override;
    public
     property    Data[Row: integer]: integer read DataRead write DataWrite; default;
     property    Item[Row: integer]: integer read ItemRead write ItemWrite;
     property    Elem: PIntegerArr read GetElem;
    public
     constructor Create(AOwner: TComponent); override;
     procedure   Setup(ARowMin, ARowCnt: integer);
    published
     property Digit;
  end;

type
  PSCElem = ^TSCElem;
  TSCElem = record
    Next: PSCElem;
    Data: double;
    R   : integer;
  end;

  PSRElem = ^TSRElem;
  TSRElem = record
    Next: PSRElem;
    Data: double;
    C   : integer;
  end;

  Indx = 0..255;
  IndxSet = Set of Indx;

  PSCols = ^TSCols;
  TSCols = array[0..255] of PSCElem;

  PSRows = ^TSRows;
  TSRows = array[0..255] of PSRElem;

  PRows = ^TRows;
  TRows = array[0..255] of IndxSet;

  PCols = ^TCols;
  TCols = array[0..255] of IndxSet;

  TSSpMatrC = class
    private
     function    GetAt (ARow, ACol: integer): double;
     function    GetAt0(ARow, ACol: integer): double;
     procedure   SetAt (ARow, ACol: integer; Val: double);
     procedure   SetAt0(ARow, ACol: integer; Val: double);
     function    TakeAt (ARow, ACol: integer): double;
     function    TakeAt0(ARow, ACol: integer): double;
     procedure   CheckIndex(Row, Col: integer);
    public
     Col: PSCols;
     Lst: PSCols;
     Row: PCols;
     Rows: integer;
     Cols: integer;
     Base: integer;
     constructor Create(ABase, ARow, ACol: integer);
     property    Data[ARow, ACol: integer]: double read GetAt write SetAt; default;
     property    Item[ARow, ACol: integer]: double read GetAt0 write SetAt0;
     property    Take[ARow, ACol: integer]: double read TakeAt write SetAt;
     property    Take0[ARow, ACol: integer]: double read TakeAt0 write SetAt0;
     function    IsZero (ARow, ACol: integer): boolean;
     function    IsZero0(ARow, ACol: integer): boolean;
     destructor  Destroy; override;
   end;

  TSSpMatrR = class
    private
     function    GetAt (ARow, ACol: integer): double;
     function    GetAt0(ARow, ACol: integer): double;
     procedure   SetAt (ARow, ACol: integer; Val: double);
     procedure   SetAt0(ARow, ACol: integer; Val: double);
     function    TakeAt (ARow, ACol: integer): double;
     function    TakeAt0(ARow, ACol: integer): double;
     procedure   CheckIndex(Row, Col: integer);
    public
     Col: PRows;
     Lst: PSRows;
     Row: PSRows;
     Rows: integer;
     Cols: integer;
     Base: integer;
     constructor Create(ABase, ARow, ACol: integer);
     property    Data[ARow, ACol: integer]: double read GetAt write SetAt; default;
     property    Item[ARow, ACol: integer]: double read GetAt0 write SetAt0;
     property    Take[ARow, ACol: integer]: double read TakeAt write SetAt;
     property    Take0[ARow, ACol: integer]: double read TakeAt0 write SetAt0;
     function    IsZero (ARow, ACol: integer): boolean;
     function    IsZero0(ARow, ACol: integer): boolean;
     destructor  Destroy; override;
   end;

const

  ERR_NOTCOMP = -1;
  ERR_SINGULA = -2;

type
  Matrix = class
    class function IsZero(var A: TDMatrix): boolean; static;
    class function Clone(var A: TDMatrix): TDMatrix; static;
    class function Inv(var MO, MI: TDMatrix): integer; static;
    class function InvFast(var MO, M: TDMatrix): integer; static;
    class function MakeInv(var MI: TDMatrix): TDMatrix; static;
    class function Mul(var MO, MA, MB: TDMatrix): integer; static;
    class function MulXtY(var MO, MA, MB: TDMatrix): integer; static;
    class function MulXtYNRR(var MO, MA, MB: TDMatrix): integer;  static; (* ricalcola MO dopo aver aggiunto una riga a MA e MB *)
    class function MulXtYNCx(var MO, MA, MB: TDMatrix): integer;  static; (* ricalcola MO dopo aver aggiunto una colonna a MA   *)
    class function MakeMul(var MA, MB: TDMatrix): TMatrix; static;
    class function MulXtX(var MO, MI: TDMatrix): integer; static;
    class function MulXtXNR(var MO, MI: TDMatrix): integer; static; (* ricalcola MO dopo aver aggiunto una riga a MI *)
    class function MulXtXNC(var MO, MI: TDMatrix): integer; static; (* ricalcola MO dopo aver aggiunto una colonna a MI *)
    class function MulXXt(var MO, MI: TDMatrix): integer; static;
    class function Vec(var r: TDVector; var A: TDMatrix; var x: TDVector): integer; static;
    class function Tra(var MO, MI: TDMatrix): integer; static;
    class function InvTriSup(var MO, MI: TDMatrix): integer; static;
    class function InvTriInf(var MO, MI: TDMatrix): integer; static;
    class function DetTri(var A: TDMatrix; var det: double): integer; static;
    class function Zero(var A: TDMatrix): integer; static;
    class function Add(var MO, MI: TDMatrix): integer; static;
    class function MulSca(var A: TDMatrix; val: double): integer; static;
    class function SortRow(var MA: TDMatrix; Col: integer): integer; static;
    class function SortCol(var MA: TDMatrix; Row: integer): integer; static;
    class function SortRows(var MA: TDMatrix): integer; static;
    class function FactorGAU(var Coef: TDMatrix; var Pivot: TIVector; var Determ: double): integer; static;
    class function FactorGAU2(var Cof: TDMatrix; var Coef: TDMatrix;  var Pivot: TIVector; var Determ: double): integer; static;
    class function  SolveGAU(var Coef: TDMatrix; var Pivot: TIVector; var TermNoti, Soluzione: TDVector): integer; static;
    class function MSolveGAU(var Coef: TDMatrix; var Pivot: TIVector; var TermNoti, Soluzione: TDMatrix; col: integer): integer; static;
    class function SolvSing(var Coef: TDMatrix; var TN, Sol: TDVector): integer; static;
    class function IMatMul(var MO, MA, MB: TIMatrix): integer; static;

    class function mat_lu(var A: TDMatrix; var P: TIVector): integer; static;
    class procedure mat_backsubs1(var A: TDMatrix; var B, X: TDMatrix; var P: TIVector; xcol: integer); static;
  end;

implementation

constructor TMatrix.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRawMode:= true;
  FRowCnt:= 0;
  FRowMin:= 0;
  FColCnt:= 0;
  FColMin:= 0;
  FData:= nil;
  FSize:= 0;
  FDigit:= 9;
  FDecim:= 4;
  MemResize;
  ClearData;
end;

procedure TMatrix.MemResize;
begin
  ReallocMem(FData, FRowCnt * FColCnt * Size);
end;

procedure TMatrix.ClearData;
begin
  if FData <> nil then begin
    FillChar(FData^, FRowCnt * FColCnt * Size, 0);
  end;
end;

procedure TMatrix.Setup(ARowMin, ARowCnt, AColMin, AColCnt, ASize: integer);
begin
  FSize:= ASize;
  FRowMin:= ARowMin;
  FRowCnt:= ARowCnt;
  FColMin:= AColMin;
  FColCnt:= AColCnt;
  MemResize;
  ClearData;
end;

procedure TMatrix.CheckIndex;
begin
  if (Row<RowMin) or (Row>=RowCnt+RowMin) or
     (Col<ColMin) or (Col>=ColCnt+ColMin) then
    raise ERangeError.CreateFmt('Bad array index %s[%d,%d]', [Name, Row,Col]);
end;

procedure TMatrix.Realloc(NewRowCnt, NewColCnt: integer);
var
  i: integer;
  NewData: PByte;
  OldDataPtr: PByte;
  NewDataPtr: PByte;
  NewOfs, OldOfs: integer;
  r, c: integer;
begin
  if (NewRowCnt <> RowCnt) or (NewColCnt <> ColCnt) then begin
    NewData:= nil;
    ReallocMem(NewData, NewRowCnt * NewColCnt * Size);
    if NewData <> nil then begin
      FillChar(NewData^, NewRowCnt * NewColCnt * Size, 0);
      OldOfs:= ColCnt * Size;
      NewOfs:= NewColCnt * Size;
      if NewRowCnt < RowCnt then r:= NewRowCnt else r:= RowCnt;
      if NewColCnt < ColCnt then c:= NewColCnt*Size else c:= ColCnt*Size;
      OldDataPtr:= Data;
      NewDataPtr:= NewData;
      for i:= 0 to r-1 do begin
        Move(OldDataPtr^, NewDataPtr^, c);
        inc(NewDataPtr, NewOfs);
        inc(OldDataPtr, OldOfs);
      end;
    end;
    ReallocMem(FData, 0);
    FData:= NewData;
    FRowCnt:= NewRowCnt;
    FColCnt:= NewColCnt;
  end;
end;

procedure TMatrix.SetSize(vl: integer);
begin
  FSize:= vl;
  MemResize;
end;

procedure TMatrix.SetRowCnt(vl: integer);
begin
  FRowCnt:= vl;
  MemResize;
end;

procedure TMatrix.SetColCnt(vl: integer);
begin
  FColCnt:= vl;
  MemResize;
end;

function TMatrix.GetAdr(Row, Col: integer): pointer;
begin
  {$IFOPT R+}
  CheckIndex(Row, Col);
  {$ENDIF}
  Result:= FData;
  inc(PByte(Result), ((Col-ColMin)+ColCnt*(Row-RowMin))*Size);
end;

function TMatrix.GetIdx(Row, Col: integer): pointer;
begin
  {$IFOPT R+}
  CheckIndex(RowMin+Row, ColMin+Col);
  {$ENDIF}
  Result:= FData;
  inc(PByte(Result), (Col+ColCnt*Row)*Size);
end;

procedure TMatrix.Assign(Source: TPersistent);
var
  M: TMatrix;
begin
  if Source is TMatrix then begin
    M:= TMatrix(Source);
    Setup(M.RowMin, M.RowCnt, M.ColMin, M.ColCnt, M.Size);
    Digit:= M.Digit;
    Decim:= M.Decim;
    RawMode:= M.RawMode;
    if (Data <> nil) and (M.Data<>nil) then begin
      Move(M.Data^, Data^, FRowCnt * FColCnt * Size);
    end;
  end
  else inherited ;
end;

procedure TMatrix.ReadElem(R: TReader; P: pointer);
var
  PC: PByte;
  l: integer;
begin
  PC:= P;
  for l:= 1 to Size do begin
    PC^:= ord(R.ReadChar);
    inc(PC);
  end;
end;

procedure TMatrix.WriteElem(W: TWriter; P: pointer);
var
  PC: PByte;
  l: integer;
begin
  PC:= P;
  for l:= 1 to Size do begin
    W.WriteChar(chr(PC^));
    inc(PC);
  end;
end;

procedure TMatrix.ReadBlock(S: TStream);
begin
  if Data <> nil then begin
    S.Read(Data^, FRowCnt * FColCnt * Size);
  end;
end;

procedure TMatrix.WriteBlock(S: TStream);
begin
  if Data <> nil then begin
    S.Write(Data^, FRowCnt * FColCnt * Size);
  end;
end;

procedure TMatrix.ReadData(Reader: TReader);
var
  r, c: integer;
  P: PByte;
begin
  P:= Data;
  Reader.ReadListBegin;
  for r:= 0 to RowCnt-1 do begin
    Reader.ReadListBegin;
    if not Reader.EndOfList then begin
      for c:= 0 to ColCnt-1 do begin
        if not Reader.EndOfList then ReadElem(Reader, P);
        inc(P, Size);
      end;
    end;
    Reader.ReadListEnd;
  end;
  Reader.ReadListEnd;
end;

procedure TMatrix.WriteData(Writer: TWriter);
var
  r, c: integer;
  P: PByte;
begin
  P:= Data;
  Writer.WriteListBegin;
  for r:= 0 to RowCnt-1 do begin
    Writer.WriteListBegin;
    for c:= 0 to ColCnt-1 do begin
      WriteElem(Writer, P);
      inc(P, Size);
    end;
    Writer.WriteListEnd;
  end;
  Writer.WriteListEnd;
end;

procedure TMatrix.DefineProperties(Filer: TFiler);
begin
  if RawMode then begin
    Filer.DefineBinaryProperty('RawData', ReadBlock, WriteBlock, Data<>nil);
  end
  else begin
    Filer.DefineProperty('Data', ReadData, WriteData, Data<>nil);
  end;
  inherited DefineProperties(Filer);
end;

procedure TMatrix.SaveToText(x: string; s, c, d, Row, Col: integer);
var
  ps, i, j: integer;
  fil: text;
  st: string;
begin
  if s = 0 then s:= 80;
  if c = 0 then c:= Digit;
  if d = 0 then d:= Decim;
  if Row = 0 then Row:= RowCnt;
  if Col = 0 then Col:= ColCnt;
  AssignFile(fil, x);
  {$I-} append(fil); {$I+} if IOResult <> 0 then ReWrite(fil);
  writeln(fil);
  if x = '' then writeln(fil, 'Matrice ', Row, 'x', Col)
  else begin
    writeln(fil,'MATRICE');
    writeln(fil,'Righe  : ', Row);
    writeln(fil,'Colonne: ', Col);
  end;
  Digit:= c;
  Decim:= d;
  for i:= RowMin to RowMin+RowCnt-1 do begin
    ps:= c+1;
    for j:= ColMin to ColMin+ColCnt-1 do begin
      st:= Strings[i, j];
      write(fil, st, ' ');
      inc(ps, c+1);
      if ps > s then begin
        writeln(fil);
        ps:= c+1;
      end;
    end;
    writeln(fil);
  end;
  Close(fil);
end;

procedure TMatrix.LoadFromText(x: string);
var
  NumRow, NumCol: integer;
  ir, ic: integer;
  ch: char;
  fin: text;
  st: string;
  procedure StPoint;
  begin
    ch:= #0;
    repeat
      if eof(fIn) then exit;
      Read(fIn, ch);
    until (ch=':');
  end;
begin
  AssignFile(fIn, x);
  Reset(fIn);
  (* cerca il primo : *)
  if x = '' then Write('Numero delle righe: ') else StPoint;
  Readln(fIN, NumRow);
  if x = '' then Write('Numero delle colonne: ') else StPoint;
  Readln(fIn, NumCol);
  RowMin:= 0; RowCnt:= NumRow;
  ColMin:= 0; ColCnt:= NumCol;
  ClearData;
  if x = '' then begin
    writeln('Inserire tutti gli elementi: A11, A12, .., A21, A22, ... Ann');
    writeln;
    for ir:= 0 to NumRow-1 do begin
      for ic:= 0 to NumCol-1 do begin
        Write('Elemento (',ir+1:3,',',ic+1:3,') = ');
        readln(fIn,st);
        Strings[ir,ic]:= st;
      end;
   end;
  end
  else begin
    for ir:= 0 to NumRow-1 do begin
      for ic:= 0 to NumCol-1 do begin
        st:= '';
        while st = '' do begin
          readln(fIn, st);
          st:= Trim(st);
        end;
        Strings[ir,ic]:= st;
      end;
    end;
  end;
  Close(fIn);
end;

destructor TMatrix.Destroy;
begin
  ReallocMem(FData, 0);
  inherited Destroy;
end;

constructor TDMatrix.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSize:= SizeOf(double);
end;

function TDMatrix.GetString;
begin
  Result:= Format('%*.*f', [Digit,Decim,Data[Row, Col]]);
end;

procedure TDMatrix.SetString(Row, Col: integer; const st: string);
begin
  Data[Row, Col]:= StrToFloat(Trim(st));
end;

procedure TDMatrix.ReadElem (R: TReader; P: pointer);
begin
  Pdouble(P)^:= R.ReadFloat;
end;

procedure TDMatrix.WriteElem(W: TWriter; P: pointer);
begin
  W.WriteFloat(Pdouble(P)^);
end;

procedure TDMatrix.Setup(ARowMin, ARowCnt, AColMin, AColCnt: integer);
begin
  inherited Setup(ARowMin, ARowCnt, AColMin, AColCnt, SizeOf(double));
end;

function TDMatrix.GetElem: PDoubleArr;
begin
  Result:= PDoubleArr(FData);
end;

function TDMatrix.DataRead(Row, Col: integer): double;
begin
  {$IFOPT R+}
  CheckIndex(Row, Col);
  {$ENDIF}
  Result:= PDoubleArr(FData)^[(Col-ColMin)+ColCnt*(Row-RowMin)];
end;

procedure TDMatrix.DataWrite(Row, Col: integer; const vl: double);
begin
  {$IFOPT R+}
  CheckIndex(Row, Col);
  {$ENDIF}
  PDoubleArr(FData)^[(Col-ColMin)+ColCnt*(Row-RowMin)]:= vl;
end;

function TDMatrix.ItemRead(Row, Col: integer): double;
begin
  {$IFOPT R+}
  CheckIndex(RowMin+Row, ColMin+Col);
  {$ENDIF}
  Result:= PDoubleArr(FData)^[Col+ColCnt*Row];
end;

procedure TDMatrix.ItemWrite(Row, Col: integer; const vl: double);
begin
  {$IFOPT R+}
  CheckIndex(RowMin+Row, ColMin+Col);
  {$ENDIF}
  PDoubleArr(FData)^[Col+ColCnt*Row]:= vl;
end;

constructor TIMatrix.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSize:= SizeOf(integer);
end;

function TIMatrix.GetString;
begin
  Result:= Format('%*d', [Digit,Data[Row, Col]]);
end;

procedure TIMatrix.SetString(Row, Col: integer; const st: string);
begin
  Data[Row, Col]:= StrToInt(Trim(st));
end;


procedure TIMatrix.ReadElem (R: TReader; P: pointer);
begin
  PInteger(P)^:= R.ReadInteger;
end;

procedure TIMatrix.WriteElem(W: TWriter; P: pointer);
begin
  W.WriteInteger(PInteger(P)^);
end;

procedure TIMatrix.Setup(ARowMin, ARowCnt, AColMin, AColCnt: integer);
begin
  inherited Setup(ARowMin, ARowCnt, AColMin, AColCnt, SizeOf(integer));
end;

function TIMatrix.GetElem: PIntegerArr;
begin
  Result:= PIntegerArr(FData);
end;

function TIMatrix.DataRead(Row, Col: integer): integer;
begin
  {$IFOPT R+}
  CheckIndex(Row, Col);
  {$ENDIF}
  Result:= PIntegerArr(FData)^[(Col-ColMin)+ColCnt*(Row-RowMin)];
end;

procedure TIMatrix.DataWrite(Row, Col: integer; const vl: integer);
begin
  {$IFOPT R+}
  CheckIndex(Row, Col);
  {$ENDIF}
  PIntegerArr(FData)^[(Col-ColMin)+ColCnt*(Row-RowMin)]:= vl;
end;

function TIMatrix.ItemRead(Row, Col: integer): integer;
begin
  {$IFOPT R+}
  CheckIndex(RowMin+Row, ColMin+Col);
  {$ENDIF}
  Result:= PIntegerArr(FData)^[Col+ColCnt*Row];
end;

procedure TIMatrix.ItemWrite(Row, Col: integer; const vl: integer);
begin
  {$IFOPT R+}
  CheckIndex(RowMin+Row, ColMin+Col);
  {$ENDIF}
  PIntegerArr(FData)^[Col+ColCnt*Row]:= vl;
end;

constructor TVector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRawMode:= true;
  FRowCnt:= 0;
  FRowMin:= 0;
  FData:= nil;
  FSize:= 0;
  FDigit:= 9;
  FDecim:= 4;
  MemResize;
  ClearData;
end;

procedure TVector.MemResize;
begin
  ReallocMem(FData, FRowCnt * Size);
end;

procedure TVector.ClearData;
begin
  if FData <> nil then begin
    FillChar(FData^, FRowCnt * Size, 0);
  end;
end;

procedure TVector.Setup(ARowMin, ARowCnt, ASize: integer);
begin
  FSize:= ASize;
  FRowMin:= ARowMin;
  FRowCnt:= ARowCnt;
  MemResize;
  ClearData;
end;

procedure TVector.CheckIndex;
begin
  if (Row<RowMin) or (Row>=RowCnt+RowMin) then
    raise ERangeError.CreateFmt('Bad array index %s[%d]', [Name, Row]);
end;

procedure TVector.SetSize(vl: integer);
begin
  FSize:= vl;
  MemResize;
end;

procedure TVector.SetRowCnt(vl: integer);
begin
  FRowCnt:= vl;
  MemResize;
end;

function TVector.GetAdr(Row: integer): pointer;
begin
  {$IFOPT R+}
  CheckIndex(Row);
  {$ENDIF}
  Result:= FData;
  inc(PByte(Result), (Row-RowMin)*Size);
end;

function TVector.GetIdx(Row: integer): pointer;
begin
  {$IFOPT R+}
  CheckIndex(RowMin+Row);
  {$ENDIF}
  Result:= FData;
  inc(PByte(Result), (Row)*Size);
end;

procedure TVector.Assign(Source: TPersistent);
var
  M: TVector;
begin
  if Source is TVector then begin
    M:= TVector(Source);
    Setup(M.RowMin, M.RowCnt, M.Size);
    RawMode:= M.RawMode;
    Digit:= M.Digit;
    Decim:= M.Decim;
    if (Data <> nil) and (M.Data<>nil) then begin
      Move(M.Data^, Data^, FRowCnt * Size);
    end;
  end
  else inherited ;
end;

procedure TVector.ReadElem(R: TReader; P: pointer);
var
  PC: PByte;
  l: integer;
begin
  PC:= P;
  for l:= 1 to Size do begin
    PC^:= ord(R.ReadChar);
    inc(PC);
  end;
end;

procedure TVector.WriteElem(W: TWriter; P: pointer);
var
  PC: PByte;
  l: integer;
begin
  PC:= P;
  for l:= 1 to Size do begin
    W.WriteChar(chr(PC^));
    inc(PC);
  end;
end;

procedure TVector.ReadBlock(S: TStream);
begin
  if Data <> nil then begin
    S.Read(Data^, FRowCnt * Size);
  end;
end;

procedure TVector.WriteBlock(S: TStream);
begin
  if Data <> nil then begin
    S.Write(Data^, FRowCnt * Size);
  end;
end;

procedure TVector.ReadData(Reader: TReader);
var
  r: integer;
  P: PByte;
begin
  P:= Data;
  Reader.ReadListBegin;
  for r:= 0 to RowCnt-1 do begin
    if not Reader.EndOfList then ReadElem(Reader, P);
    inc(P, Size);
  end;
  Reader.ReadListEnd;
end;

procedure TVector.WriteData(Writer: TWriter);
var
  r: integer;
  P: PByte;
begin
  P:= Data;
  Writer.WriteListBegin;
  for r:= 0 to RowCnt-1 do begin
    WriteElem(Writer, P);
    inc(P, Size);
  end;
  Writer.WriteListEnd;
end;

procedure TVector.DefineProperties(Filer: TFiler);
begin
  if RawMode then begin
    Filer.DefineBinaryProperty('RawData', ReadBlock, WriteBlock, Data<>nil);
  end
  else begin
    Filer.DefineProperty('Data', ReadData, WriteData, Data<>nil);
  end;
  inherited DefineProperties(Filer);
end;

procedure TVector.Realloc(NewRowCnt: integer);
var
  NewData: PByte;
  r: integer;
begin
  if (NewRowCnt <> RowCnt) then begin
    NewData:= nil;
    ReallocMem(NewData, NewRowCnt * Size);
    if NewData <> nil then begin
      if NewRowCnt < RowCnt then begin
        r:= NewRowCnt*Size;
      end
      else begin
        FillChar(NewData^, NewRowCnt * Size, 0);
        r:= RowCnt*Size;
      end;
      Move(Data^, NewData^, r);
    end;
    ReallocMem(FData, 0);
    FData:= NewData;
    FRowCnt:= NewRowCnt;
  end;
end;

procedure TVector.SaveToText(x: string; s, c, d, Row: integer);
var
  ps, i: integer;
  fil: text;
  st: string;
begin
  if s = 0 then s:= 80;
  if c = 0 then c:= Digit;
  if d = 0 then d:= Decim;
  if Row = 0 then Row:= RowCnt;
  AssignFile(fil, x);
  {$I-} append(fil); {$I+} if IOResult <> 0 then ReWrite(fil);
  writeln(fil);
  if x = '' then writeln(fil, 'Vettore ', Row)
  else begin
    writeln(fil,'VETTORE');
    writeln(fil,'Righe  : ', Row);
  end;
  Digit:= c;
  Decim:= d;
  ps:= c+1;
  for i:= RowMin to RowMin+RowCnt-1 do begin
    st:= Strings[i];
    write(fil, st, ' ');
    ps:= ps+ (c+1);
    if ps > s then begin
      writeln(fil);
      ps:= c+1;
    end;
    writeln(fil);
  end;
  Close(fil);
end;

procedure TVector.LoadFromText(x: string);
var
  NumRow: integer;
  ir: integer;
  ch: char;
  fin: text;
  st: string;
  procedure StPoint;
  begin
    ch:= #0;
    repeat
      if eof(fIn) then exit;
      Read(fIn, ch);
    until (ch=':');
  end;
begin
  AssignFile(fIn, x);
  Reset(fIn);
  (* cerca il primo : *)
  if x = '' then Write('Numero delle righe: ') else StPoint;
  Readln(fIN, NumRow);
  RowMin:= 0; RowCnt:= NumRow;
  ClearData;
  if x = '' then begin
    writeln('Inserire tutti gli elementi: A1, A2, .., An');
    writeln;
    for ir:= 0 to NumRow-1 do begin
      Write('Elemento (',ir+1:3,') = ');
      readln(fIn,st);
      Strings[ir]:= st;
   end;
  end
  else begin
    for ir:= 0 to NumRow-1 do begin
      st:= '';
      while st = '' do begin
        readln(fIn, st);
        st:= Trim(st);
      end;
      Strings[ir]:= st;
    end;
  end;
  Close(fIn);
end;

destructor TVector.Destroy;
begin
  ReallocMem(FData, 0);
  inherited Destroy;
end;

constructor TDVector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSize:= SizeOf(double);
end;

function TDVector.GetString;
begin
  Result:= Format('%*.*f', [Digit,Decim,Data[Row]]);
end;

procedure TDVector.SetString(Row: integer; const st: string);
begin
  Data[Row]:= StrToFloat(Trim(st));
end;

procedure TDVector.ReadElem (R: TReader; P: pointer);
begin
  Pdouble(P)^:= R.ReadFloat;
end;

procedure TDVector.WriteElem(W: TWriter; P: pointer);
begin
  W.WriteFloat(Pdouble(P)^);
end;

procedure TDVector.Setup(ARowMin, ARowCnt: integer);
begin
  inherited Setup(ARowMin, ARowCnt, SizeOf(double));
end;

function TDVector.GetElem: PDoubleArr;
begin
  Result:= PDoubleArr(FData);
end;

function TDVector.DataRead(Row: integer): double;
begin
  {$IFOPT R+}
  CheckIndex(Row);
  {$ENDIF}
  Result:= PDoubleArr(FData)^[(Row-RowMin)];
end;

procedure TDVector.DataWrite(Row: integer; const vl: double);
begin
  {$IFOPT R+}
  CheckIndex(Row);
  {$ENDIF}
  PDoubleArr(FData)^[(Row-RowMin)]:= vl;
end;

function TDVector.ItemRead(Row: integer): double;
begin
  {$IFOPT R+}
  CheckIndex(RowMin+Row);
  {$ENDIF}
  Result:= PDoubleArr(FData)^[Row];
end;

procedure TDVector.ItemWrite(Row: integer; const vl: double);
begin
  {$IFOPT R+}
  CheckIndex(RowMin+Row);
  {$ENDIF}
  PDoubleArr(FData)^[Row]:= vl;
end;

constructor TIVector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSize:= SizeOf(integer);
end;

function TIVector.GetString;
begin
  Result:= Format('%*d', [Digit,Data[Row]]);
end;

procedure TIVector.SetString(Row: integer; const st: string);
begin
  Data[Row]:= StrToInt(Trim(st));
end;

procedure TIVector.ReadElem (R: TReader; P: pointer);
begin
  PInteger(P)^:= R.ReadInteger;
end;

procedure TIVector.WriteElem(W: TWriter; P: pointer);
begin
  W.WriteInteger(PInteger(P)^);
end;

procedure TIVector.Setup(ARowMin, ARowCnt: integer);
begin
  inherited Setup(ARowMin, ARowCnt, SizeOf(integer));
end;

function TIVector.GetElem: PIntegerArr;
begin
  Result:= PIntegerArr(FData);
end;

function TIVector.DataRead(Row: integer): integer;
begin
  {$IFOPT R+}
  CheckIndex(Row);
  {$ENDIF}
  Result:= PIntegerArr(FData)^[(Row-RowMin)];
end;

procedure TIVector.DataWrite(Row: integer; const vl: integer);
begin
  {$IFOPT R+}
  CheckIndex(Row);
  {$ENDIF}
  PIntegerArr(FData)^[(Row-RowMin)]:= vl;
end;

function TIVector.ItemRead(Row: integer): integer;
begin
  {$IFOPT R+}
  CheckIndex(RowMin+Row);
  {$ENDIF}
  Result:= PIntegerArr(FData)^[Row];
end;

procedure TIVector.ItemWrite(Row: integer; const vl: integer);
begin
  {$IFOPT R+}
  CheckIndex(RowMin+Row);
  {$ENDIF}
  PIntegerArr(FData)^[Row]:= vl;
end;

constructor TSSpMatrC.Create(ABase, ARow, ACol: integer);
var
  c: integer;
begin
  Rows:= ARow;
  Cols:= ACol;
  Base:= ABase;
  GetMem(Col, ACol * SizeOf(PSCElem));
  GetMem(Lst, ACol * SizeOf(PSCElem));
  GetMem(Row, ACol * SizeOf(IndxSet));
  for c:= 0 to Cols-1 do begin
    Row^[c]:= [];
    Col^[c]:= nil;
    Lst^[c]:= nil;
  end;
end;

function TSSpMatrC.GetAt0(ARow, ACol: integer): double;
var
  Old, ps: PSCElem;
begin
  {$IFOPT R+}
  CheckIndex(Base+ARow, Base+ACol);
  {$ENDIF}
  if IsZero0(ARow, ACol) then Result:= 0
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

function TSSpMatrC.GetAt(ARow, ACol: integer): double;
var
  Old, ps: PSCElem;
begin
  {$IFOPT R+}
  CheckIndex(ARow, ACol);
  {$ENDIF}
  Dec(ARow, Base);
  Dec(ACol, Base);
  if IsZero0(ARow, ACol) then GetAt:= 0
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

function TSSpMatrC.TakeAt0(ARow, ACol: integer): double;
var
  Old, ps: PSCElem;
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
  if ps <> nil then TakeAt0:= ps^.Data else Result:= 0;
  if Old <> nil then begin
    Lst^[ACol]^.Next:= Col^[ACol];
    Col^[ACol]:= ps;
    Old^.Next:= nil;
    Lst^[ACol]:= Old;
  end;
end;

procedure TSSpMatrC.CheckIndex(Row, Col: integer);
begin
end;

function TSSpMatrC.TakeAt(ARow, ACol: integer): double;
var
  Old, ps: PSCElem;
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
  if ps <> nil then TakeAt:= ps^.Data else Result:= 0;
  if Old <> nil then begin
    Lst^[ACol]^.Next:= Col^[ACol];
    Col^[ACol]:= ps;
    Old^.Next:= nil;
    Lst^[ACol]:= Old;
  end;
end;

procedure TSSpMatrC.SetAt(ARow, ACol: integer; Val: double);
var
  tmp: PSCElem;
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

procedure TSSpMatrC.SetAt0(ARow, ACol: integer; Val: double);
var
  tmp: PSCElem;
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

function TSSpMatrC.IsZero(ARow, ACol: integer): boolean;
begin
  {$IFOPT R+}
  CheckIndex(ARow, ACol);
  {$ENDIF}
  IsZero:= not ((ARow-Base) in Row^[ACol-Base]);
end;

function TSSpMatrC.IsZero0(ARow, ACol: integer): boolean;
begin
  {$IFOPT R+}
  CheckIndex(Base+ARow, Base+ACol);
  {$ENDIF}
  IsZero0:= not(ARow in Row^[ACol]);
end;

destructor TSSpMatrC.Destroy;
var
  old, ps: PSCElem;
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
  FreeMem(Col, Cols * SizeOf(PSCElem));
  FreeMem(Lst, Cols * SizeOf(PSCElem));
  FreeMem(Row, Cols * SizeOf(IndxSet));
end;

constructor TSSpMatrR.Create(ABase, ARow, ACol: integer);
var
  c: integer;
begin
  Rows:= ARow;
  Cols:= ACol;
  Base:= ABase;
  GetMem(Col, ARow * SizeOf(PSRElem));
  GetMem(Lst, ARow * SizeOf(PSRElem));
  GetMem(Row, ARow * SizeOf(IndxSet));
  for c:= 0 to Rows-1 do begin
    Col^[c]:= [];
    Row^[c]:= nil;
    Lst^[c]:= nil;
  end;
end;

function TSSpMatrR.GetAt0(ARow, ACol: integer): double;
var
  Old, ps: PSRElem;
begin
  {$IFOPT R+}
  CheckIndex(Base+ARow, Base+ACol);
  {$ENDIF}
  if IsZero0(ARow, ACol) then GetAt0:= 0
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

function TSSpMatrR.GetAt(ARow, ACol: integer): double;
var
  Old, ps: PSRElem;
begin
  {$IFOPT R+}
  CheckIndex(ARow, ACol);
  {$ENDIF}
  Dec(ARow, Base);
  Dec(ACol, Base);
  if IsZero0(ARow, ACol) then Result:= 0
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

procedure TSSpMatrR.CheckIndex(Row, Col: integer);
begin
end;

function TSSpMatrR.TakeAt0(ARow, ACol: integer): double;
var
  Old, ps: PSRElem;
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
  if ps <> nil then TakeAt0:= ps^.Data else TakeAt0:= 0;
  if Old <> nil then begin
    Lst^[ARow]^.Next:= Row^[ARow];
    Row^[ARow]:= ps;
    Old^.Next:= nil;
    Lst^[ARow]:= Old;
  end;
end;

function TSSpMatrR.TakeAt(ARow, ACol: integer): double;
var
  Old, ps: PSRElem;
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
  if ps <> nil then TakeAt:= ps^.Data else TakeAt:= 0;
  if Old <> nil then begin
    Lst^[ARow]^.Next:= Row^[ARow];
    Row^[ARow]:= ps;
    Old^.Next:= nil;
    Lst^[ARow]:= Old;
  end;
end;

procedure TSSpMatrR.SetAt(ARow, ACol: integer; Val: double);
var
  tmp: PSRElem;
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

procedure TSSpMatrR.SetAt0(ARow, ACol: integer; Val: double);
var
  tmp: PSRElem;
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

function TSSpMatrR.IsZero(ARow, ACol: integer): boolean;
begin
  {$IFOPT R+}
  CheckIndex(ARow, ACol);
  {$ENDIF}
  IsZero:= not ((ACol-Base) in Col^[ARow-Base]);
end;

function TSSpMatrR.IsZero0(ARow, ACol: integer): boolean;
begin
  {$IFOPT R+}
  CheckIndex(Base+ARow, Base+ACol);
  {$ENDIF}
  IsZero0:= not(ACol in Col^[ARow]);
end;

destructor TSSpMatrR.Destroy;
var
  old, ps: PSRElem;
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
  FreeMem(Row, Rows * SizeOf(PSCElem));
  FreeMem(Lst, Rows * SizeOf(PSCElem));
  FreeMem(Col, Rows * SizeOf(IndxSet));
end;

class function Matrix.IsZero(var A: TDMatrix): boolean;
var
  r, c: integer;
begin
  Result:= true;
  for r:= 0 to pred(A.RowCnt) do begin
    for c:= 0 to pred(A.ColCnt) do begin
      if abs(A.Item[r, c]) < cZERO then begin
        A.Item[r,c]:= 0;
      end
      else begin
        Result:= false;
      end;
    end;
  end;
end;

class function Matrix.Clone(var A: TDMatrix): TDMatrix;
var
  M: TDMatrix;
begin
  M:= TDMatrix.Create(nil);
  Result:= M;
  if M = nil then exit;
  M.Assign(A);
  IsZero(M);
end;

class function Matrix.Inv(var MO, MI: TDMatrix): integer;
var
  i, j, k, l: integer;
  r : integer;
  p: integer;
  mx: double;
  t: double;
  M: TDMatrix;
begin
  r:= MI.RowCnt;
  if (r <> MI.ColCnt) or (r <> MO.ColCnt) or (r <> MO.RowCnt) then begin
    Result:= ERR_NOTCOMP;
    exit;
  end;
  M:= TDMatrix.Create(nil);
  M.Assign(MI);
  dec(r);
  for i:= 0 to r do begin
    for j:= 0 to r do begin
      if i = j then t:= 1.0 else t:= 0.0;
      MO.Item[i, j]:= t;
    end;
  end;
  for J:= 0 to R do begin
    p:= -1; mx:= 0;
    for I:= J to R do begin
      if abs(M.Item[i, j]) > mx then begin p:= I; mx:= abs(M.Item[i, j]); end;
    end;
    if mx < 10e-20 then begin
      Result:= ERR_SINGULA;
      M.Free;
      exit;
    end;
    I:= p;
    if I <> J then begin
      for K:= 0 to R do begin
        t:= M.Item[J, K];
        M.Item[J, K]:= M.Item[I, K];
        M.Item[I, K]:= t;
        t:= MO.Item[J, K];
        MO.Item[J, K]:= MO.Item[I, K];
        MO.Item[I, K]:= t;
      end;
    end;
    t:= 1 / M.Item[J, J];
    for K:= 0 to R do begin
      M.Item[J, K]:= t * M.Item[J, K];
      MO.Item[J, K]:= t * MO.Item[J, K];
    end;
    for L:= 0 to R do begin
      if L <> J then begin
        T:= -M.Item[L, J];
        for K:= 0 to R do begin
          M.Item[L, K]:= M.Item[L, K] + T * M.Item[J, K];
          MO.Item[L, K]:= MO.Item[L, K] + T * MO.Item[J, K];
        end;
      end;
    end;
  end;
  Result:= 0;
  M.Free;
end;

class function Matrix.InvFast(var MO, M: TDMatrix): integer;
var
  i, j, k, l: integer;
  r : integer;
  p: integer;
  mx: double;
  t: double;
begin
  r:= M.RowCnt;
  if (r <> M.ColCnt) or (r <> MO.ColCnt) or (r <> MO.RowCnt) then begin
    Result:= ERR_NOTCOMP;
    exit;
  end;
  dec(r);
  for i:= 0 to r do begin
    for j:= 0 to r do begin
      if i = j then t:= 1.0 else t:= 0.0;
      MO.Item[i, j]:= t;
    end;
  end;
  for J:= 0 to R do begin
    p:= -1; mx:= 0;
    for I:= J to R do begin
      if abs(M.Item[i, j]) > mx then begin p:= I; mx:= abs(M.Item[i, j]); end;
    end;
    if mx < 10e-20 then begin
      Result:= ERR_SINGULA;
      exit;
    end;
    I:= p;
    if I <> J then begin
      for K:= 0 to R do begin
        t:= M.Item[J, K];
        M.Item[J, K]:= M.Item[I, K];
        M.Item[I, K]:= t;
        t:= MO.Item[J, K];
        MO.Item[J, K]:= MO.Item[I, K];
        MO.Item[I, K]:= t;
      end;
    end;
    t:= 1 / M.Item[J, J];
    for K:= 0 to R do begin
      M.Item[J, K]:= t * M.Item[J, K];
      MO.Item[J, K]:= t * MO.Item[J, K];
    end;
    for L:= 0 to R do begin
      if L <> J then begin
        T:= -M.Item[L, J];
        for K:= 0 to R do begin
          M.Item[L, K]:= M.Item[L, K] + T * M.Item[J, K];
          MO.Item[L, K]:= MO.Item[L, K] + T * MO.Item[J, K];
        end;
      end;
    end;
  end;
  Result:= 0;
end;

class function Matrix.MakeInv(var MI: TDMatrix): TDMatrix;
var
  i, j, k, l: integer;
  r : integer;
  p: integer;
  mx: double;
  t: double;
  M: TDMatrix;
  MO: TDMatrix;
begin
  r:= MI.RowCnt;
  if (r <> MI.ColCnt) then begin
    Result:= nil;
    exit;
  end;
  M:= TDMatrix.Create(nil);
  M.Setup(0,r,0,r);
  MO:= TDMatrix.Create(nil);
  MO.Setup(MI.RowMin, r, MI.ColMin, r);
  Result:= MO;
  if MO = nil then exit;
  dec(r);
  M.Assign(MI);
  for i:= 0 to r do begin
    for j:= 0 to r do begin
      if i = j then t:= 1.0 else t:= 0.0;
      MO.Item[i, j]:= t;
    end;
  end;
  for J:= 0 to R do begin
    p:= -1; mx:= 0;
    for I:= J to R do begin
      if abs(M.Item[j, i]) > mx then begin p:= I; mx:= abs(M.Item[j,i]); end;
    end;
    if mx < cZERO then begin
      MO.Free;
      M.Free;
      Result:= nil;
      exit;
    end;
    I:= p;
    if I <> J then begin
      for K:= 0 to R do begin
        t:= M.Item[J, K];
        M.Item[J, K]:= M.Item[I, K];
        M.Item[I, K]:= t;
        t:= MO.Item[J, K];
        MO.Item[J, K]:= MO.Item[I, K];
        MO.Item[I, K]:= t;
      end;
    end;
    t:= 1 / M.Item[J, J];
    for K:= 0 to R do begin
      M.Item[J, K]:= t * M.Item[J, K];
      MO.Item[J, K]:= t * MO.Item[J, K];
    end;
    for L:= 0 to R do begin
      if L <> J then begin
        T:= -M.Item[L, J];
        for K:= 0 to R do begin
          M.Item[L, K]:= M.Item[L, K] + T * M.Item[J, K];
          MO.Item[L, K]:= MO.Item[L, K] + T * MO.Item[J, K];
        end;
      end;
    end;
  end;
  M.Free;
end;

class function Matrix.Mul(var MO, MA, MB: TDMatrix): integer;
var
  i, j , k : integer;
  r1, c1, c2 : integer;
  sum : extended;
begin
  r1:= MA.RowCnt-1;
  c1:= MA.ColCnt-1;
  c2:= MB.ColCnt-1;
  if (c1 <> MB.RowCnt-1) or (r1 <> MO.RowCnt-1) or (c2 <> MO.ColCnt-1) then begin
    Result:= ERR_NOTCOMP;
    exit;
  end;
  for I:= 0 to R1 do begin
    for J:= 0 to C2 do begin
      sum:= 0;
      for K:= 0 to C1 do begin
        sum:= sum + MA.Item[I, K] * MB.Item[K, J];
      end;
      MO.Item[i, j]:= sum;
    end;
  end;
  Result:= 0;
end;

class function Matrix.MulXtY(var MO, MA, MB: TDMatrix): integer;
var
  i, j , k : integer;
  r1, c1, c2 : integer;
  sum : extended;
begin
  c1:= MA.RowCnt-1;
  r1:= MA.ColCnt-1;
  c2:= MB.ColCnt-1;
  if (c1 <> MB.RowCnt-1) or (r1 <> MO.RowCnt-1) or (c2 <> MO.ColCnt-1) then begin
    Result:= ERR_NOTCOMP;
    exit;
  end;
  for I:= 0 to R1 do begin
    for J:= 0 to C2 do begin
      sum:= 0;
      for K:= 0 to C1 do begin
        sum:= sum + MA.Item[K, I] * MB.Item[K, J];
      end;
      MO.Item[i, j]:= sum;
    end;
  end;
  Result:= 0;
end;

class function Matrix.MulXtYNRR(var MO, MA, MB: TDMatrix): integer;
(* [Xt x] * [Y y]' = [XtY + x'*y] *)
var
  New, i, j: integer;
begin
  New:= MA.RowCnt-1;
  for i:= 0 to MO.RowCnt-1 do begin
    for j:= 0 to MO.ColCnt-1 do begin
      MO.Item[i, j]:= MO.Item[i, j] + MA.Item[New, i] * MB.Item[New, j];
    end;
  end;
  Result:= 0;
end;

class function Matrix.MulXtYNCx(var MO, MA, MB: TDMatrix): integer;
(* [X c]' * [Y] = [XtY c'*Y]' *)
var
  New, i, j: integer;
  Sum: extended;
begin
  New:= MA.ColCnt-1;
  for j:= 0 to MO.ColCnt-1 do begin
    Sum:= 0;
    for i:= 0 to MA.RowCnt-1 do begin
      Sum:= Sum + MA.Item[i, New] * MB.Item[i, j];
    end;
    MO.Item[New, j]:= Sum;
  end;
  Result:= 0;
end;

class function Matrix.MakeMul(var MA, MB: TDMatrix): TMatrix;
var
  i, j , k : integer;
  r1, c1, c2 : integer;
  sum : extended;
  MO: TDMatrix;
begin
  r1:= MA.RowCnt-1;
  c1:= MA.ColCnt-1;
  c2:= MB.ColCnt-1;
  if (c1 <> MB.RowCnt-1) then begin
    Result:= nil;
    exit;
  end;
  MO:= TDMatrix.Create(nil);
  MO.Setup(MA.RowMin, r1, MA.ColMin, c2);
  Result:= MO;
  if MO = nil then exit;
  for I:= 0 to R1 do begin
    for J:= 0 to C2 do begin
      sum:= 0;
      for K:= 0 to C1 do begin
        sum:= sum + MA.Item[I, K] * MB.Item[K, J];
      end;
      MO.Item[i, j]:= sum;
    end;
  end;
end;

class function Matrix.MulXXt(var MO, MI: TDMatrix): integer;
var
  i, j , k : integer;
  sum: extended;
  r,c: integer;
begin
  r:= MI.RowCnt;
  c:= MI.ColCnt-1;
  if (MO.RowCnt <> r) or (MO.ColCnt <> r) then begin
    Result:= ERR_NOTCOMP;
    exit;
  end;
  dec(r);
  for I:= 0 to r do begin
    for J:= 0 to r do begin
      sum:= 0;
      for K:= 0 to c do begin
        sum:= sum + MI.Item[K, I] * MI.Item[K, J];
      end;
      MO.Item[i, j]:= sum;
    end;
  end;
  Result:= 0;
end;

class function Matrix.MulXtX(var MO, MI: TDMatrix): integer;
var
  i, j , k : integer;
  sum: extended;
  r, c: integer;
begin
  r:= MI.RowCnt-1;
  c:= MI.ColCnt;
  if (MO.RowCnt <> c) or (MO.ColCnt <> c) then begin
    Result:= ERR_NOTCOMP;
    exit;
  end;
  dec(c);
  for I:= 0 to c do begin
    for J:= I to c do begin
      sum:= 0;
      for K:= 0 to r do begin
        sum:= sum + MI.Item[K, I] * MI.Item[K, J];
      end;
      MO.Item[i, j]:= sum;
      MO.Item[j, i]:= sum;
    end;
  end;
  Result:= 0;
end;

class function Matrix.MulXtXNR(var MO, MI: TDMatrix): integer;
(* [X r] * [X r']' = XtX + rr' *)
var
  New, i, j: integer;
begin
  New:= MI.RowCnt-1;
  for i:= 0 to MO.RowCnt-1 do begin
    for j:= 0 to MO.ColCnt-1 do begin
      MO.Item[i, j]:= MO.Item[i, j] + MI.Item[New, i] * MI.Item[New, j];
    end;
  end;
  Result:= 0;
end;

class function Matrix.MulXtXNC(var MO, MI: TDMatrix): integer;
(* [X'] [X c] = [XtX X'c]
   [c']         [c'X c'c]
*)
var
  New, i, j: integer;
  Sum: extended;
begin
  New:= MI.ColCnt-1;
  for j:= 0 to MO.ColCnt-1 do begin
    Sum:= 0;
    for i:= 0 to MI.RowCnt-1 do begin
      Sum:= Sum + MI.Item[i, New] * MI.Item[i, j];
    end;
    MO.Item[New, j]:= Sum;
    MO.Item[j, New]:= Sum;
  end;
  Result:= 0;
end;

class function Matrix.Vec(var r: TDVector; var A: TDMatrix; var x: TDVector): integer;
var
  c1, r1: integer;
  j , k : integer;
  sum: extended;
begin
  c1:= x.RowCnt;
  r1:= r.RowCnt;
  if (c1 <> A.ColCnt) or (r1 <> A.RowCnt) then begin
    Result:= ERR_NOTCOMP;
    exit;
  end;
  dec(r1); dec(c1);
  for J:= 0 to r1 do begin
    sum:= 0;
    for K:= 0 to C1 do begin
      sum:= sum + A.Item[j, K] * x.Item[K];
    end;
    r.Item[J]:= sum;
  end;
  Result:= 0;
end;

class function Matrix.Tra(var MO, MI: TDMatrix): integer;
var i, j: integer;
begin
  if (MO.RowCnt <> MI.ColCnt) or (MO.ColCnt <> MI.RowCnt) then begin
    Result:= ERR_NOTCOMP;
    exit;
  end;
  for j:= 0 to MI.RowCnt-1 do begin
    for i:= 0 to MI.ColCnt-1 do begin
      MO.Item[i, j]:= MI.Item[j, i];
    end;
  end;
  Result:= 0;
end;

class function Matrix.MulSca(var A: TDMatrix; val: double): integer;
var
  r, c: integer;
begin
  for r:= 0 to pred(A.RowCnt) do begin
    for c:= 0 to pred(A.ColCnt) do begin
      A.Item[r, c]:= A.Item[r, c] * val;
    end;
  end;
  Result:= 0;
end;

class function Matrix.Zero(var A: TDMatrix): integer;
var
  r, c: integer;
begin
  for r:= 0 to pred(A.RowCnt) do begin
    for c:= 0 to pred(A.ColCnt) do begin
      A.Item[r, c]:= 0;
    end;
  end;
  Result:= 0;
end;

class function Matrix.Add(var MO, MI: TDMatrix): integer;
var
  r, c: integer;
begin
  if (MI.RowCnt <> MO.RowCnt) or (MI.ColCnt <> MO.ColCnt) then begin
    Result:= ERR_NOTCOMP;
    exit;
  end;
  Result:= 0;
  for r:= 0 to pred(MI.RowCnt) do begin
    for c:= 0 to pred(MI.ColCnt) do begin
      MO.Item[r, c]:= MO.Item[r, c] + MI.Item[r, c];
    end;
  end;
end;

class function Matrix.DetTri(var A: TDMatrix; var det: double): integer;
var i: integer;
begin
  if (A.RowCnt <> A.ColCnt) then begin
    Result:= ERR_NOTCOMP;
    exit;
  end;
  Result:= 0;
  det:= 1;
  for i:= 0 to pred(A.RowCnt) do begin
    det:= det * A.Item[i, i];
  end;
end;

(* Inverte una matrice triangolare inferiore *)
class function Matrix.InvTriInf(var MO, MI: TDMatrix): integer;
var
  KCol, KRow, k: integer;
  sum: extended;
begin
  if (MO.RowCnt <> MO.ColCnt) or (MO.RowCnt <> MI.ColCnt) or (MI.ColCnt <> MI.RowCnt) then begin
    Result:= ERR_NOTCOMP;
    exit;
  end;
  Result:= 0;
  MO.Item[0, 0]:= 1 / MI.Item[0, 0];
  if MI.RowCnt = 1 then exit;
  for KRow:= 1 to pred(MI.RowCnt) do begin
    MO.Item[KRow, KRow]:= 1 / MI.Item[KRow, KRow];
    for KCol:= 0 to pred(KRow) do begin
      sum:= 0;
      for k:= KCol to pred(KRow) do begin
        sum:= sum + MI.Item[KRow, K] * MO.Item[K, KCol];
      end;
      MO.Item[KRow, KCol]:= -sum / MI.Item[KRow, KRow];
    end;
  end;
end;

(* Inverte una matrice triangolare superiore *)
class function Matrix.InvTriSup(var MO, MI: TDMatrix): integer;
var
  KCol, KRow, k: integer;
  sum: extended;
begin
  if (MO.RowCnt <> MO.ColCnt) or (MO.RowCnt <> MI.ColCnt) or (MI.ColCnt <> MI.RowCnt) then begin
    Result:= ERR_NOTCOMP;
    exit;
  end;
  Result:= 0;
  for k:= 0 to pred(MI.RowCnt) do MO.Item[k, k]:= 1 / MI.Item[k, k];
  if MI.RowCnt = 1 then exit;
  for KRow:= MI.RowCnt-2 downto 0 do begin
    for KCol:= succ(KRow) to pred(MI.RowCnt) do begin
      sum:= 0;
      for k:= KRow to pred(KCol) do begin
        sum:= sum + MI.Item[K, KCol] * MO.Item[KRow, K];
      end;
      MO.Item[KRow, KCol]:= -sum / MI.Item[KCol, KCol];
    end;
  end;
end;

(* FactorGAU,
Costrusice la matrici G e U soddisfanti la relazione G * A = U, permettendo
poi la risoluzione del sistema con il metodo di gauss (U * x = G * b)
Elem = ordine +1 della matrice dei coefficenti
Coef(MAXMAT)(MAXMAT) = matrice dei coefficenti del sistema lineare
Pivot(ELEM-1) = vettore contenente le permutazioni di riga
Determ = conterra' il valore del determinante
MAXMAT = dimensione matrice (massima)
ritorna un'indicazione d'errore:
  MATH_NOERR    = Tutto Ok,
  MATH_SINGMATR = MATRICE SINGOLARE
*)
class function Matrix.FactorGAU(var Coef: TDMatrix; var Pivot: TIVector; var Determ: double): integer;
var
  temp,  MaxVal: double;
  Elem, Riga, i, j, k: integer;
begin
  Elem:= Coef.RowCnt-1;
  if Elem+1 <> Coef.ColCnt then begin
    FactorGAU:= ERR_NOTCOMP;
    exit;
  end;
  Determ:= 1.0;
  Pivot.Free;
  Pivot:= TIVector.Create(nil);
  Pivot.Setup(Coef.RowMin, Elem);
  for k:= 0 to Elem-1 do begin
    MaxVal:= abs(Coef.Item[k,k]);
    RIGA:= k;
    (* Ricerca pivot, pivoting parziale *)
    for i:= k+1 to Elem do begin
      if (abs(Coef.Item[i,k]) > MaxVal) then begin
        MaxVal:= abs(Coef.Item[i,k]);
        RIGA:= i;
      end;
    end;
    Pivot.Item[k]:= RIGA;
    (* Controllo singolarita' matrice *)
    if (MaxVal < cZERO) then begin
      Determ:= 0.0;
      FactorGAU:= ERR_SINGULA;
      exit;
    end;
    if (RIGA <> k) then begin
      (* scambio la riga K con la riga RIGA, a partire dall'elemento K *)
      for j:= k to Elem do begin
        Temp:= Coef.Item[k,j];
        Coef.Item[k,j]:= Coef.Item[RIGA,j];
        Coef.Item[RIGA,j]:= Temp;
      end;
      Determ:= -Determ;
    end;
    for i:= k+1 to Elem do begin
      Temp:= -(Coef.Item[i,k] / Coef.Item[k,k]);
      Coef.Item[i,k]:= Temp;
      for j:= k+1 to Elem do begin
        Coef.Item[i,j]:= Coef.Item[i,j] + Temp * Coef.Item[k,j];
      end;
    end;
    Determ:= Determ* Coef.Item[k,k];
  end;
  Determ:= Determ*Coef.Item[Elem,Elem];
  (* Controllo singolarita' matrice *)
  if (abs(Determ) < cZERO) then FactorGAU:= ERR_SINGULA else FactorGAU:= 0;
end;

(* Come FactorGAU ma crea una matrice a parte per i la matrice U *)
class function Matrix.FactorGAU2(var Cof: TDMatrix; var Coef: TDMatrix; var Pivot: TIVector; var Determ: double): integer;
var
  temp,  MaxVal: double;
  Elem, Riga, i, j, k: integer;
begin
  Elem:= Cof.RowCnt-1;
  if Elem+1 <> Cof.ColCnt then begin
    FactorGAU2:= ERR_NOTCOMP;
    exit;
  end;
  Determ:= 1.0;
  Pivot.Free;
  Coef.Free;
  Pivot:= TIVector.Create(nil); Pivot.Setup(Cof.RowMin, Elem);
  Coef := TDMatrix.Create(nil); Coef.Assign(Cof);
  for k:= 0 to Elem-1 do begin
    MaxVal:= abs(Coef.Item[k,k]);
    RIGA:= k;
    (* Ricerca pivot, pivoting parziale *)
    for i:= k+1 to Elem do begin
      if (abs(Coef.Item[i,k]) > MaxVal) then begin
        MaxVal:= abs(Coef.Item[i,k]);
        RIGA:= i;
      end;
    end;
    Pivot.Item[k]:= RIGA;
    (* Controllo singolarita' matrice *)
    if (MaxVal < cZERO) then begin
      Determ:= 0.0;
      FactorGAU2:= ERR_SINGULA;
      exit;
    end;
    if (RIGA <> k) then begin
      (* scambio la riga K con la riga RIGA, a partire dall'elemento K *)
      for j:= k to Elem do begin
        Temp:= Coef.Item[k,j];
        Coef.Item[k,j]:= Coef.Item[RIGA,j];
        Coef.Item[RIGA,j]:= Temp;
      end;
      Determ:= -Determ;
    end;
    for i:= k+1 to Elem do begin
      Temp:= -(Coef.Item[i,k] / Coef.Item[k,k]);
      Coef.Item[i,k]:= Temp;
      for j:= k+1 to Elem do begin
        Coef.Item[i,j]:= Coef.Item[i,j] + Temp * Coef.Item[k,j];
      end;
    end;
    Determ:= Determ* Coef.Item[k,k];
  end;
  Determ:= Determ*Coef.Item[Elem,Elem];
  (* Controllo singolarita' matrice *)
  if (abs(Determ) < cZERO) then FactorGAU2:= ERR_SINGULA else FactorGAU2:= 0;
end;

(* SolveGAU,
Dopo la fattorizzazione GA=U, procede alla soluzione del sistema triangolare
cosi' ottenuto
Elem = ordine della matrice + 1
Coef(MAXMAT)(MAXMAT) = matrice elaborata da FactorGAU
Pivot(ELEM-1) = vettore contenente le permutazioni di Coef
TermNoti(ELEM) = Termini noti, conterra' all'uscita la soluzione del sistema
Soluzione(ELEM) = vettore dei risultati, non ci sono problemi se Soluzione e
  i termini noti usano la stessa RAM (&Soluzione = &TermNoti)
MAXMAT = dimensione max della matrice
*)
class function Matrix.SolveGAU(var Coef: TDMatrix; var Pivot: TIVector; var TermNoti, Soluzione: TDVector): integer;
var
  temp, sum: double;
  i,j,k,Elem: integer;
begin
  Elem:= Coef.RowCnt-1;
  if @Soluzione = nil then begin
    Soluzione:= TDVector.Create(nil);
    Soluzione.Setup(Coef.RowMin, Elem+1);
  end;
  if (Elem+1 <> Coef.ColCnt) or (Elem <> Pivot.RowCnt) or (Elem+1 <> TermNoti.RowCnt) then begin
    SolveGAU:= ERR_NOTCOMP;
    exit;
  end;
  if (@Soluzione <> @TermNoti) then begin
    Soluzione.Assign(TermNoti);
  end;
  for k:= 0 to Elem-1 do begin
    j:= Pivot.Item[k];
    if (j <> k) then begin
      Temp:= Soluzione.Item[j];
      Soluzione.Item[j] := Soluzione.Item[k];
      Soluzione.Item[k] := Temp;
     end;
    for i:= k+1 to Elem do begin
      Soluzione.Item[i]:= Soluzione.Item[i] + Coef.Item[i,k] * Soluzione.Item[k];
    end;
  end;
  Soluzione.Item[Elem]:= Soluzione.Item[Elem] / Coef.Item[Elem,Elem];
  for i:= Elem-1 downto 0 do begin
    sum:= 0;
    for j:= i + 1 to Elem do begin
      sum:= sum + Coef.Item[i,j] * Soluzione.Item[j];
    end;
    Soluzione.Item[i] := (Soluzione.Item[i] - SUM) / Coef.Item[i,i];
  end;
  SolveGAU:= 0;
end;

(* SolveGAU,
Dopo la fattorizzazione GA=U, procede alla soluzione del sistema triangolare
cosi' ottenuto
Elem = ordine della matrice + 1
Coef(MAXMAT)(MAXMAT) = matrice elaborata da FactorGAU
Pivot(ELEM-1) = vettore contenente le permutazioni di Coef
TermNoti(ELEM,Col) = Termini noti, conterra' all'uscita la soluzione del sistema
Soluzione(ELEM,Col) = vettore dei risultati, non ci sono problemi se Soluzione e
  i termini noti usano la stessa RAM (&Soluzione = &TermNoti)
MAXMAT = dimensione max della matrice
*)
class function Matrix.MSolveGAU(var Coef: TDMatrix; var Pivot: TIVector; var TermNoti, Soluzione: TDMatrix; Col: integer): integer;
var
  temp, sum: double;
  i,j,k,Elem: integer;
begin
  Elem:= Coef.RowCnt-1;
  if (Elem+1 <> Coef.ColCnt) or (Elem <> Pivot.RowCnt) or (Elem+1 <> TermNoti.RowCnt) then begin
    MSolveGAU:= ERR_NOTCOMP;
    exit;
  end;
  if (@Soluzione <> @TermNoti) then begin
    for i:= 0 to Elem do begin
      Soluzione.Item[i, Col]:= TermNoti.Item[i, Col];
    end;
  end;
  for k:= 0 to Elem-1 do begin
    j:= Pivot.Item[k];
    if (j <> k) then begin
      Temp:= Soluzione.Item[j, Col];
      Soluzione.Item[j, Col] := Soluzione.Item[k, col];
      Soluzione.Item[k, Col] := Temp;
     end;
    for i:= k+1 to Elem do begin
      Soluzione.Item[i, col]:= Soluzione.Item[i, Col] + Coef.Item[i,k] * Soluzione.Item[k, Col];
    end;
  end;
  Soluzione.Item[Elem, Col]:= Soluzione.Item[Elem, Col] / Coef.Item[Elem,Elem];
  for i:= Elem-1 downto 0 do begin
    sum:= 0;
    for j:= i + 1 to Elem do begin
      sum:= sum + Coef.Item[i,j] * Soluzione.Item[j, Col];
    end;
    Soluzione.Item[i, Col] := (Soluzione.Item[i, Col] - SUM) / Coef.Item[i,i];
  end;
  MSolveGAU:= 0;
end;

(* risolve sistemi indeterminati, valori liberi a 0 nelle ultime soluzioni *)
class function Matrix.SolvSing(var Coef: TDMatrix; var TN, Sol: TDVector): integer;
var
  tmp, Sum, MaxVal: double;
  Elem, Riga, i, j, k: integer;
  procedure Swap(a,b: Pdouble);
  var tmp: double;
  begin
    tmp:= a^;
    a^:= b^;
    b^:= tmp;
  end;
begin
  Elem:= Coef.RowCnt-1;
  if Elem+1 <> Coef.ColCnt then begin
    SolvSing:= ERR_NOTCOMP;
    exit;
  end;
  for i:= 0 to Elem do begin
    Sol.Item[i]:= TN.Item[i];
  end;
  for k:= 0 to Elem-1 do begin
    MaxVal:= abs(Coef.Item[k,k]);
    RIGA:= k;
    (* Ricerca pivot, pivoting parziale *)
    for i:= k+1 to Elem do begin
      if (abs(Coef.Item[i,k]) - MaxVal) > cZERO then begin
        MaxVal:= abs(Coef.Item[i,k]);
        RIGA:= i;
      end;
    end;
    if (RIGA <> k) then begin
      (* scambio la riga K con la riga RIGA, a partire dall'elemento K *)
      for j:= k to Elem do begin
        tmp:= Coef.Item[k,j];
        Coef.Item[k,j]:= Coef.Item[RIGA,j];
        Coef.Item[RIGA,j]:= tmp;
      end;
      tmp:= Sol.Item[k];
      Sol.Item[k]:= Sol.Item[RIGA];
      Sol.Item[RIGA]:= tmp;
    end;
    (* Controllo singolarita' matrice *)
    if (MaxVal < cZERO) then begin
      continue;
    end;
    for i:= k+1 to Elem do begin
      tmp:= -(Coef.Item[i,k] / Coef.Item[k,k]);
      Coef.Item[i,k]:= 0;
      for j:= k+1 to Elem do begin
        Coef.Item[i,j]:= Coef.Item[i,j] + tmp * Coef.Item[k,j];
      end;
      Sol.Item[i]:= Sol.Item[i] + Sol.Item[k]*tmp;
    end;
  end;
  tmp:= Coef.Item[Elem,Elem];
  if abs(tmp)<cZERO then Sol.Item[Elem]:= 0
  else Sol.Item[Elem]:= Sol.Item[Elem] / tmp;
  for i:= Elem-1 downto 0 do begin
    sum:= 0;
    for j:= i + 1 to Elem do begin
      sum:= sum + Coef.Item[i,j] * Sol.Item[j];
    end;
    tmp:= Coef.Item[i,i];
    if abs(tmp)<cZERO then Sol.Item[i]:= 0
    else Sol.Item[i]:= (Sol.Item[i] - SUM) / tmp;
  end;
  SolvSing:= 0;
end;

class function Matrix.IMatMul(var MO, MA, MB: TIMatrix): integer;
var
  i, j , k : integer;
  r1, c1, c2 : integer;
  sum: longint;
begin
  r1:= MA.RowCnt-1;
  c1:= MA.ColCnt-1;
  c2:= MB.ColCnt-1;
  if (c1 <> MB.RowCnt-1) or (r1 <> MO.RowCnt-1) or (c2 <> MO.ColCnt-1) then begin
    IMatMul:= ERR_NOTCOMP;
    exit;
  end;
  for I:= 0 to R1 do begin
    for J:= 0 to C2 do begin
      sum:= 0;
      for K:= 0 to C1 do begin
        inc(sum, MA.Item[I, K] * MB.Item[K, J]);
      end;
      MO.Item[i, j]:= sum;
    end;
  end;
  IMatMul:= 0;
end;

class function Matrix.SortRow(var MA: TDMatrix; Col: integer): integer;
var rw,cl: integer;
  procedure QuickSort2(sinistra,destra: integer);
  var
    a, b, j: integer;
    ele1, ele2: double;
  begin
    a:= sinistra;
    b:= destra;
    ele1:= MA.Item[(sinistra+destra) shr 1, Col];
    repeat
      while MA.Item[a, Col] < ele1 do inc(a);
      while ele1 < MA.Item[b, Col] do dec(b);
      if a <= b then begin
        for j:= 0 to cl do begin
          ele2:= MA.Item[a,j];
          MA.Item[a,j]:= MA.Item[b,j];
          MA.Item[b,j]:= ele2;
        end;
        inc(a);
        dec(b);
      end;
    until a > b;
    if sinistra < b then QuickSort2(sinistra, b);
    if a < destra then QuickSort2(a, destra);
  end;
begin
  Result:= ERR_NOTCOMP;
  rw:= MA.RowCnt-1;
  cl:= MA.ColCnt-1;
  if col > cl then exit;
  QuickSort2(0,rw);
  Result:= 0;
end;

class function Matrix.SortCol(var MA: TDMatrix; Row: integer): integer;
var rw: integer;
  procedure QuickSort2(sinistra,destra: integer);
  var
    a, b, j: integer;
    ele1, ele2: double;
  begin
    a:= sinistra;
    b:= destra;
    ele1:= MA.Item[Row, (sinistra+destra) shr 1];
    repeat
      while MA.Item[Row, a] < ele1 do inc(a);
      while ele1 < MA.Item[Row, b] do dec(b);
      if a <= b then begin
        for j:= 0 to rw do begin
          ele2:= MA.Item[j, a];
          MA.Item[j, a]:= MA.Item[j, b];
          MA.Item[j, b]:= ele2;
        end;
        inc(a);
        dec(b);
      end;
    until a > b;
    if sinistra < b then QuickSort2(sinistra, b);
    if a < destra then QuickSort2(a, destra);
  end;
begin
  Result:= ERR_NOTCOMP;
  rw:= MA.RowCnt-1;
  if Row > rw then exit;
  QuickSort2(0,rw);
  Result:= 0;
end;

class function Matrix.SortRows(var MA: TDMatrix): integer;
var rw,cl: integer;
  procedure QuickSort2(sinistra,destra: integer);
  var
    a, b, j: integer;
    ele1: TDVector;
    ele2: double;
    function Less1: boolean;
    var i: integer;
    begin
      Less1:= true;
      i:= 0;
      while i <= cl do begin
         if MA.Item[a, i] < ele1.Item[i] then exit;
         if MA.Item[a, i] > ele1.Item[i] then break;
         inc(i);
      end;
      Less1:= false;
    end;
    function Less2: boolean;
    var i: integer;
    begin
      Less2:= true;
      i:= 0;
      while i <= cl do begin
        if ele1.Item[i] < MA.Item[b, i] then exit;
        if ele1.Item[i] > MA.Item[b, i] then break;
        inc(i);
      end;
      Less2:= false;
    end;
  begin
    ele1:= TDVector.Create(nil);
    ele1.Setup(0, cl+1);
    a:= sinistra;
    b:= destra;
    for j:= 0 to cl do ele1.Item[j]:= MA.Item[(sinistra+destra) shr 1, j];
    repeat
      while Less1 do inc(a);
      while Less2 do dec(b);
      if a <= b then begin
        for j:= 0 to cl do begin
          ele2:= MA.Item[a,j];
          MA.Item[a,j]:= MA.Item[b,j];
          MA.Item[b,j]:= ele2;
        end;
        inc(a);
        dec(b);
      end;
    until a > b;
    if sinistra < b then QuickSort2(sinistra, b);
    if a < destra then QuickSort2(a, destra);
    ele1.Free;
  end;
begin
  rw:= MA.RowCnt-1;
  cl:= MA.ColCnt-1;
  QuickSort2(0,rw);
  Result:= 0;
end;

(* NON TESTATE *)

(*-----------------------------------------------------------------------------
*	funct:	mat_lu
*	desct:	in-place LU decomposition with partial pivoting
*	given:	!! A = square matrix (n x n) !ATTENTION! see commen
*		P = permutation vector (n x 1)
*	retrn:	number of permutation performed
*		-1 means suspected singular matrix
*	comen:	A will be overwritten to be a LU-composite matrix
*
*	note:	the LU decomposed may NOT be equal to the LU of
*		the orignal matrix a. But equal to the LU of the
*		rows interchanged matrix.
*-----------------------------------------------------------------------------
*)
class function Matrix.mat_lu(var A: TDMatrix; var P: TIVector): integer;
var
  i, j, k, n: integer;
  maxi, tmp: integer;
  c, c1: double;
  t: double;
  pp: integer;
begin
  mat_lu:= -1;
  n:= A.ColCnt-1;
  pp:= 0;
  for i:= 0 to n do begin
    P.Item[i]:= i;
  end;
  for k:= 0 to n do begin
    (* --- partial pivoting --- *)
    maxi:= k;
    c:= 0.0;
    for i:= k to n do begin
      c1:= abs(A.Item[P.Item[i], k]);
      if (c1 > c) then begin
        c:= c1;
	maxi:= i;
      end;
    end;
    (* row exchange, update permutation vector *)
    if (k <> maxi) then begin
      inc(pp);
      tmp:= P.Item[k];
      P.Item[k]:= P.Item[maxi];
      P.Item[maxi]:= tmp;
    end;
    (* suspected singular matrix *)
    if abs(A.Item[P.Item[k], k]) < 10e-50 then exit;
    for i:= k+1 to n do begin
      (* --- calculate m(i,j) --- *)
      A.Item[P.Item[i], k]:= A.Item[P.Item[i],k] / A.Item[P.Item[k],k];
      (* --- elimination --- *)
      t:= -A.Item[P.Item[i],k];
      for j:= k+1 to n do begin
        A.Item[P.Item[i],j]:= A.Item[P.Item[i],j] + t * A.Item[P.Item[k],j];
      end;
    end;
  end;
  mat_lu:= pp;
end;

(*-----------------------------------------------------------------------------
*	funct:	mat_backsubs1
*	desct:	back substitution
*	given:	A = square matrix A (LU composite)
*		!! B = column matrix B (attention!, see comen)
*		!! X = place to put the result of X
*		P = Permutation vector (after calling mat_lu)
*		xcol = column of x to put the result
*	retrn:	column matrix X (of AX = B)
*	comen:	B will be overwritten
*-----------------------------------------------------------------------------*)
class procedure Matrix.mat_backsubs1(var A: TDMatrix; var B, X: TDMatrix; var P: TIVector; xcol: integer);
var
  i, j, k, n: integer;
  sum: double;
begin
  n:= A.ColCnt-1;
  for k:= 0 to n do begin
    for i:= k+1 to n do begin
      B.Item[P.Item[i], xcol]:= B.Item[P.Item[i], xcol] -
      A.Item[P.Item[i],k] * B.Item[P.Item[k], 0];
    end;
  end;
  X.Item[n-1,xcol]:= B.Item[P.Item[n-1],0] / A.Item[P.Item[n-1], n-1];
  for k:= n-1 downto 0 do begin
    sum:= 0.0;
    for j:= k+1 to n do begin
      sum:= sum + A.Item[P.Item[k],j] * X.Item[j, xcol];
    end;
    X.Item[k,xcol]:= (B.Item[P.Item[k],0] - sum) / A.Item[P.Item[k], k];
  end;
end;

initialization
  RegisterClass(TDMatrix);
  RegisterClass(TDVector);
  RegisterClass(TIMatrix);
  RegisterClass(TIVector);
end.

