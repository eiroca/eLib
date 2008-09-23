{
 Designer: Craig Ward, 100554.2072@compuserve.com
 Date:     29/2/96

 Version:  1.1


 Function: Property editor for the TcwXTab component.

 Notes:    A custom propery editor requires extensive programming of the Edit procedure. See
           this method for more information.

           The items in the combo boxes (format and math operation) are in a specific order
           which matches the order in the type declaration in cwXtab. Do not change these!!!
**********************************************************************************}
unit CWXTEdit;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, DB, DBTables, DesignIntf,
  DesignEditors, cwXTab;


type
  TXTabEditorDlg = class(TForm)
    Bevel1: TBevel;
    comboRow: TComboBox;
    comboCol: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Bevel2: TBevel;
    comboSum1: TComboBox;
    comboMathOp1: TComboBox;
    comboFormat1: TComboBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    comboSum2: TComboBox;
    comboMathOp2: TComboBox;
    comboFormat2: TComboBox;
    Bevel5: TBevel;
    comboSum3: TComboBox;
    comboMathOp3: TComboBox;
    comboFormat3: TComboBox;
    Label7: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FXTab: TXObject;
    procedure SetXTab(value: TXObject);
  public
    { Public declarations }
    property Crosstab: TXObject read FXTab write SetXTab;
  end;


 {property editor}
 TXTabProperty = class(TClassProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  { Component editor - brings up custom editor when double clicking on property}
  TXTabEditor = class(TDefaultEditor)
  public
//    procedure EditProperty(PropertyEditor: TPropertyEditor; var Continue, FreeEditor: Boolean); override;
    procedure EditProperty(const PropertyEditor: IProperty; var Continue: Boolean); override;
  end;


var
  XTabEditorDlg: TXTabEditorDlg;

  procedure Register;

implementation

{$R *.DFM}

{***property editor preferences**************************************************}

{edit}
procedure TXTabProperty.Edit;
var
 c: TXObject;
 s: TStringList;
 i: integer;
begin
 {initialise}
 c := TXOBject(GetOrdValue);
 if c.table = nil then exit;
 XTabEditorDlg := TXTabEditorDlg.Create(Application);
 s := TStringList.create;
 try
  XTabEditorDlg.Crosstab := c;
 {populate fields in the editor with table's fields}
 for i := 0 to (XTabEditorDlg.Crosstab.Table.fieldCount -1) do
  begin
   xTabEditorDlg.comboRow.items.add(XTabEditorDlg.Crosstab.Table.fields[i].fieldName);
   xTabEditorDlg.comboCol.items.add(XTabEditorDlg.Crosstab.Table.fields[i].fieldName);
   xTabEditorDlg.comboSum1.items.add(XTabEditorDlg.Crosstab.Table.fields[i].fieldName);
   xTabEditorDlg.comboSum2.items.add(XTabEditorDlg.Crosstab.Table.fields[i].fieldName);
   xTabEditorDlg.comboSum3.items.add(XTabEditorDlg.Crosstab.Table.fields[i].fieldName);
  end;

 {store field names in string-list for next section...}
 s.assign(xTabEditorDlg.comboRow.items);

 {load user's previous values - if any}
 xTabEditorDlg.comboRow.itemIndex := s.indexOf(c.RowField);
 xTabEditorDlg.comboCol.itemIndex := s.indexOf(c.ColumnField);
 xTabEditorDlg.comboSum1.itemIndex := s.indexOf(c.SummaryField1);
 xTabEditorDlg.comboSum2.itemIndex := s.indexOf(c.SummaryField2);
 xTabEditorDlg.comboSum3.itemIndex := s.indexOf(c.SummaryField3);


 {set combo using index of saved data}
 if c.summaryField1 <> '' then
  begin
   xTabEditorDlg.comboMathOp1.itemIndex := ord(c.SumField1MathOp);
   xTabEditorDlg.comboFormat1.itemIndex := ord(c.SumField1Format);
  end;

 {set combo using index of saved data}
 if c.summaryField2 <> '' then
  begin
   xTabEditorDlg.comboMathOp2.itemIndex := ord(c.SumField2MathOp);
   xTabEditorDlg.comboFormat2.itemIndex := ord(c.SumField2Format);
  end;

 {set combo using index of saved data}
 if c.summaryField3 <> '' then
  begin
   xTabEditorDlg.comboMathOp3.itemIndex := ord(c.SumField3MathOp);
   xTabEditorDlg.comboFormat3.itemIndex := ord(c.SumField3Format);
  end;

 {on ok...}
 if XTabEditorDlg.ShowModal = mrOK then
  begin

   {write data to the custom record}
   c.rowField := xTabEditorDlg.comboRow.text;
   c.ColumnField := xTabEditorDlg.comboCol.text;
   c.SummaryField1 := xTabEditorDlg.comboSum1.text;
   c.SummaryField2 := xTabEditorDlg.comboSum2.text;
   c.SummaryField3 := xTabEditorDlg.comboSum3.text;

   {set custom record's operation field}
   case xTabEditorDlg.comboMathOp1.itemIndex of
    0:
     c.SumField1MathOp := sum;
    1:
     c.SumField1MathOp := avg;
    2:
     c.SumField1MathOp := min;
    3:
     c.SumField1MathOp := max;
    4:
     c.SumField1MathOp := count;
   end;

  {set custom record's format field}
   case xTabEditorDlg.comboFormat1.itemIndex of
    0:
     c.SumField1Format := currency_format;
    1:
     c.SumField1Format := integer_format;
    2:
     c.SumField1Format := real_format;
   end;

   {set custom record's operation field}
   case xTabEditorDlg.comboMathOp2.itemIndex of
    0:
     c.SumField2MathOp := sum;
    1:
     c.SumField2MathOp := avg;
    2:
     c.SumField2MathOp := min;
    3:
     c.SumField2MathOp := max;
    4:
     c.SumField2MathOp := count;
   end;

   {set custom record's format field}
   case xTabEditorDlg.comboFormat2.itemIndex of
    0:
     c.SumField2Format := currency_format;
    1:
     c.SumField2Format := integer_format;
    2:
     c.SumField2Format := real_format;
   end;

   {set custom record's operation field}
   case xTabEditorDlg.comboMathOp3.itemIndex of
    0:
     c.SumField3MathOp := sum;
    1:
     c.SumField3MathOp := avg;
    2:
     c.SumField3MathOp := min;
    3:
     c.SumField3MathOp := max;
    4:
     c.SumField3MathOp := count;
   end;

   {set custom record's format field}
   case xTabEditorDlg.comboFormat3.itemIndex of
    0:
     c.SumField3Format := currency_format;
    1:
     c.SumField3Format := integer_format;
    2:
     c.SumField3Format := real_format;
   end;

  designer.modified;


  end


 {clean up}
 finally
  XTabEditorDlg.Free;
  s.free;
 end;


end;


{***property editor's preferences***********************************************}

{attributes}
function TXTabProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

{edit}
//procedure TXTabEditor.EditProperty(PropertyEditor: TPropertyEditor; var Continue, FreeEditor: Boolean);
procedure TXTabEditor.EditProperty(const PropertyEditor: IProperty; var Continue: Boolean); 
var
  PropName: string;
begin
  PropName := PropertyEditor.GetName;
  if (CompareText(PropName, 'Crosstab') = 0) then
  begin
    PropertyEditor.Edit;
    Continue := False;
  end;
end;


{***edit dialog's preferences***************************************************}

{set crosstab}
procedure TXTabEditorDlg.SetXTab(value: TXObject);
begin
 if value <> FXTab then
  FXTab := value;
end;

{on create}
procedure TXTabEditorDlg.FormCreate(Sender: TObject);
begin
 FXtab := TXObject.create;
end;

procedure Register;
begin
  RegisterComponentEditor(TcwXTab, TXTabEditor);
  RegisterPropertyEditor(TypeInfo(TXObject),nil,'',TXTabProperty);
end;

{}
end.
