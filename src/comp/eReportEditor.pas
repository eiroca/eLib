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
unit eReportEditor;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, eReport, Buttons, StdCtrls,
  DesignIntf, DesignEditors;

type
  TfmEditFieldDefs = class(TForm)
    lbFld: TListBox;
    Label1: TLabel;
    btOk: TButton;
    btCancel: TButton;
    btAddFld: TButton;
    btDelFld: TButton;
    iPos: TEdit;
    iSiz: TEdit;
    cbAlign: TComboBox;
    btUndo: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure iPosKeyPress(Sender: TObject; var Key: Char);
    procedure btAddFldClick(Sender: TObject);
    procedure lbFldClick(Sender: TObject);
    procedure btUndoClick(Sender: TObject);
    procedure btDelFldClick(Sender: TObject);
    procedure btOkClick(Sender: TObject);
  private
    { Private declarations }
    Fld: TList;
    OldPos: integer;
    procedure ClearFld;
    procedure Select(aPos: integer);
    procedure UpdateList(ps: integer);
    function  AddFld(RF: TReportField): integer;
    procedure ToInput(aPos: integer);
    procedure FromInput(aPos: integer);
  public
    { Public declarations }
  end;

  TDevicePropertyEditor = class(TPropertyEditor)
    function  GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
    function  GetValue: string; override;
    procedure SetValue(const Value: string); override;
  end;

  TeLineFieldsEditor = class(TComponentEditor)
    function  GetVerb(Index: integer): string; override;
    function  GetVerbCount: integer; override;
    procedure ExecuteVerb(index: Integer); override;
    procedure Edit; override;
  end;

function EditFieldDefs(LF: TeLineFields): boolean;

procedure Register;

implementation

{$R *.DFM}

uses
  eLibVCL;

function EditFieldDefs(LF: TeLineFields): boolean;
var
  fmEditFieldDefs: TfmEditFieldDefs;
  i: integer;
  RF: TReportField;
begin
  fmEditFieldDefs:= TfmEditFieldDefs.Create(nil);
  try
    for i:= 0 to LF.FieldsCount-1 do begin
      with LF.Field[i] do begin
        RF:= TReportField.Create(Pos, Size, Align);
      end;
      fmEditFieldDefs.AddFld(RF);
    end;
    Result:= fmEditFieldDefs.ShowModal=mrOk;
    if Result then begin
      LF.DeleteAllFields;
      for i:= 0 to fmEditFieldDefs.Fld.Count-1 do begin
        with TReportField(fmEditFieldDefs.Fld[i]) do begin
          LF.AddField(Pos, Size, Align);
        end;
      end;
    end;
  finally
    fmEditFieldDefs.Free;
  end;
end;


procedure TfmEditFieldDefs.FormCreate(Sender: TObject);
begin
  Rescale(Self, 96);
  Fld:= TList.Create;
  lbFld.Items.Clear;
end;

procedure TfmEditFieldDefs.ClearFld;
var
  i: integer;
begin
  for i:= Fld.Count-1 downto 0 do begin
    TReportField(Fld[i]).Free;
  end;
  Fld.Clear;
  Fld.Pack;
end;

procedure TfmEditFieldDefs.FormDestroy(Sender: TObject);
begin
  ClearFld;
  Fld.Free;
end;

procedure TfmEditFieldDefs.ToInput(aPos: integer);
begin
  with TReportField(Fld[aPos]) do begin
    iPos.Text:= IntToStr(Pos);
    iSiz.Text:= IntToStr(Size);
    cbAlign.ItemIndex:= ord(Align);
  end;
end;

procedure TfmEditFieldDefs.FromInput(aPos: integer);
begin
  with TReportField(Fld[aPos]) do begin
    try
      if iPos.Text<>'' then Pos:= StrToInt(iPos.Text);
    except
      on EConvertError do ;
    end;
    try
      if iSiz.Text<>'' then Size:= StrToInt(iSiz.Text);
    except
      on EConvertError do ;
    end;
    case cbAlign.ItemIndex of
      0: Align:= taLeftJustify;
      1: Align:= taRightJustify;
      2: Align:= taCenter;
    end;
  end;
end;

procedure TfmEditFieldDefs.Select(aPos: integer);
var
  flg: boolean;
begin
  if (OldPos>=0) and (OldPos<Fld.Count) then begin
    FromInput(OldPos);
    UpdateList(OldPos);
  end;
  lbFld.ItemIndex:= aPos;
  if (aPos>=0) and (aPos<Fld.Count) then begin
    ToInput(aPos);
    flg:= true;
  end
  else begin
    iPos.Text:= '';
    iSiz.Text:= '';
    cbAlign.ItemIndex:= 0;
    flg:= false;
  end;
  iPos.Enabled:= flg;
  iSiz.Enabled:= flg;
  cbAlign.Enabled:= flg;
  btDelFld.Enabled:= flg;
  btUndo.Enabled:= flg;
  OldPos:= aPos;
end;

procedure TfmEditFieldDefs.FormShow(Sender: TObject);
begin
  OldPos:= -1;
  (* Copia da componente *)
  Select(lbFld.Items.Count-1);
end;

procedure TfmEditFieldDefs.iPosKeyPress(Sender: TObject; var Key: Char);
begin
  if (ord(Key)>31) and (not CharInSet(Key, ['0'..'9'])) then Key:= #0;
end;

function TfmEditFieldDefs.AddFld(RF: TReportField): integer;
begin
  Result:= Fld.Add(RF);
  lbFld.Items.Add('');
  UpdateList(Result);
end;

procedure TfmEditFieldDefs.UpdateList(ps: integer);
const
  AlignStr: array[TAlignment] of string[20]=('left','right','center');
begin
  with TReportField(Fld[ps]) do begin
    lbFld.Items[ps]:= Format('%4d %4d %s', [Pos, Size, AlignStr[Align]]);
  end;
end;

procedure TfmEditFieldDefs.btAddFldClick(Sender: TObject);
var
  RF: TReportField;
begin
  Select(-1);
  RF:=TReportField.Create(1, 10, taRightJustify);
  if Fld.Count>0 then begin
    with TReportField(Fld[Fld.Count-1]) do begin
      RF.Pos:= Pos+Size+1;
    end;
  end;
  Select(AddFld(RF));
end;

procedure TfmEditFieldDefs.lbFldClick(Sender: TObject);
begin
  Select(lbFld.ItemIndex);
end;

procedure TfmEditFieldDefs.btUndoClick(Sender: TObject);
var
  Pos: integer;
begin
  Pos:= lbFld.ItemIndex;
  if (Pos>=0) and (Pos<Fld.Count) then ToInput(Pos);
end;

procedure TfmEditFieldDefs.btDelFldClick(Sender: TObject);
var
  Pos: integer;
begin
  Pos:= lbFld.ItemIndex;
  if (Pos>=0) and (Pos<Fld.Count) then begin
    lbFld.Items.Delete(Pos);
    TReportField(Fld[Pos]).Free;
    Fld.Delete(Pos);
    if Pos>=lbFld.Items.Count then Pos:= lbFld.Items.Count-1;
    Select(Pos);
  end;
end;

procedure TfmEditFieldDefs.btOkClick(Sender: TObject);
begin
  Select(-1);
end;

function TDevicePropertyEditor.GetAttributes: TPropertyAttributes;
begin
  Result:= [paValueList, paAutoUpdate, paSortList, paReadOnly];
end;

procedure TDevicePropertyEditor.GetValues(Proc: TGetStrProc);
var
  i: integer;
  OutputDevices: TStrings;
begin
  OutputDevices:= _getOutputDevices;
  for i:= 0 to OutputDevices.Count-1 do begin
    Proc(OutputDevices[i]);
  end;
  Proc(msgNoDevice);
end;

function TDevicePropertyEditor.GetValue: string;
begin
  Result:= GetStrValue;
end;

procedure TDevicePropertyEditor.SetValue(const Value: string);
begin
  SetStrValue(Value);
end;

function  TeLineFieldsEditor.GetVerb(Index: integer): string;
begin
  Result:= 'Edit fields';
end;

function  TeLineFieldsEditor.GetVerbCount: integer;
begin
  Result:= 1;
end;

procedure TeLineFieldsEditor.ExecuteVerb(index: Integer);
begin
  Edit;
end;

procedure TeLineFieldsEditor.Edit;
begin
  if Component <> nil then begin
    if EditFieldDefs(Component as TeLineFields) then begin
      if Designer <> nil then Designer.Modified;
    end;
  end;
end;

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(string), TeLineReport, 'DeviceKind', TDevicePropertyEditor);
  RegisterComponentEditor(TeLineFields, TeLineFieldsEditor);
end;

end.

