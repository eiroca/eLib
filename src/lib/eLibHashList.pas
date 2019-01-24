{
  ======================================================================
  HashList.pas
  ------------
  Copyright (c) 2000 Barry Kelly
  
  barry_j_kelly@hotmial.com
  
  Do whatever you like with this code, but don't redistribute modified
  versions without clearly marking them so.
  
  No warranties, express or implied. Use at your own risk.
  ======================================================================
  A simple string / pointer associative array. Good performance.
  ======================================================================

  Usage:

    Creation:
    ---------
    THashList.Create(<hash size>, <compare func>, <hash func>)

    <hash size> should be the expected size of the filled hash list. Hash
    size cannot be changed after the fact. However, hash buckets are
    implemented as binary trees so performance should not degrade by
    too much for small overflows.

    <compare func> should be the comparison function for strings. If nil
    is passed, then StrCompare (case sensitive, ordinal value) is used.
    This function (declared in this unit) simply calls CompareStr.

    <hash func> should be the hash function for a string. If nil is
    passed, then StrHash (case sensitive, ordinal value) is used.
    This function (declared in this unit) uses a table of 32-bit numbers,
    and xors them based on the offset of each character in the string.
    It increments the accumulator each step, too. This means that:
    * Permutations of a string have different hash values, but not wildly
      different.
    * No limit on amount of string hashed => long strings may degrade
      performance.

    For <compare func> and <hash func> the functions TextCompare and
    TextHash are also declared. These are case insensitive versions. They
    simply adjust to lower case and call the case sensitive versions.

    You can, obviously, replace these functions without modifying the
    source.

    Addition
    --------
    procedure Add(const s: string; const p);

    s is the string, p is interpreted as a pointer. It should, therefore,
    be 4 bytes long to avoid garbage.

    Property Access
    ---------------
    property Data[const s: string]: Pointer;

    You can also add implicitly by using the Data property:
      myHashList.Data['MyString'] := Pointer($ABCDEF00);
    This property type is default, so above could be
      myHashList['MyString'] := Pointer($ABCDEF00);

    Note that this is explicitly a pointer. Will return nil
    if s isn't in the hash. Will only implicitly add on Set not Get.

    Deletion
    --------
    function Remove(const s: string): Pointer;
    procedure RemoveData(const p);

    Remove returns the data reference, so it can be freed.

    Deletion from hash lists is a strange business. The bucket must
    be adjusted so that it is still a valid binary search tree. Therefore,
    it is fairly slow. Also, random deletion followed by random insertion
    destroys the randomness of the tree, affecting subsequent performance.

    Random insertion with random deletion, then random insertion, will
    mean the tree will have ~88% the performance of a tree using no
    deletion.

    However, if your hash list is big enough, you don't need to worry about
    this.

    Misc
    ----
    function Has(const s: string): Boolean;

    Returns whether hash contains string s.
    ----
    function Find(const s: string; var p): Boolean;

    Returns true if found, p set to value of data corresponding to s.
    P is not set if not found.
    ----
    function FindData(const p; var s: string): Boolean;

    'Opposite' of Find: searches for key given a data value; Returns
    true if found, s not set if not found. Only first key found is
    returned: there may be other keys that have this data.
    The first key found is not in any particular order, and is found
    using the Iterate method.
    ----
    procedure Iterate(AUserData: Pointer; AIterateFunc: TIterateFunc);

    AIterateFunc = function(AUserData: Pointer; const AStr: string;
      var APtr: Pointer): Boolean;

    AIterateFunc is called for each item in the hash in no particular
    order, and will terminate the iteration if the user function
    ever returns false. The value of APtr can be adjusted, but *not*
    AStr since that would involve destroying the iteration order.

    Iterate_FreeObjects is a predefined function that will typecast
    every Data to TObject and call the Free method. This is useful
    to destroy associated objects in a hash before freeing the hash.
    AUserData isn't used by this iterator.

    Iterate_Dispose will call Dispose on each data object. AUserData
    isn't used.

    Iterate_FreeMem will call FreeMem on each data object. AUserData
    isn't used.

    IterateMethod is similar, but works with a method pointer (closure/
    event) rather than a function pointer.
    ----
    property Count: Integer;

    This contains the number of items in the hash list.
}
unit eLibHashList;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
  SysUtils, Classes;

type
  EHashListException = class(Exception);

type
  TCompareFunc = function(const l, r: string): Integer;
  THashFunc = function(const s: string): Integer;

  { iterate func returns false to terminate iteration }
  TIterateFunc = function(AUserData: Pointer; const AStr: string; var APtr: Pointer): Boolean;

  TIterateMethod = function(AUserData: Pointer; const AStr: string; var APtr: Pointer): Boolean of object;

  PPHashNode = ^PHashNode;
  PHashNode = ^THashNode;
  THashNode = record
    Str: string;
    Ptr: Pointer;
    Left: PHashNode;
    Right: PHashNode;
  end;

  TNodeIterateFunc = procedure(AUserData: Pointer; ANode: PPHashNode);

  PHashArray = ^THashArray;
  THashArray = array[0..MaxInt div SizeOf(PHashNode) - 1] of PHashNode;

{
  ======================================================================
  THashList
  ======================================================================
}
  THashList = class
  public
    constructor Create(AHashSize: Integer; ACompareFunc: TCompareFunc; AHashFunc: THashFunc);
    destructor Destroy; override;
  private
    FHashFunc: THashFunc;
    FCompareFunc: TCompareFunc;
    FHashSize: Integer;
    FCount: Integer;
    FList: PHashArray;
    FLeftDelete: Boolean;

    { private methods }
    procedure SetHashSize(AHashSize: Integer);
  protected
    {
      helper methods
    }
    { FindNode returns a pointer to a pointer to the node with s,
      or, if s isn't in the hash, a pointer to the location where the
      node will have to be added to be consistent with the structure }
    function FindNode(const s: string): PPHashNode;
    function IterateNode(ANode: PHashNode; AUserData: Pointer; AIterateFunc: TIterateFunc): Boolean;
    function IterateMethodNode(ANode: PHashNode; AUserData: Pointer; AIterateMethod: TIterateMethod): Boolean;

    // !!! NB: this function iterates NODES NOT DATA !!!
    procedure NodeIterate(ANode: PPHashNode; AUserData: Pointer; AIterateFunc: TNodeIterateFunc);

    procedure DeleteNode(var q: PHashNode);
    procedure DeleteNodes(var q: PHashNode);

    { !!! NB: AllocNode and FreeNode don't inc / dec the count,
      to remove burden from overridden implementations;
      Therefore, EVERY time AllocNode / FreeNode is called,
      FCount MUST be incremented / decremented to keep Count valid. }
    function AllocNode: PHashNode; virtual;
    procedure FreeNode(ANode: PHashNode); virtual;

    { property access }
    function GetData(const s: string): Pointer;
    procedure SetData(const s: string; p: Pointer);
  public
    { public methods }
    procedure Add(const s: string; const p{: Pointer});
    procedure RemoveData(const p{: Pointer});
    function Remove(const s: string): Pointer;
    procedure Iterate(AUserData: Pointer; AIterateFunc: TIterateFunc);
    procedure IterateMethod(AUserData: Pointer; AIterateMethod: TIterateMethod);
    function Has(const s: string): Boolean;
    function Find(const s: string; var p{: Pointer}): Boolean;
    function FindData(const p{: Pointer}; var s: string): Boolean;

    procedure Clear;

    { properties }
    property Count: Integer read FCount;
    property Data[const s: string]: Pointer read GetData write SetData; default;
  end;

{ str=case sensitive, text=case insensitive }

function StrHash(const s: string): Integer;
function TextHash(const s: string): Integer;

function StrCompare(const l, r: string): Integer;
function TextCompare(const l, r: string): Integer;

{ iterators }
function Iterate_FreeObjects(AUserData: Pointer; const AStr: string; var AData: Pointer): Boolean;
function Iterate_Dispose(AUserData: Pointer; const AStr: string; var AData: Pointer): Boolean;
function Iterate_FreeMem(AUserData: Pointer; const AStr: string; var AData: Pointer): Boolean;

implementation

function Iterate_FreeObjects(AUserData: Pointer; const AStr: string; var AData: Pointer): Boolean;
begin
  TObject(AData).Free;
  AData := nil;
  Result := True;
end;

function Iterate_Dispose(AUserData: Pointer; const AStr: string; var AData: Pointer): Boolean;
begin
  Dispose(AData);
  AData := nil;
  Result := True;
end;

function Iterate_FreeMem(AUserData: Pointer; const AStr: string; var AData: Pointer): Boolean;
begin
  FreeMem(AData);
  AData := nil;
  Result := True;
end;

const
  Hash_Table: array[AnsiChar] of Integer = (
    $4CBF5B63, $2A009AF6, $31A262D3, $65BCFC21, $5FC274A9, $1C483154, $7980CAA8, $694F5B4F,
    $5422088F, $7998ACD2, $17B02C1F, $2A2D1A9D, $598AFD15, $06EA8B70, $7602FD34, $6E4A880B,
    $35FAD83C, $0B496B2E, $652B53EA, $4C7A1199, $4C45C001, $08720A0C, $2FD0E641, $63DA4547,
    $693C7A67, $5490460A, $13470A37, $0F63D115, $7D726D6D, $531D1D28, $53E2B5CC, $23978303,
    $09A39F14, $2ADCAD66, $42F07F02, $644C4911, $23BAB55A, $76FC34C4, $2C4A9BD9, $009D313F,
    $1A76F640, $11501142, $418EE24E, $02F7698D, $5DB247C5, $33B1C0E0, $38F4C865, $43483FFB,
    $71472FEB, $4E7DE19E, $75C3641A, $094B2289, $5096D4B1, $1232317C, $30676B71, $2CF79F37,
    $48AEFC17, $4A2B8E7A, $34293467, $230F6405, $6F100C1D, $4683F698, $6882B4FC, $03CC3EF3,
    $7B130AC3, $331087D6, $7C158332, $39AE1E01, $67EF9E09, $597F8034, $2740D509, $26690F2F,
    $65620BEF, $6C963DB2, $1C57807F, $2BF3407D, $3CF13A76, $1A8F3E50, $5B75FB94, $27B2FFEB,
    $71D4AF9B, $4498200E, $3FF85C4B, $0DCCBB79, $017A9162, $596FA0EC, $3D9058A1, $72910127,
    $4AADA5C7, $71239EEA, $62FB4696, $700A7EF5, $415B52CD, $67EF1808, $58581C2C, $75AC02E3,
    $34F99E74, $56382A46, $2F1D6F63, $301E7AF1, $0F8D2EBA, $63AE13A4, $79AF7638, $572EF51F,
    $134F49A0, $13873222, $409606AE, $4FDC9F6D, $3CF3D526, $47DF03C0, $0B5296C5, $3086C7DB,
    $108F574C, $5A34267E, $52D63C7A, $553ADC69, $371CF612, $4706585C, $5397ADD0, $52226B17,
    $72A47777, $0A94775A, $554940C6, $321121E5, $0F00417E, $6CBA8178, $1E2EEB5D, $0F32CED3,
    $15435A24, $19EF94B6, $68144392, $33D95FE1, $27BF676A, $0763EF14, $4CE27F68, $116AE30F,
    $0CAAAF50, $403EEE92, $40D674DE, $7B6F865D, $0D6617D6, $59FD1130, $505699F4, $34BF97CB,
    $706326FB, $6DEDF4EE, $776904AA, $7CD18559, $73AA02C1, $15D257CC, $08C96B01, $6B27DD07,
    $4DFF7127, $099A17CA, $3A9F22F7, $06DF4CD5, $5CAAD82D, $1C4232E8, $0ED3228D, $285CA2C3,
    $43DC3DD3, $75D2C726, $6D05FFC2, $531ACCD1, $67B24819, $087D1284, $6425F098, $5598D8FF,
    $43E03CFF, $5ED97302, $29A4CB0F, $1D67F54D, $47F40285, $014566A0, $0C4E0525, $4D596FBB,
    $7E3C1EAB, $50618B5E, $30BCB4DB, $43CCB649, $634DB771, $52AF9F3C, $0D719031, $5F1D56F7,
    $742A92D7, $1350803A, $3C88ED27, $6E30FFC5, $190716DE, $4FE22C58, $5910C1BC, $5B257EB3,
    $32B04984, $537DC196, $3DFEA3F3, $3E1EC1C1, $3091D0CA, $7CD57DF4, $1CC5C9C9, $2634D6EF,
    $355BF2B0, $0D72BF72, $018D093F, $0681EC3D, $70499535, $00140410, $7B04D854, $55504FAB,
    $71063E5B, $442AE9CE, $3BDD4D0B, $0B686F39, $5C341421, $5C7A2EAC, $2BDC1D61, $517ED8E7,
    $0691DC88, $7ED3B0AA, $7E929F56, $49C23AB5, $1CC0FD8E, $72F66DC8, $05B3C8ED, $038962A3,
    $1DAB7D34, $0E8C8406, $150A3023, $47213EB1, $0D8A017A, $4C493164, $6E0E0AF8, $07BADCDF,
    $6789D05F, $1C26D3E2, $491B2F6E, $69796B2D, $7412CFE5, $2AC4E980, $32471385, $69A0379B,
    $49AD860B, $7DE6103E, $0FD6CD3B, $56E0B029, $5E8918D1, $640E061C, $48551290, $67C862D7,
    $30A14E38, $553FA91A, $1E483987, $5D4EFDA5, $2A848C3E, $02DAF738, $7788381C, $3F844E93
  );

function StrHash(const s: string): Integer;
var
  i: Integer;
  p: PChar;
begin
  // comp.compilers
  //hash  =  (hash ^ current_character) + ((hash<<26)+(hash>>6));
  // Result := (Result xor Ord(p^)) + ((Result shl 26) + (Result shr 6));

  Result := 0;
  p := PChar(s);
  i := Length(s);

  if i > 0 then
    repeat
      Result := (Result xor Ord(p^)) + ((Result shl 26) + (Result shr 6));
      Inc(p);
      Dec(i);
    until i = 0;

  { |Result| }
  Result := Result and $7FFFFFFF;
// orig
//  Result := 0;
//  p := PChar(s);
//
//  i := Length(s);
//  if i > 0 then
//    repeat
//      Result := Result xor Hash_Table[p^];
//      Inc(Result);
//      Inc(p);
//      Dec(i);
//    until i = 0;
end;

function TextHash(const s: string): Integer;
begin
  Result := StrHash(LowerCase(s));
end;

function StrCompare(const l, r: string): Integer;
begin
  Result := CompareStr(l, r);
end;

function TextCompare(const l, r: string): Integer;
begin
  Result := CompareText(l, r);
end;

{
  ======================================================================
  THashList
  ======================================================================
}
constructor THashList.Create(AHashSize: Integer; ACompareFunc: TCompareFunc; AHashFunc: THashFunc);
begin
  SetHashSize(AHashSize);
  if not Assigned(AHashFunc) then
    FHashFunc := StrHash
  else
    FHashFunc := AHashFunc;

  if not Assigned(ACompareFunc) then
    FCompareFunc := StrCompare
  else
    FCompareFunc := ACompareFunc;
end;

destructor THashList.Destroy;
begin
  Clear;
  SetHashSize(0);
  inherited Destroy;
end;

{
  private methods
}
procedure THashList.SetHashSize(AHashSize: Integer);
begin
  if FHashSize <> AHashSize then begin
    ReallocMem(FList, AHashSize * SizeOf(FList^[0]));
    FillChar(FList^, AHashSize * SizeOf(FList^[0]), 0);
    FHashSize := AHashSize;
  end;
end;

{
  helper methods
}
function THashList.FindNode(const s: string): PPHashNode;
var
  i, r: Integer;
  ppn: PPHashNode;
begin
  { we start at the node offset by s in the hash list }
  i := FHashFunc(s) mod FHashSize;

  ppn := @FList^[i];

  if ppn^ <> nil then
    while True do begin
      r := FCompareFunc(s, ppn^^.Str);

      { left, then right, then match }
      if r < 0 then
        ppn := @ppn^^.Left
      else if r > 0 then
        ppn := @ppn^^.Right
      else
        Break;

      { check for empty position after drilling left or right }
      if ppn^ = nil then
        Break;
    end;

  Result := ppn;
end;

function THashList.IterateNode(ANode: PHashNode; AUserData: Pointer;
  AIterateFunc: TIterateFunc): Boolean;
begin
  if ANode <> nil then begin
    Result := AIterateFunc(AUserData, ANode^.Str, ANode^.Ptr);
    if not Result then
      Exit;

    Result := IterateNode(ANode^.Left, AUserData, AIterateFunc);
    if not Result then
      Exit;

    Result := IterateNode(ANode^.Right, AUserData, AIterateFunc);
    if not Result then
      Exit;
  end else
    Result := True;
end;

function THashList.IterateMethodNode(ANode: PHashNode; AUserData: Pointer;
  AIterateMethod: TIterateMethod): Boolean;
begin
  if ANode <> nil then begin
    Result := AIterateMethod(AUserData, ANode^.Str, ANode^.Ptr);
    if not Result then
      Exit;

    Result := IterateMethodNode(ANode^.Left, AUserData, AIterateMethod);
    if not Result then
      Exit;

    Result := IterateMethodNode(ANode^.Right, AUserData, AIterateMethod);
    if not Result then
      Exit;
  end else
    Result := True;
end;

procedure THashList.NodeIterate(ANode: PPHashNode; AUserData: Pointer;
  AIterateFunc: TNodeIterateFunc);
begin
  if ANode^ <> nil then begin
    AIterateFunc(AUserData, ANode);
    NodeIterate(@ANode^.Left, AUserData, AIterateFunc);
    NodeIterate(@ANode^.Right, AUserData, AIterateFunc);
  end;
end;

procedure THashList.DeleteNode(var q: PHashNode);
var
  t, r, s: PHashNode;
begin
  { we must delete node q without destroying binary tree }
  { Knuth 6.2.2 D (pg 432 Vol 3 2nd ed) }

  { alternating between left / right delete to preserve decent
    performance over multiple insertion / deletion }
  FLeftDelete := not FLeftDelete;

  { t will be the node we delete }
  t := q;

  if FLeftDelete then begin
    if t^.Right = nil then
      q := t^.Left
    else begin
      r := t^.Right;
      if r^.Left = nil then begin
        r^.Left := t^.Left;
        q := r;
      end
      else begin
        s := r^.Left;
        if s^.Left <> nil then
          repeat
            r := s;
            s := r^.Left;
          until s^.Left = nil;
        { now, s = symmetric successor of q }
        s^.Left := t^.Left;
        r^.Left :=  s^.Right;
        s^.Right := t^.Right;
        q := s;
      end;
    end;
  end
  else begin
    if t^.Left = nil then
      q := t^.Right
    else begin
      r := t^.Left;
      if r^.Right = nil then begin
        r^.Right := t^.Right;
        q := r;
      end
      else begin
        s := r^.Right;
        if s^.Right <> nil then
          repeat
            r := s;
            s := r^.Right;
          until s^.Right = nil;
        { now, s = symmetric predecessor of q }
        s^.Right := t^.Right;
        r^.Right := s^.Left;
        s^.Left := t^.Left;
        q := s;
      end;
    end;
  end;

  { we decrement before because the tree is already adjusted
    => any exception in FreeNode MUST be ignored.

    It's unlikely that FreeNode would raise an exception anyway. }
  Dec(FCount);
  FreeNode(t);
end;

procedure THashList.DeleteNodes(var q: PHashNode);
begin
  { ? use tail recursion? - Normal recursion is easier to understand;
    We're not in a tearing hurry here... }
  if q^.Left <> nil then
    DeleteNodes(q^.Left);
  if q^.Right <> nil then
    DeleteNodes(q^.Right);
  FreeNode(q);
  q := nil;
end;

function THashList.AllocNode: PHashNode;
begin
  New(Result);
  Result^.Left := nil;
  Result^.Right := nil;
end;

procedure THashList.FreeNode(ANode: PHashNode);
begin
  Dispose(ANode);
end;

{
  property access
}
function THashList.GetData(const s: string): Pointer;
var
  ppn: PPHashNode;
begin
  ppn := FindNode(s);

  if ppn^ <> nil then
    Result := ppn^^.Ptr
  else
    Result := nil;
end;

procedure THashList.SetData(const s: string; p: Pointer);
var
  ppn: PPHashNode;
begin
  ppn := FindNode(s);

  if ppn^ <> nil then
    ppn^^.Ptr := p
  else begin
    { add }
    ppn^ := AllocNode;
    { we increment after in case of exception }
    Inc(FCount);
    ppn^^.Str := s;
    ppn^^.Ptr := p;
  end;
end;

{
  public methods
}
procedure THashList.Add(const s: string; const p{: Pointer});
var
  ppn: PPHashNode;
begin
  ppn := FindNode(s);

  { if reordered from SetData because ppn^ = nil is more common for Add }
  if ppn^ = nil then begin
    { add }
    ppn^ := AllocNode;
    { we increment after in case of exception }
    Inc(FCount);
    ppn^^.Str := s;
    ppn^^.Ptr := Pointer(p);
  end else
    raise EHashListException.CreateFmt('Duplicate hash list entry: %s', [s]);
end;

type
  PListNode = ^TListNode;
  TListNode = record
    Next: PListNode;
    NodeLoc: PPHashNode;
  end;

  PDataParam = ^TDataParam;
  TDataParam = record
    Head: PListNode;
    Data: Pointer;
  end;

procedure NodeIterate_BuildDataList(AUserData: Pointer; ANode: PPHashNode);
var
  dp: PDataParam absolute AUserData;
  t: PListNode;
begin
  if dp.Data = ANode^^.Ptr then begin
    New(t);
    t^.Next := dp.Head;
    t^.NodeLoc := ANode;
    dp.Head := t;
  end;
end;

procedure THashList.RemoveData(const p{: Pointer});
var
  dp: TDataParam;
  i: Integer;
  n, t: PListNode;
begin
  dp.Data := Pointer(p);
  dp.Head := nil;

  for i := 0 to FHashSize - 1 do
    NodeIterate(@FList^[i], @dp, NodeIterate_BuildDataList);

  n := dp.Head;
  while n <> nil do begin
    DeleteNode(n^.NodeLoc^);
    t := n;
    n := n^.Next;
    Dispose(t);
  end;
end;

function THashList.Remove(const s: string): Pointer;
var
  ppn: PPHashNode;
begin
  ppn := FindNode(s);

  if ppn^ <> nil then begin
    Result := ppn^^.Ptr;
    DeleteNode(ppn^);
  end
  else
    raise EHashListException.CreateFmt('Tried to remove invalid node: %s', [s]);
end;

procedure THashList.IterateMethod(AUserData: Pointer;
  AIterateMethod: TIterateMethod);
var
  i: Integer;
begin
  for i := 0 to FHashSize - 1 do
    if not IterateMethodNode(FList^[i], AUserData, AIterateMethod) then
      Break;
end;

procedure THashList.Iterate(AUserData: Pointer; AIterateFunc: TIterateFunc);
var
  i: Integer;
begin
  for i := 0 to FHashSize - 1 do
    if not IterateNode(FList^[i], AUserData, AIterateFunc) then
      Break;
end;

function THashList.Has(const s: string): Boolean;
var
  ppn: PPHashNode;
begin
  ppn := FindNode(s);
  Result := ppn^ <> nil;
end;

function THashList.Find(const s: string; var p{: Pointer}): Boolean;
var
  ppn: PPHashNode;
begin
  ppn := FindNode(s);
  Result := ppn^ <> nil;
  if Result then
    Pointer(p) := ppn^^.Ptr;
end;

type
  PFindDataResult = ^TFindDataResult;
  TFindDataResult = record
    Found: Boolean;
    ValueToFind: Pointer;
    Key: string;
  end;

function Iterate_FindData(AUserData: Pointer; const AStr: string; var APtr: Pointer): Boolean;
var
  pfdr: PFindDataResult absolute AUserData;
begin
  pfdr^.Found := (APtr = pfdr^.ValueToFind);
  Result := not pfdr^.Found;
  if pfdr^.Found then
    pfdr^.Key := AStr;
end;

function THashList.FindData(const p{: Pointer}; var s: string): Boolean;
var
  pfdr: PFindDataResult;
begin
  New(pfdr);
  try
    pfdr^.Found := False;
    pfdr^.ValueToFind := Pointer(p);
    Iterate(pfdr, Iterate_FindData);
    Result := pfdr^.Found;
    if Result then
      s := pfdr^.Key;
  finally
    Dispose(pfdr);
  end;
end;

procedure THashList.Clear;
var
  i: Integer;
  ppn: PPHashNode;
begin
  for i := 0 to FHashSize - 1 do begin
    ppn := @FList^[i];
    if ppn^ <> nil then
      DeleteNodes(ppn^);
  end;
  FCount := 0;
end;

end.

