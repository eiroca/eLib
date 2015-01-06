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
unit eLibBDE;

interface

uses
  BDE, DB, DBTables;

type
  DBEUtil = class
    class procedure PostMaster(ds: TDataSource); static;
    class procedure _PostMaster(ds: TDataSet); static;
    class procedure EmptyTable(var Table: TTable); static;
  end;

type
  aCROpType  = array[0..29] of CROpType;
  aFLDDesc   = array[0..29] of FLDDesc;
  aIDXDesc   = array[0..29] of IDXDesc;
  aVChkDesc  = array[0..29] of VChkDesc;
  aRIntDesc  = array[0..29] of RIntDesc;
  paCROpType = ^aCROpType;
  paFLDDesc  = ^aFLDDesc;
  paIDXDesc  = ^aIDXDesc;
  paVChkDesc = ^aVChkDesc;
  paRIntDesc = ^aRIntDesc;

procedure DeleteAuxFiles(const szDirectory, szTblName, szTblType: string);

function GetDBPath(aDB: TDataBase): string;

function  InitTableDesc(const iAFldCount, iAIDXCount, iAValChkCount, iARintCount: integer): pCRTblDesc;
procedure DoneTableDesc(var pTableDesc: pCRTblDesc);

procedure DefField(var FieldDesc: FLDDesc; const sName: string; const iAFldID,iAFldType,iASubType,iAUnits1,iAUnits2: integer);
procedure DefIndex(var IndexDesc: IDXDesc; const sName,sTagName,sFormat,sKeyExp,sKeyCond: string; const aFields: array of integer; const iAIndexID,iAFldsInKey,iAKeyLen, iAKeyExptype,iABlockSize,iARestrNum: integer; const bAPrimary,bAUnique,bADescending,bAMaintained,bASubSet,bAExpIDX,bAOutOfDate,bACaseInsensitive: boolean);
procedure DefValCheck(var ValCheckDesc: VChkDesc; const iAFldNum: integer; const aAMinVal,aAMaxVal,aADefVal: array of Byte; const bARequired,bAHasMinVal,bAHasMaxVal,bAHasDefVal: boolean; const sPict,sLkupTblName: string; const eALKUPType: LKUPType);
procedure DefRefInt(var RefInteg: RIntDesc; const iARintNum,iAFldCount: integer; const aiAThisTabFld,aAiOthTabFld: array of integer; const sRintName, sDirectory, sTblName: string; const eAType: RINTType; const eAModOP,eADelOP: RINTQual);
procedure DefTable(var TableDesc: CRTblDesc; const sName,sType,sPassword: string);

implementation

uses
  SysUtils, eLibCore;

class procedure DBEUtil.PostMaster(ds: TDataSource);
var
  DataSet: TDataSet;
begin
  DataSet:= ds.DataSet;
  if Assigned(DataSet) then begin
    if (DataSet is TTable) then begin
      if TTable(DataSet).MasterSource <> nil then begin
        DataSet:= TTable(DataSet).MasterSource.DataSet;
      end;
    end;
  end;
  if DataSet <> nil then _PostMaster(DataSet);
end;

class procedure DBEUtil._PostMaster(ds: TDataSet);
begin
  if ds.State = dsInsert then begin
    ds.Post;
    ds.Edit;
  end;
end;

class procedure DBEUtil.EmptyTable(var Table: TTable);
  procedure DeleteRecByRec;
  begin
    Table.Active:= true;
    Table.First;
    while not Table.EOF do Table.Delete;
  end;
begin
  Table.Active:= false;
  try
    Table.EmptyTable;
    Table.Active:= true;
  except
    DeleteRecByRec;
  end;
end;

procedure DeleteAuxFiles(const szDirectory, szTblName, szTblType: string);
var
  sFileName: string;
  f: file of byte;
  b: byte;
begin
  sFileName:= szDirectory+szTblName;
  if szTblType = szParadox then begin
    SysUtils.DeleteFile(ChangeFileExt(sFileName,'.PX'));
    SysUtils.DeleteFile(ChangeFileExt(sFileName,'.VAL'));
    FileUtil.DeleteFiles(ChangeFileExt(sFileName,'.X*'));
    FileUtil.DeleteFiles(ChangeFileExt(sFileName,'.Y*'));
  end
  else if szTblType = szDBase then begin
    AssignFile(f,ChangeFileExt(sFileName,'.DBF'));
    reset(f);
    try
      seek(f,28);
      b:= 0;
      write(f,b);
      SysUtils.DeleteFile(ChangeFileExt(sFileName,'.MDX'));
    finally
      closefile(f);
    end;
  end
  else ;
end;

function GetDBPath(aDB: TDataBase): string;
var
  Path: DBIPath;
begin
  aDB.Connected := true;
  Check(DbiGetDirectory(aDB.Handle,False,Path));
  Result:= StrPas(Path);
end;

function  InitTableDesc(const iAFldCount, iAIDXCount, iAValChkCount, iARintCount: integer): pCRTblDesc;
begin
  Result:= AllocMem(SizeOf(CRTblDesc));
  with Result^ do begin
    iFldCount:= iAFldCount;
    if iAFldCount > 0 then begin
      pFldDesc := AllocMem(iAFldCount * SizeOf(FLDDesc));
      pecrFldOp:= AllocMem(iAFldCount * SizeOf(CROpType));
    end;
    iIdxCount:= iAIdxCount;
    if iAIdxCount > 0 then begin
      pIdxDesc := AllocMem(iAIdxCount * SizeOf(IDXDesc));
      pecrIdxOp:= AllocMem(iAIdxCount * SizeOf(CROpType));
    end;
    iValChkCount:= iAValChkCount;
    if iAValChkCount > 0 then begin
      pVChkDesc := AllocMem(iAValChkCount * SizeOf(VChkDesc));
      pecrValChkOp:= AllocMem(iAValChkCount * SizeOf(CROpType));
    end;
    iRIntCount:= iARIntCount;
    if iARIntCount > 0 then begin
      pRIntDesc := AllocMem(iARIntCount * SizeOf(RIntDesc));
      pecrRIntOp:= AllocMem(iARIntCount * SizeOf(CROpType));
    end;
  end;
end;

procedure DoneTableDesc(var pTableDesc: pCRTblDesc);
begin
  with pTableDesc^ do begin
    if iFldCount > 0 then begin
      FreeMem(pFldDesc, iFldCount * SizeOf(FLDDesc));
      FreeMem(pecrFldOp, iFldCount * SizeOf(CROpType));
    end;
    if iIdxCount > 0 then begin
      FreeMem(pIdxDesc, iIdxCount * SizeOf(IDXDesc));
      FreeMem(pecrIdxOp, iIdxCount * SizeOf(CROpType));
    end;
    if iValChkCount > 0 then begin
      FreeMem(pVChkDesc, iValChkCount * SizeOf(VChkDesc));
      FreeMem(pecrValChkOp, iValChkCount * SizeOf(CROpType));
    end;
    if iRIntCount > 0 then begin
      FreeMem(pRIntDesc, iRIntCount * SizeOf(RIntDesc));
      FreeMem(pecrRIntOp, iRIntCount * SizeOf(CROpType));
    end;
  end;
  FreeMem(pTableDesc, SizeOf(CRTblDesc));
  pTableDesc:= nil;
end;

procedure DefField(
  var FieldDesc: FLDDesc;
  const sName: string;
  const iAFldID,iAFldType,iASubType,iAUnits1,iAUnits2: integer);
begin
  with FieldDesc do begin
    iFldNum:= iAFldID;
    StrPCopy(szName,sName);
    iFldType:= iAFldType;
    iSubType:= iASubType;
    iUnits1:= iAUnits1;
    iUnits2:= iAUnits2;
  end;
end;

procedure DefIndex(
  var IndexDesc: IDXDesc;
  const sName,sTagName,sFormat,sKeyExp,sKeyCond: string;
  const aFields: array of integer;
  const iAIndexID,iAFldsInKey,iAKeyLen, iAKeyExptype,iABlockSize,iARestrNum: integer;
  const bAPrimary,bAUnique,bADescending,bAMaintained,bASubSet,bAExpIDX,bAOutOfDate,bACaseInsensitive: boolean);
var
  i: byte;
begin
  with IndexDesc do begin
    StrPCopy(szName,sName);
    iIndexId:= iAIndexId;
    StrPCopy(szFormat,sFormat);
    StrPCopy(szTagName,sTagName);
    StrPCopy(szKeyExp,sKeyExp);
    StrPCopy(szKeyCond,sKeyCond);
    iFldsInkey:= iAFldsInkey;
    iKeyLen:= iAKeyLen;
    iKeyExpType:= iAKeyExpType;
    iBlocksize:= iABlocksize;
    iRestrNum:= iARestrNum;
    bPrimary:= bAPrimary;
    bUnique:= bAUnique;
    bDescending:= bADescending;
    bMaintained:= bAMaintained;
    bSubset:= bASubset;
    bExpIdx:= bAExpIdx;
    bOutofDate:= bAOutofDate;
    bCaseInsensitive:= bACaseInsensitive;
    FillChar(aiKeyFld,SizeOf(aiKeyFld),#0);
    for i:= Low(aFields) to High(aFields) do aiKeyFld[i]:= aFields[i];
  end;
end;

procedure DefValCheck(
  var ValCheckDesc: VChkDesc;
  const iAFldNum: integer;
  const aAMinVal,aAMaxVal,aADefVal: array of Byte;
  const bARequired,bAHasMinVal,bAHasMaxVal,bAHasDefVal: boolean;
  const sPict,sLkupTblName: string;
  const eALKUPType: LKUPType);
var
  i: byte;
begin
  with ValCheckDesc do begin
    iFldNum:= iAFldNum;
    StrPCopy(szPict,sPict);
    bRequired:= bARequired;
    bHasMinVal:= bAHasMinVal;
    bHasMaxVal:= bAHasMaxVal; bHasDefVal:= bAHasDefVal;
    eLKUPType:= eALKUPType; StrPCopy(szLkupTblName,sLkupTblName);
    FillChar(aMinVal,SizeOf(aMinVal),#0);
    for i:= Low(aAMinVal) to High(aAMinVal) do aMinVal[i]:= aAMinVal[i];
    FillChar(aMaxVal,SizeOf(aMaxVal),#0);
    for i:= Low(aAMaxVal) to High(aAMaxVal) do aMaxVal[i]:= aAMaxVal[i];
    FillChar(aDefVal,SizeOf(aDefVal),#0);
    for i:= Low(aADefVal) to High(aADefVal) do aDefVal[i]:= aADefVal[i];
  end;
end;

procedure DefRefInt(
  var RefInteg: RIntDesc;
  const iARintNum,iAFldCount: integer;
  const aiAThisTabFld,aAiOthTabFld: array of integer;
  const sRintName, sDirectory, sTblName: string;
  const eAType: RINTType;
  const eAModOP,eADelOP: RINTQual);
var
  i: byte;
begin
  with RefInteg do begin
    iRintNum:= iARintNum;
    StrPCopy(szRintName,sRintName);
    eType:= eAType;
    StrPCopy(sztblName,sDirectory+stblName);
    eModOp:= eAModOp;
    eDelOp:= eADelOp;
    iFldCount:= iAFldCount;
    FillChar(aiThisTabFld,SizeOf(aiThisTabFld),#0);
    for i:= Low(aiAThisTabFld) to High(aiAThisTabFld) do aiThisTabFld[i]:= aiAThisTabFld[i];
    FillChar(aiOthTabFld,SizeOf(aiOthTabFld),#0);
    for i:= Low(aAiOthTabFld) to High(aAiOthTabFld) do aiOthTabFld[i]:= aAiOthTabFld[i];
  end;
end;

procedure DefTable(
  var TableDesc: CRTblDesc;
  const sName,sType,sPassword: string);
begin
  with TableDesc do begin
    StrPCopy(szTblName,sName);
    StrPCopy(szTblType,sType);
    bProtected:=(sPassword <> '');
    if bProtected then begin
      StrPCopy(szPassword,sPassword);
    end;
    bPack:= true;
  end;
end;

end.
