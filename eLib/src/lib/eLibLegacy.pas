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
unit eLibLegacy;

(*
  Function & classes obsolete in XE2
*)

interface

type
  TObjectPointerList = array of TObject;

  TObjectList = class(TObject)
    private
     FCount: Integer;
     FCapacity: Integer;
    protected
     FList: TObjectPointerList;
    protected
     procedure Grow;
     function  Get(Index: Integer): TObject;
     procedure Put(Index: Integer; Item: TObject);
     procedure SetCapacity(NewCapacity: Integer);
     procedure SetCount(NewCount: Integer);
    public
     class procedure Error(const Msg: string; Data: Integer); virtual;
     procedure  Clear;
     function   IndexOf(Item: TObject): Integer;
     procedure  Add(Item: TObject);
     function   Remove(Item: TObject): Integer;
     procedure  Insert(Index: Integer; Item: TObject); virtual;
     procedure  Delete(Index: Integer); virtual;
     destructor Destroy; override;
    public
     property Capacity: Integer read FCapacity write SetCapacity;
     property Count: Integer read FCount write SetCount;
     property Objects[Index: Integer]: TObject read Get write Put;
     property List: TObjectPointerList read FList;
  end;


implementation

uses
  System.Classes;

resourcestring
  errListCapacityError = 'List Capacity Error %d';
  errListIndexError    = 'Out of index %d';
  errListCountError    = 'List Count Error %d';

procedure TObjectList.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity < FCount) then Error(errListCapacityError, NewCapacity);
  if NewCapacity <> FCapacity then begin
    SetLength(FList, NewCapacity);
    FCapacity:= NewCapacity;
  end;
end;

procedure TObjectList.SetCount(NewCount: Integer);
var
  i: integer;
begin
  if (NewCount < 0) then Error(errListCountError, NewCount);
  if NewCount > FCapacity then SetCapacity(NewCount);
  if NewCount > FCount then begin
    for i:= FCount to NewCount-1 do begin
      FList[i]:= nil;
    end;
  end;
  FCount:= NewCount;
end;

class procedure TObjectList.Error(const Msg: string; Data: Integer);
  function ReturnAddr: Pointer;
  asm
    MOV EAX,[EBP+4]
  end;
begin
  raise EListError.CreateFmt(Msg, [Data]) at ReturnAddr;
end;

function TObjectList.Get(Index: Integer): TObject;
begin
  Result:= FList[Index];
end;

procedure TObjectList.Put(Index: Integer; Item: TObject);
begin
  FList[Index]:= Item;
end;

procedure TObjectList.Grow;
begin
  SetCapacity(FCapacity + 256);
end;

procedure TObjectList.Clear;
begin
  SetCount(0);
  SetCapacity(0);
end;

function TObjectList.IndexOf(Item: TObject): Integer;
begin
  Result:= 0;
  while (Result < FCount) and (FList[Result] <> Item) do Inc(Result);
  if Result = FCount then Result:= -1;
end;

procedure TObjectList.Add(Item: TObject);
begin
  Insert(Count, Item);
end;

function TObjectList.Remove(Item: TObject): Integer;
begin
  Result:= IndexOf(Item);
  if Result <> -1 then Delete(Result);
end;

procedure TObjectList.Delete(Index: Integer);
var
  i: integer;
begin
  {$IFOPT R+}
  if (Index < 0) or (Index >= FCount) then Error(errListIndexError, Index);
  {$ENDIF}
  Dec(FCount);
  if Index < FCount then begin
    for i:= Index + 1 to FCount-1 do FList[i-1]:= FList[i];
  end;
end;

procedure TObjectList.Insert(Index: Integer; Item: TObject);
var
  i: integer;
begin
  {$IFOPT R+}
  if (Index < 0) or (Index > FCount) then Error(errListIndexError, Index);
  {$ENDIF}
  if FCount = FCapacity then Grow;
  if Index < FCount then begin
    for i:= FCount-1 downto Index+1 do FList[i]:= FList[i-1];
  end;
  FList[Index]:= Item;
  Inc(FCount);
end;

destructor TObjectList.Destroy;
var
  i: integer;
begin
  for i:= 0 to Count-1 do Objects[i].Free;
  Clear;
end;

end.
