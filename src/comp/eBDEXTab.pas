{ Modificato da Me
 - Usato DVal al posto di StrToFloat;
 - Modificato SaveXTab al fine di specificare il tipo di tabella e migliorie minori


 Designer: Craig Ward, 100554.2072@compuserve.com
           H Van Tasell, 76602.1123@compuserve.com

 Date:     9/5/96

 Version:  1.32


 Function: The TcwXTab component is a component, descended from TStringGrid, which
           allows cross-tabulations of a table's data to be built.


 XTab's:   A crosstab is the representation of de-normalised table-data. Typically
           you'd have a summary by the unique values contained in a row field and
           a column field.

           In my component, you can have multiple results in a cell (a max of 3), each performing
           a discrete mathematical operation, and displaying this data in the format
           that you specify. Woopee!


 Calling:  The method Execute will execute the crosstab.
           The method SaveXTab will save the crosstab as a Paradox table.


 Update:   The following amendments have been made:

            [0] resolution for bug in reading negative currency values.

            [1] the OnDrawCell routine now ignores row\column headings since I felt it looked
                aesthetically unattractive to have text with hard-returns in the headings...

            [2] the crosstab can now have summary fields for both rows and columns (this is
                the AggRowCols property). Note that the summary cells used a maroon font, and
                in the case of using the SaveXTab procedure, they are not saved to the result
                table (since that would *seriously* violate normalisation rules).

            [3] the crosstab now has an additional property which allows the cells to resize
                to the maximum text displayed (this is the AutoResize property). In this case,
                the component will make row-heights big enough to fit the lines in a cell,
                whilst the column-widths will be made big enough to fit the maximum size
                of text in each respective column heading.

            [4] the crosstab now uses pointers to the custom types used in the PopXTab routine.

            [5] a new property, "EmptyCellChar", allows the developer to choose between blanks
                or zeros for empty cells.

           The main update was to implement summary rows and columns. To achieve this I had to
           *modularise* the code, so that the drawing to cells (and reading from) was done
           by discrete functions (which is what they should have been in the first place, but
           as I've said, this component is well and truly hacked).

           A problem that I had with implementing the auto-resize property was executing the
           routine at the correct time in the component's life. In particular, the grid is populated
           before it's drawn, so the auto-resize property (btw, that's implemented through the
           UpdateXTab procedure) had to come after the grid had finished drawing itself. I couldn't think
           of any other way around this then to create a bool, that's true on creation, and once the
           first DrawCell event has executed, is set to false (obviously, when the bool is true, call
           the UpdateXTab routine). Though this works okay, I find it somewhat brutish, and the
           flickering is a bit annoying...any ideas?



 Bugs:     The following undocumented features are known:

            [1] Though the editor will allow you to select calculated fields, the crosstab
                will actually run into GPF if you try to run it where either the row or
                column fields are calculated.
            [2] The auto-resize function works on the text in column headings, and not
                on the text in cells. Therefore, a column could be resized so that the
                heading fits, but the value in the column's cells is not properly visible.


 Hackers:  This component is severely hacked. It took me ages to develop, mainly due to
           the difficulty in getting the custom property editor to work (a job in itself).
           Therefore, the code is not quite optimal, and it certainly isn't going to win
           any prizes, but it might help in some way, least of all the fact that you now
           have a working Crosstab in your VCL.

           My main gripe would be the custom object that stores the XTab data (see the type
           declaration for TXObject). The fields should really have been stored in a custom
           record (ie: FieldName, MathOp, Format) as opposed to duplicating the object's fields -
           check out the custom type defined in the PopXTab procedure (that is what really should be
           stored in TXObject, though that in itself would probably require another custom property
           editor.....!).


 VCL:      IMHO, this component is okay. I've seen better (one that springs to mind is
           the TCrosstab component by Kevin Liu - INTERNET:kliu@oodb.syscom.com.tw -
           which is particularly impressive in that you can set how many columns and
           rows to summarise by). However, I don't know of any crosstab components where
           they are free, and the source is available at no charge.


 Thanks:    Thanks goto the following:

             [1] Dennis Passmore (71640.2464@compuserve.com) for help in drawing multi-line
                 text in a cell
             [2] Greg Tresdell (74131.2175@compuserve.com) for help in writing custom
                 property editors. Check out his "Gray Paper" for more information...
             [3] The following for help in getting text metrics:
                  Pat Ritchey (700007.4660@compuserve.com)
                  Julian Bucknall (72662.1324@compuserve.com)
                  Harley L Pebley (103330.2334@compuserve.com)
             [4] Harry Van Tasell for taking time to add improvements to the component
             [5] Fox TV for "The X-Files"

**********************************************************************************}
unit eBDEXTab;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, DB, DBTables, eCompBDE, eLibCore;

{constants for array sizes}
const
 iSizeOfArray = 2;

type
  {custom type - possible math operations to be carried out}
  TMathOp = (sum, avg, min, max, count);

  {custom type - empty character}
  TEmptyChar = (ecBlank,ecZero);

  {custom type - possible display options for results}
  TResultFormat = (currency_format, integer_format, real_format);

  {custom type - returns cell contents}
  TarrFloat = array[0..iSizeOfArray] of extended;

  {custom type - record which stores the data in the TXObject}
  TSummaryField = record
   FieldName: string;
   MathOp: TMathOp;
   Format: TResultFormat;
  end;

  {custom type - array of the previous custom type}
  TarrSummaryField = array[0..iSizeOfArray] of TSummaryField;

  {custom type - record which stores data for the current cell}
  TCellData = record
   Result: extended;
   Min: extended;
   Max: extended;
   Count: integer;
   Avg: extended;
   Sum: extended;
  end;
  {custom type - array of the previous custom type}
  TarrCellData = array[0..iSizeOfArray] of TCellData;
  PArrCellData = ^TarrCellData;


  {custom type - this is the object that the property editor is editing}
  TXObject = class(TPersistent)
  private
    FRowField: string;
    FColField: string;
    FSumField1: string;
    FSumField2: string;
    FSumField3: string;
    FMathField1: TMathOp;
    FMathField2: TMathOp;
    FMathField3: TMathOp;
    FFormatField1: TResultFormat;
    FFormatField2: TResultFormat;
    FFormatField3: TResultFormat;
    FOnChange: TNotifyEvent;
    FTable: TTable;
    procedure SetRowField(const value: string);
    procedure SetColField(const value: string);
    procedure SetSumField1(const value: string);
    procedure SetSumField2(const value: string);
    procedure SetSumField3(const value: string);
    procedure SetTable(value: TTable);
    procedure SetSumField1MathOp(const value: TMathOp);
    procedure SetSumField2MathOp(const value: TMathOp);
    procedure SetSumField3MathOp(const value: TMathOp);
    procedure SetSumField1Format(const value: TResultFormat);
    procedure SetSumField2Format(const value: TResultFormat);
    procedure SetSumField3Format(const value: TResultFormat);
  public
    procedure Changed;
  published
    property RowField: string read FRowField write SetRowField;
    property ColumnField: string read FColField write SetColField;
    property SummaryField1: string read FSumField1 write SetSumField1;
    property SummaryField2: string read FSumField2 write SetSumField2;
    property SummaryField3: string read FSumField3 write SetSumField3;
    property SumField1MathOp: TMathOp read FMathField1 write SetSumField1MathOp;
    property SumField2MathOp: TMathOp read FMathField2 write SetSumField2MathOp;
    property SumField3MathOp: TMathOp read FMathField3 write SetSumField3MathOp;
    property SumField1Format: TResultFormat read FFormatField1 write SetSumField1Format;
    property SumField2Format: TResultFormat read FFormatField2 write SetSumField2Format;
    property SumField3Format: TResultFormat read FFormatField3 write SetSumField3Format;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Table: TTable read FTable write SetTable;
  end;


  {the declaration for the crosstab component}
  TcwXTab = class(TStringGrid)
  private
    { Private declarations }
    Query1: TQuery;
    FXTab: TXObject;
    FTable: TTable;
    FAgg: boolean;
    FAutoResizeCells: boolean;
    FEmptyChar: TEmptyChar;
    procedure SetEmptyChar(value: TEmptyChar);
    procedure SetTable(value: TTable);
    procedure PopRows;
    procedure PopCols;
    procedure PopXTab;
    procedure AddSummaries;
    procedure RunQuery(const sSQL: string);
    procedure SetXtab(value: TXObject);
    procedure SetAgg(value: boolean);
    procedure SetCells(value: boolean);
    function GetCellContents(const iRow, iCol: integer): TarrFloat;
    procedure DrawCellContents(const iRow, iCol: integer; eArray: TarrFloat);
    function FindBiggestStr(const sCell: string): integer;
  protected
    { Protected declarations }
    arrFields: TarrSummaryField;
    FCurrent: boolean;
    procedure UpdateXTab; virtual;
    procedure XTabDrawCell(Sender: TObject; Col, Row: Longint;Rect: TRect; State: TGridDrawState);
  public
    { Public declarations }
    procedure Execute; virtual;
    procedure SaveXTab(const sTable: string; TblType: TTableType); virtual;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property Crosstab: TXObject read FXTab write SetXTab;
    property Table: TTable read FTable write SetTable;
    property AggRowsCols: boolean read FAgg write SetAgg;
    property AutoResize: boolean read FAutoResizeCells write SetCells;
    property EmptyCellChar: TEmptyChar read FEmptyChar write SetEmptyChar;
  end;

procedure Register;

implementation

{****VCL preferences************************************************************}

{constructor}
constructor TcwXTab.create(aOwner: TComponent);
begin
  inherited create(aOwner);
  Query1:= TQuery.create(self);
  FXTab:= TXObject.create;
  {set defaults for cwXTab}
  options:= options + [goColSizing, goRowSizing, goColMoving, goRowMoving];
  OnDrawCell:= XTabDrawCell;
  FEmptyChar:= ecBlank;
end;

{destructor}
destructor TcwXTab.destroy;
begin
 Query1.free;
 FXTab.free;
 inherited destroy;
end;


{set empty char}
procedure TcwXTab.SetEmptyChar(value: TEmptyChar);
begin
 if value <> FEmptyChar then
  begin
   FEmptyChar:= value;
  end;
end;


{set custom object which holds crosstab}
procedure TcwXTab.SetXTab(value : TXObject);
begin
 FXTab:= (value);
end;

{set Table}
procedure TcwXTab.SetTable(value: TTable);
begin
 if value <> FTable then
  begin
   FTable:= Value;
  end;
 {set object's table to match}
 FXTab.Table:= value;
end;


{set aggregate}
procedure TcwXTab.SetAgg(value: boolean);
begin
 if value <> FAgg then
  FAgg:= value;
end;

{set cell heights and widths}
procedure TcwXTab.SetCells(value: boolean);
begin
 if value <> FAutoResizeCells then
  FAutoResizeCells:= value;
end;

{***custom object preferences**************************************************}

{set field}
procedure TXObject.SetSumField1Format(const value: TResultFormat);
begin
 if value <> FFormatField1 then
  FFormatField1:= value;
end;

{set field}
procedure TXObject.SetSumField2Format(const value: TResultFormat);
begin
 if value <> FFormatField2 then
 FFormatField2:= value;
end;

{set field}
procedure TXObject.SetSumField3Format(const value: TResultFormat);
begin
if value <> FFormatField3 then
 FFormatField3:= value;
end;

{set field}
procedure TXObject.SetSumField1MathOp(const value: TMathOp);
begin
if value <> FMathField1 then
 FMathField1:= value;
end;

{set field}
procedure TXObject.SetSumField2MathOp(const value: TMathOp);
begin
if value <> FMathField2 then
 FMathField2:= value;
end;

{set field}
procedure TXObject.SetSumField3MathOp(const value: TMathOp);
begin
if value <> FMathField3 then
 FMathField3:= value;
end;

{set field}
procedure TXobject.SetRowField(const value: string);
begin
if value <> FRowField then
 FRowField:= value;
end;

{set field}
procedure TXobject.SetColField(const value: string);
begin
if value <> FColField then
 FColField:= value;
end;


{set changed}
procedure TXobject.Changed;
begin
 if Assigned(FOnChange) then FOnChange(Self);
end;

{set object's table reference}
procedure TXObject.SetTable(value: TTable);
begin
if value <> FTable then
 FTable:= value;
end;

{set field}
procedure TXObject.SetSumField1(const value: string);
begin
if value <> FSumField1 then
 FSumField1:= value;
end;

{set field}
procedure TXObject.SetSumField2(const value: string);
begin
if value <> FSumField2 then
 FSumField2:= value;
end;

{set field}
procedure TXObject.SetSumField3(const value: string);
begin
if value <> FSumField3 then
 FSumField3:= value;
end;




{***XTab custom routines*******************************************************}

{execute}
procedure TcwXTab.Execute;
begin

 {exit if table not set}
 if Table = nil then exit;

 screen.cursor:= crHourGlass;

 {initialise}
 try
  {initialise array}
  arrFields[0].FieldName:= Crosstab.SummaryField1;
  arrFields[0].MathOp:= Crosstab.SumField1MathOp;
  arrFields[0].Format:= Crosstab.SumField1Format;
  {***}
  arrFields[1].FieldName:= Crosstab.SummaryField2;
  arrFields[1].MathOp:= Crosstab.SumField2MathOp;
  arrFields[1].Format:= Crosstab.SumField2Format;
  {***}
  arrFields[2].FieldName:= Crosstab.SummaryField3;
  arrFields[2].MathOp:= Crosstab.SumField3MathOp;
  arrFields[2].Format:= Crosstab.SumField3Format;

  {execute methods to populate the crosstab}
  popRows;
  popCols;
  popXTab;

  {auto-resize}
  if FAutoResizeCells then begin
    UpdateXTab;
  end;

  {aggregates}
  if FAgg then AddSummaries; {add summary fields}

 {cleanup}
 finally
  FCurrent:= true;
  screen.cursor:= crDefault;
 end;

end;


{update XTAb}
procedure TcwXTab.UpdateXTab;
var
 FontMetrics: TTextMetric;
 w, wAgg: word;
 iInc: integer;
begin
  screen.cursor:= crHourGlass;
  {initialise}
  w:= 0;
  wAgg:= 1;
  {set row heights}
  self.RowHeights[0]:= 24;                             {set first row height to default}
  for iInc:= 0 to iSizeOfArray do
    if arrFields[iInc].FieldName <> '' then inc(w,1);   {find how many lines of text in cells}
  GetTextMetrics(Canvas.Handle, FontMetrics);           {get current text-metrics}
  for iInc:= 1 to (self.RowCount - 1) do               {apply height to rows}
    self.RowHeights[iInc]:= (FontMetrics.tmHeight + FontMetrics.tmInternalLeading) * w;
  {set column width for row-headers}
  w:= FindBiggestStr( self.cells[0,1] );               {get initial value}
  for iInc:= 1 to (self.rowCount - 1) do begin
    if w < FindBiggestStr( self.cells[0,iInc] ) then
      w:= FindBiggestStr( self.cells[0,iInc] );
  end;
  if w < 20 then w:= 20;
  self.colWidths[0]:= w;
  {set column widths for columns}
  if FAgg then inc(wAgg,1);
  for iInc:= 1 to (self.colCount - wAgg) do begin
    w:= FindBiggestStr( self.cells[iInc,0]);
    if w < 20 then w:= 20;
    self.ColWidths[iInc]:= w;
  end;
  {use default for last column}
  if FAgg then self.colWidths[self.colCount -1]:= 64;
  screen.cursor:= crDefault;
end;


{return required pixels for string passed}
function TcwXTab.FindBiggestStr(const sCell: string): integer;
begin
  result:= canvas.textWidth(sCell) + 3; {return size of string passed in pixels, plus a value for grid spacing}
end;


{run query - this is used by PopRows and PopCols to execute their SQL statements}
procedure TcwXTab.RunQuery(const sSQL: string);
begin
 Query1.active:= false;
 Query1.DatabaseName:= Table.DatabaseName;
 Query1.SQL.clear;
 Query1.SQL.Add(sSQL);
 Query1.active:= true;
end;


{populate rows - read distinct values from row field into the grid's rows}
procedure TcwXTab.PopRows;
var
 i, iAdd: integer;
begin

 {if row aggregate then add two additional rows as opposed to one}
 if FAgg then
  iAdd:= 2
 else
  iAdd:= 1;

 RunQuery('select distinct '+Crosstab.RowField+' from "'+Table.TableName+'"');

 Query1.first;
 i:= 1;
 self.rowCount:= Query1.recordCount + iAdd;
 while not query1.eof do
  begin
   self.cells[0,i]:= Query1.fields[0].text;
   inc(i);
   Query1.next;
  end;

 {add summary label}
 if FAgg then self.cells[0,(self.rowCount -1)]:= 'Total';

end;


{populate columns - read distinct values from column field into the grid's columns}
procedure TcwXTab.PopCols;
var
 i, iAdd: integer;
begin

 {if row aggregate then add two additional rows as opposed to one}
 if FAgg then
  iAdd:= 2
 else
  iAdd:= 1;

 RunQuery('select distinct '+Crosstab.ColumnField+' from "'+Table.TableName+'"');

 Query1.first;
 i:= 1;
 self.ColCount:= Query1.recordCount + iAdd;
 while not Query1.eof do
  begin
   self.cells[i,0]:= Query1.fields[0].text;
   inc(i);
   Query1.next;
  end;

 {add summary label}
 if FAgg then self.cells[(self.ColCount -1),0]:= 'Total';

end;


{populate cross-tab - the crux of the component. Lots of code that basically concerns itself with
 iterating through the table, finding values in the row and column fields that match the current
 cell row\column headings, and then performing the math operation as specified by the developer}
procedure TcwXTab.PopXTab;
var
 iRow, iCol, iFldCol, iFldRow: integer;
 eCell: PArrCellData;
 e: TArrFloat;
 bFindMinOrMax: boolean;
 wRow, wCol: word;
 iInc: integer;
begin
  New(eCell);
  try
   {find index in table of row and column fields}
   iFldCol:= Table.FieldbyName( Crosstab.ColumnField ).Index;
   iFldRow:= Table.FieldbyName( Crosstab.RowField ).Index;
   {iterate by row}
   wRow:= self.RowCount;
   if FAgg then dec(wRow,1);
   for iRow:= 1 to wRow do begin
    {iterate by row, column}
    wCol:= self.colCount;
  if FAgg then dec(wCol,1);
  for iCol:= 1 to wCol do begin
    {clean out cell array}
    for iInc:= 0 to iSizeOfArray do begin
      eCell^[iInc].Result:= 0;
      eCell^[iInc].Min:= 0;
      eCell^[iInc].Max:= 0;
      eCell^[iInc].Count:= 0;
      eCell^[iInc].Avg:= 0;
      eCell^[iInc].Sum:= 0;
     end;

   {check to see if developer has specified a max or min operation. We check for this, since either of these
    will require an iteration through the table, per field defined, in order to find an initial value
    for each cell\row which serve as a starting point for both min\max. Obviously, if the developer hasn't
    specified either of these operations then it's an un-neccessary delay that we can avoid}
    bFindMinOrMax:= false;
   for iInc:= 0 to iSizeOfArray do
    if (arrFields[iInc].MathOp = min) or (arrFields[iInc].MathOp = max) then bFindMinOrMax:= true;

   {developer needs min\max value}
   if bFindMinOrMax then
    {iterate through field array}
    for iInc:= 0 to iSizeOfArray do
     if (arrFields[iInc].FieldName <> '') and ( (arrFields[iInc].MathOp = min) or (arrFields[iInc].MathOp = max) ) then
      begin
     table.First;
     {iterate through table}
      while not table.eof do
       begin
       {get first value in field, where the cell's row\column headings are equal to the row\column fields}
        if (CompareText(Table.fields[iFldCol].Text,self.cells[iCol,0]) = 0)
         and (CompareText(Table.fields[iFldRow].Text,self.cells[0,iRow]) = 0) then
          begin
           eCell^[iInc].Min:= Parser.DVal(Table.fieldByName( arrFields[iInc].FieldName ).text);
           eCell^[iInc].Max:= Parser.DVal(Table.fieldByName( arrFields[iInc].FieldName ).text);
           break; {break from loop since we only need first value}
          end;
       table.next;
      end;
     end;

     {this is the start of the main crosstab routine...we now iterate through table, by values that
     match row and column, performing the developer's math operation}
     Table.first;
     while not Table.eof do
      begin
       if (CompareText(Table.fields[iFldCol].Text,self.cells[iCol,0]) = 0)
        and (CompareText(Table.fields[iFldRow].Text,self.cells[0,iRow]) = 0)
         then
          begin

           {add to cell array the summary values}
           for iInc:= 0 to iSizeOfArray do
            begin

             {switch on operation}
             if arrFields[iInc].FieldName <> '' then
               case arrFields[iInc].MathOp of
                sum:               {sum up values}
                 begin
                  eCell^[iInc].Result:=
                   eCell^[iInc].Result + Parser.DVal(Table.fieldByName( arrFields[iInc].FieldName ).text);
                 end;
                count:             {count}
                 begin
                  inc(eCell^[iInc].Count,1);
                  eCell^[iInc].Result:= eCell^[iInc].Count;
                 end;
                avg:               {average}
                 begin
                  inc(eCell^[iInc].Count,1);
                  eCell^[iInc].Sum:= eCell^[iInc].Sum + Parser.DVal(Table.fieldByName( arrFields[iInc].FieldName ).text);
                  eCell^[iInc].Result:= eCell^[iInc].Sum / eCell^[iInc].Count;
                 end;
                min:                {minimum}
                 begin
                  if Parser.DVal(Table.fieldByName( arrFields[iInc].FieldName ).Text ) < eCell^[iInc].Min then
                   eCell^[iInc].Min:= Parser.DVal(Table.fieldByName( arrFields[iInc].FieldName ).text);
                  eCell^[iInc].Result:= eCell^[iInc].Min;
                 end;
                max:                {maximum}
                 begin
                  if Parser.DVal(Table.fieldByName( arrFields[iInc].FieldName ).Text ) > eCell^[iInc].Max then
                   eCell^[iInc].Max:= Parser.DVal(Table.fieldByName( arrFields[iInc].FieldName ).Text );
                  eCell^[iInc].Result:= eCell^[iInc].Max;
                 end;
               end;

            end;
          end;

       Table.next;

      end;

     {set var-array to cell-array}
     for iInc:= 0 to iSizeOfArray do
      e[iInc]:= eCell^[iInc].Result;

     {call custom method which writes data to cell}
     DrawCellContents(iRow,iCol,e);

   {clean out var's for next cell}
   for iInc:= 0 to iSizeOfArray do
    begin
     eCell^[iInc].Result:= 0;
     eCell^[iInc].Min:= 0;
     eCell^[iInc].Max:= 0;
     eCell^[iInc].Count:= 0;
     eCell^[iInc].Avg:= 0;
     eCell^[iInc].Sum:= 0;
    end;

   end; {end for column FOR..loop}
  end;  {end for row FOR..loop}

 finally
  Dispose(eCell);
 end;

end;


{add summaries to the crosstab. Basically this routine will add a column and row, and
 populate both of these with the sum of the results in the respective cells.}
procedure TcwXTab.AddSummaries;
var
 i, iInc, iCol, iRow: integer;
 e, eRet: TArrFloat;
begin
 try

 {initialise}
 for iInc:= 0 to iSizeOfArray do begin
   e[iInc]:= 0;
   eRet[iInc]:= 0;
 end;


 {sum by row}
 for iRow:= 1 to (self.rowCount -1) do
  begin
   for iCol:= 1 to (self.colCount -1) do
    begin
     {if last column, then add summary}
     if iCol = (self.ColCount -1) then
      begin
       DrawCellContents(iRow,(self.ColCount -1),e); {draw result in last column}
      end
     else
      begin
       {get cell contents and add to array}
       eRet:= GetCellContents(iRow,iCol);
       for i:= 0 to iSizeOfArray do
        e[i]:= e[i] + eRet[i];
      end;
    end;

     {clean up}
     for iInc:= 0 to iSizeOfArray do begin
       e[iInc]:= 0;
       eRet[iInc]:= 0;
     end;

  end;


 {sum by column}
 for iCol:= 1 to (self.colCount -1) do
  begin
   for iRow:= 1 to (self.rowCount -1) do
    begin
     {if last column, then add summary}
     if iRow = (self.RowCount -1) then
      begin
       DrawCellContents((self.RowCount -1),iCol,e); {draw result in last row}
      end
     else begin
       {get cell contents and add to array}
       eRet:= GetCellContents(iRow,iCol);
       for i:= 0 to iSizeOfArray do e[i]:= e[i] + eRet[i];
     end;
    end;

    {clean up}
    for iInc:= 0 to iSizeOfArray do begin
      e[iInc]:= 0;
      eRet[iInc]:= 0;
    end;

  end;

 finally
 end;
end;


{draw cell contents - takes the array of floats and draws it into the cell as specified in
 the parameters}
procedure TcwXTab.DrawCellContents(const iRow, iCol: integer; eArray: TarrFloat);
var
 sCellNew, sCellCurrent: string;
 iInc: integer;
begin

 {initialise}
 sCellNew:= '';
 sCellCurrent:= '';

 {iterate through field array - draw to cells the result field in the matching cell array}
 for iInc:= 0 to iSizeOfArray do
  begin
   if arrFields[iInc].FieldName <> '' then
    begin
    {switch on format - notice that currency formats are rounded up}
    if eArray[iInc] <> 0 then
     case arrFields[iInc].format of
      currency_format:
       sCellNew:= format('%0.0m',[eArray[iInc]]);
      integer_format:
       sCellNew:= format('%0.0n',[eArray[iInc]]);
      real_format:
       sCellNew:= format('%0.2n',[eArray[iInc]]);
     end
    else
     if FEmptyChar = ecBlank then
      sCellNew:= ''
     else
      sCellNew:= '0';

   {we must now write the result to the cell - check to see if we should add a hard-return}
    if iInc < 2 then
     begin
      if arrFields[iInc + 1].FieldName <> '' then
       sCellCurrent:= sCellCurrent + sCellNew +#13#10 {add hard-return to move to next line in cell}
      else
       sCellCurrent:= sCellCurrent + sCellNew; {add line, but no hard-return}
     end
    else
     sCellCurrent:= sCellCurrent + sCellNew;

   end;
  end;

  {write to cell}
  self.cells[iCol,iRow]:= '';                  {empty cell}
  self.cells[iCol,iRow]:= sCellCurrent;       {add new value to cell}

end;


{get cell contents - returns the cell contents as an array of float. Note that this
 routine is quite complex, since we have to read the values from the cell and, without
 knowing how many lines there are in the cell, split the text into the array}
function TcwXTab.GetCellContents(const iRow, iCol: integer): TarrFloat;
var
 st1, st2, st3, st4: string;
 e: TArrFloat;
 iInc: integer;
begin
 try

  {initialise}
  st1:= '';
  st2:= '';
  st3:= '';
  st4:= '';
  for iInc:= 0 to iSizeOfArray do e[iInc]:= 0;

  {find cell string}
  st1:= self.cells[iCol,iRow];

  {find individual strings within the cell}
  st2:= copy(st1,1,pos(#13,st1)-1); {copies up to the first line-feed - if there is one}
  if st2 = '' then
   st2:= copy(st1,1,length(st1)) {copies the entire string, in case of no line-feed}
  else
   st3:= copy(st1,pos(#13,st1)+2,255); {definetly a line-feed, so copies from first line-feed onwards}

  st4:= copy(st3,1,pos(#13,st3)-1); {copies up to the next line-feed - if there is one}
  if st4 <> '' then
   begin
    {more than two lines in cell...}
    st4:= copy(st3,pos(#13,st3)+2,255); {copies from the next line-feed onwards}
    st3:= copy(st3,1,pos(#13,st3)-1); {copies up to the next line-feed}
   end;

  {write values to array (provided not empty)}
  if (Crosstab.SummaryField1 <> '') and not ((st2 = '') or (st2 = #13+#10) or (st2 = #13+#10+#13+#10))
   then e[0]:= Parser.DVal(st2);
  if (Crosstab.SummaryField2 <> '') and not ((st3 = '') or (st3 = #13+#10))
   then e[1]:= Parser.DVal(st3);
  if (Crosstab.SummaryField3 <> '') and (st4 <>'')
   then e[2]:= Parser.DVal(st4);

  result:= e;

 {cleanup}
 finally
 end;

end;


{***Paint Routines**************************************************************}

{draw cell - this routine allows a cell to contain more than one line of text}
procedure TcwXTab.XTabDrawCell(Sender: TObject; Col, Row: Longint; Rect: TRect; State: TGridDrawState);
var
 iRow, iCol : integer;
 pStr: pChar;
begin

 pStr:= StrAlloc(256);

 try

 iRow:= Row;
 iCol:= Col;

 {exit if cell is column\row - in both these cases we keep default since not aesthetically pleasing
  to have right-aligned text in row and column headers}
 if iCol = 0 then exit;
 if iRow = 0 then exit;

 with (Sender as TStringGrid) do

  with Canvas do
    begin

     {colour summary fields maroon}
     font.color:= (Sender as TStringGrid).Font.Color; {...default...}
     if FAgg then
      begin
       if (iCol = (self.colCount -1)) or (iRow = (self.rowCount -1)) then
        font.color:= clMaroon
       else
        Font.Color:= (Sender as TStringGrid).Font.Color;
      end;

     if (gdSelected in State) then
       begin
        Brush.Color:= clHighlight;
        Font.Color := clHighlightText;
       end
     else
      if (gdFixed in State) then
       Brush.Color:= self.FixedColor
      else
       Brush.Color:= self.Color;

     FillRect(Rect);
     SetBkMode(Handle, TRANSPARENT);

     StrPCopy(pStr,Cells[iCol,iRow]);

     {key line...notice the parameters}
     DrawText(Handle, pStr,Length( StrPAS(pStr) ), Rect, DT_RIGHT OR DT_WORDBREAK);

    end;

 finally
  StrDispose(pStr);
 end;

end;



{***I\O Routines*****************************************************************}

{save crosstab as a table. Note that parameter is the table name, so should be no
 greater than eight characters}
procedure TcwXTab.SaveXTab(const sTable: string; TblType: TTableType);
var
 Table1: TTable;
 st1, st2, st3, st4: string;
 iRow, iCol: integer;
 e: TArrFloat;
 wRow, wCol: word;
 iInc: integer;
begin
  Table1:= TTable.create(self);
  try
    {initialise}
    st1:= '';
    st2:= '';
    st3:= '';
    st4:= '';
    for iInc:= 0 to iSizeOfArray do e[iInc]:= 0;
   {create table}
    with Table1 do begin
      Active:= False;
      DatabaseName:= ExtractFilePath(sTable);
      TableName:= ExtractFileName(sTable);
      TableType:= TblType;
      with FieldDefs do begin
        Clear;
       {add fields - note I've made 20 the maximum size of the row\column labels}
       Add('RowField', ftString, 20, false);
       Add('ColField', ftString, 20, false);
       if Crosstab.SummaryField1 <> '' then Add('Summary1', ftFloat, 0, false);
       if Crosstab.SummaryField2 <> '' then Add('Summary2', ftFloat, 0, false);
       if Crosstab.SummaryField3 <> '' then Add('Summary3', ftFloat, 0, false);
      end;
      CreateTable;
      Table1.active:= true;
    end;
    {iterate by grid row}
    wRow:= self.RowCount -1;
    if FAgg then dec(wRow,1);
    for iRow:= 1 to wRow do begin
      {iterate by grid column}
      wCol:= self.colCount -1;
      if FAgg then dec(wCol,1);
      for iCol:= 1 to wCol do begin
        {this line fixes a bug which was adding blank rows un-necessary - basically, the FOR loop
        skips this iteration if the column or row value is blank}
        if (self.cells[iCol,0] = '') or (self.cells[0,iRow] = '') then continue;
        {get cell contents}
        e:= GetCellContents(iRow,iCol);
        {read cell contents into strings}
        st2:= FloatToStr(e[0]);
        st3:= FloatToStr(e[1]);
        st4:= FloatToStr(e[2]);
        {add record to table - note column field will be first field in table...}
        if Crosstab.SummaryField3 <> '' then
          table1.AppendRecord([self.cells[iCol,0],self.cells[0,iRow],Parser.DVal(st2),Parser.DVal(st3),Parser.DVal(st4)])
        else begin
          if Crosstab.SummaryField2 <> '' then
           table1.AppendRecord([self.cells[iCol,0],self.cells[0,iRow],Parser.DVal(st2),Parser.DVal(st3)])
          else
           if Crosstab.SummaryField1 <> '' then table1.AppendRecord([self.cells[iCol,0],self.cells[0,iRow],Parser.DVal(st2)])
        end;
        {clean-up}
        st1:= '';
        st2:= '';
        st3:= '';
        st4:= '';
        for iInc:= 0 to iSizeOfArray do e[iInc]:= 0;
      end;
    end;
    table1.active:= false;
  finally
    Table1.free;
  end;
end;

procedure Register;
begin
  RegisterComponents(eCompPage, [TcwXTab]);
end;

end.

