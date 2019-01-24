unit eLibTAGExtractor;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface
{$M+}

{$IFNDEF FPC}
uses
  SysUtils, Classes, Math;

//strings for error report
const
  GTNotFound = '> not found';
  SingleQuoteNotMatch = ''' not match';
  DoubleQuoteNotMatch = '" not match';
  EndScriptTagNotMatch = '</script> not match';
  EndStyleTagNotMatch = '</style> not match';
  KeyNotDefinedInTag = 'key not defined in tag';

type
  TOnHTMLParseError = procedure (const ErrorInfo,Raw: String) of object;

  THTMLItem = class
    private
     fPosition: Integer;
     fLength: Integer;
     function GetItem: String;
     procedure SetItem(Const Position,Length: Integer);
    public
      property Position: integer read fPosition;
      property Length: integer read fLength;
  end;

  THTMLParam = class
  private
    fRaw: THTMLItem;
    fKey: THTMLItem;
    fValue: THTMLItem;

    function GetRaw: String;
    function GetKey: String;
    function GetValue: String;
  public
    constructor Create;
    destructor Destroy; override;
  published
    property Key: String read GetKey;
    property Value: String read GetValue;
    property Raw: String read GetRaw;
  end;

  THTMLTag = class
  private
    fOnHTMLParseError: TOnHTMLParseError;
    fName: THTMLItem;
    fRaw: THTMLItem;
    fParams: TList; //Maybe is nil !!!

    procedure decodeParam;
    function GetParam: TList;
    function GetName: String;
    function GetRaw: String;
    procedure SetName(const Position,Length: Integer);
  public

    constructor Create;
    destructor Destroy; override;
  published
    property Name: String read GetName; // uppercased TAG (without <>)
    property Raw: String read GetRaw; // raw TAG (parameters included) as read from input file (without<>)
    property Params: TList read GetParam; // raw TAG (parameters included) as read from input file (without<>)
  end;

  TTAGExtractor = class(TObject)
  private
    fOnHTMLParseError: TOnHTMLParseError;
    LastTagName: String;
    LTPos,GTPos,LastGTPos: Integer;

    procedure Init;
    procedure Final;
    procedure AddText;
    procedure AddTag;
  public
    parsed:TList;
    Memory: TMemoryStream;
    constructor Create;
    destructor Destroy; override;
    procedure Execute;
  published
    property OnHTMLParseError: TOnHTMLParseError read fOnHTMLParseError write fOnHTMLParseError;
  end;

  //Search first SubStr in buffer from StartPos with case insensitive,if found return pos else return -1
  function FirstSubStrIInBuffer(const SubStr: PChar; const Buffer,BufLen,StartPos: Integer): Integer;
  //Search first char in buffer from StartPos,if found return pos else return -1
  function FirstCharInBuffer(const C: Char; const Buffer,BufLen,StartPos: Integer): Integer;
  //Search first char in buffer from StartPos not in quotes,if found return pos else return -1
  function FirstCharInBufferNotInQuotes(const C: Char; const Buffer,BufLen,StartPos: Integer): Integer;
  //Search first white space in buffer from StartPos,if found return pos else return -1
  //C <-- Nonsence,just in order to clone above function
  function FirstWhiteSpaceInBufferNotInQuotes(const C: Char; const Buffer,BufLen,StartPos: Integer): Integer;
  //Skip TAB #10 #13 SP, if all rest chars are white space return -1 else return Non_White_Space's pos
  function SkipWhiteSpaces(const Buffer,Length,StartPos: Integer): Integer;
  //Reverse skip TAB #10 #13 SP, if all front chars are white space return -1 else return Non_White_Space's pos
  function ReverseSkipWhiteSpaces(const Buffer,Length,StartPos: Integer): Integer;
  function IsHTMLFile(const Buffer,Length: Integer): Boolean;
{$ENDIF}

implementation

{$IFNDEF FPC}
function FirstSubStrIInBuffer(const SubStr: PChar; const Buffer,BufLen,StartPos: Integer): Integer;
asm
  //eax <-- SubStr
  //edx <-- Buffer
  //ecx <-- BufLen

  //Comment out for speed. In this unit, it is impossible! But if you copy and
  //paste this function to other place, it is safe not comment out following 3
  //blocks

  //SubStr is NULL ?
  //test eax,eax
  //je @@Exit

  //Buffer is NULL ?
  //test edx,edx
  //je @@Exit

  //BufLen <= 0 ?
  //cmp ecx,0
  //jle @@Exit

  //BufLen <= StartPos ?
  cmp ecx,StartPos
  jle @@Exit

  //Save registers
  push esi
  push edi

  mov esi,eax

  mov al,[esi]
  cmp al,0      //terminal char
  je @@NotFound

  mov edi,edx
  add edi,StartPos
  sub ecx,StartPos

@@Prepare:
  mov al,[esi]

@@CompareFirstChar:
  //jecxz @@NotFound, optimize for speed, 2001.11.6
  test ecx,ecx        //to the end of buffer
  jz @@NotFound

  mov ah,[edi]
  inc edi
  dec ecx
  cmp ah,al
  je @@CompareRest
  cmp al,'a'
  jb @@SourceToUpper
  cmp al,'z'
  ja @@CompareFirstChar
  sub al,20h

@@SourceToUpper:
  cmp ah,'a'
  jb @@SecondCompare
  cmp ah,'z'
  ja @@CompareFirstChar
  sub ah,20h

@@SecondCompare:
  cmp ah,al
  jne @@CompareFirstChar

@@CompareRest:
  //save registers
  push esi
  push edi
  push ecx

  //advance pointer
  inc esi

@@CompareStrI:
  //jecxz @@PrepareGoBack, optimize for speed, 2001.11.6
  test ecx,ecx             //to the end of buffer
  jz @@PrepareGoBack

  //lodsb, optimize for speed, 2001.11.6
  mov al,[esi]
  inc esi

  cmp al,0      //terminal char
  je @@Matched
  mov ah,[edi]
  inc edi
  dec ecx
  cmp ah,al
  je @@CompareStrI
  cmp al,'a'
  jb @@SourceToUpperRest
  cmp al,'z'
  ja @@PrepareGoBack
  sub al,20h

@@SourceToUpperRest:
  cmp ah,'a'
  jb @@SecondCompareRest
  cmp ah,'z'
  ja @@PrepareGoBack
  sub ah,20h

@@SecondCompareRest:
  cmp ah,al
  je @@CompareStrI
  jmp @@PrepareGoBack

@@Matched:
  //balance stack
  pop ecx
  pop edi
  pop esi

  mov eax,edi
  sub eax,edx

  //restore registers
  pop edi
  pop esi
  jmp @@Exit1

@@PrepareGoback:
  //restore registers
  pop ecx
  pop edi
  pop esi
  jmp @@Prepare

@@NotFound:
  //restore registers
  pop edi
  pop esi

@@Exit:
  xor eax,eax

@@Exit1:

  dec eax
end;

function FirstCharInBuffer(const C: Char; const Buffer,BufLen,StartPos: Integer): Integer;
asm
  //eax <-- C
  //edx <-- Buffer
  //ecx <-- BufLen

  //Comment out for speed. In this unit, it is impossible! But if you copy and
  //paste this function to other place, it is safe not comment out following 2
  //blocks

  //Buffer is NULL ?
  //test edx,edx
  //je @@Exit

  //BufLen <= 0 ?
  //cmp ecx,0
  //jle @@Exit

  //BufLen <= StartPos ?
  cmp ecx,StartPos
  jle @@Exit

  //save register
  push edi

  mov edi,edx
  add edi,StartPos
  sub ecx,StartPos

@@Compare:
  //repne scasb, optimize for speed, 2001.11.6
  cmp al,[edi]
  je @@Found
  inc edi
  dec ecx
  test ecx,ecx
  jz @@NotFound
  jmp @@Compare

@@Found:
  mov eax,edi
  sub eax,edx

  //restore register
  pop edi
  jmp @@OK

@@NotFound:
  //restore register
  pop edi

@@Exit:
  xor eax,eax
  dec eax

@@OK:
end;

function FirstCharInBufferNotInQuotes(const C: Char; const Buffer,BufLen,StartPos: Integer): Integer;
asm
  //eax <-- C
  //edx <-- Buffer
  //ecx <-- BufLen

  //Comment out for speed. In this unit, it is impossible! But if you copy and
  //paste this function to other place, it is safe not comment out following 2
  //blocks

  //Buffer is NULL ?
  //test edx,edx
  //je @@Exit

  //BufLen <= 0 ?
  //cmp ecx,0
  //jle @@Exit

  //BufLen <= StartPos ?
  cmp ecx,StartPos
  jle @@Exit

  //save register
  push edi

  mov edi,edx
  add edi,StartPos
  sub ecx,StartPos

@@Compare:
  //jecxz @@NotFound, optimize for speed, 2001.11.6
  test ecx,ecx
  jz @@NotFound

  mov ah,[edi]
  inc edi
  dec ecx
  cmp ah,'"'
  je @@SkipDoubleQuotes
  cmp ah,''''
  je @@SkipSingleQuotes
  cmp ah,al
  jne @@Compare

  mov eax,edi
  sub eax,edx

  //restore register
  pop edi
  jmp @@DecEax

@@SkipDoubleQuotes:
  //jecxz @@NotFound, optimize for speed, 2001.11.6
  test ecx,ecx
  jz @@NotFound

  mov ah,[edi]
  inc edi
  dec ecx
  cmp ah,'"'
  jne @@SkipDoubleQuotes

  //escape ? 2001.11.6
  cmp [edi-2],'\'
  je @@SkipDoubleQuotes

  jmp @@Compare

@@SkipSingleQuotes:
  //jecxz @@NotFound, optimize for speed, 2001.11.6
  test ecx,ecx
  jz @@NotFound

  mov ah,[edi]
  inc edi
  dec ecx
  cmp ah,''''
  jne @@SkipSingleQuotes

  //escape ? 2001.11.6
  cmp [edi-2],'\'
  je @@SkipSingleQuotes

  jmp @@Compare

@@NotFound:
  //restore register
  pop edi

@@Exit:
  xor eax,eax

@@DecEax:
  dec eax
end;

(*
function FirstWhiteSpaceInBufferNotInQuotes(const Buffer,BufLen,StartPos: Integer): Integer;
var
  Pos,TrialPos: Integer;
begin
  Pos:= MaxInt;
  TrialPos:= FirstCharInBufferNotInQuotes(#9,Buffer,BufLen,StartPos);
  if (TrialPos > 0) and (TrialPos < Pos) then Pos:= TrialPos;

  TrialPos:= FirstCharInBufferNotInQuotes(#10,Buffer,BufLen,StartPos);
  if (TrialPos > 0) and (TrialPos < Pos) then Pos:= TrialPos;

  TrialPos:= FirstCharInBufferNotInQuotes(#13,Buffer,BufLen,StartPos);
  if (TrialPos > 0) and (TrialPos < Pos) then Pos:= TrialPos;

  TrialPos:= FirstCharInBufferNotInQuotes(#32,Buffer,BufLen,StartPos);
  if (TrialPos > 0) and (TrialPos < Pos) then Pos:= TrialPos;

  if Pos = MaxInt then Pos:= -1;

  Result:= Pos;
end;
*)

function FirstWhiteSpaceInBufferNotInQuotes(const C: Char; const Buffer,BufLen,StartPos: Integer): Integer;
asm
  //eax <-- C   (Nonsence)
  //edx <-- Buffer
  //ecx <-- BufLen

  //Comment out for speed. In this unit, it is impossible! But if you copy and
  //paste this function to other place, it is safe not comment out following
  //block

  //BufLen <= 0 ?
  //cmp ecx,0
  //jle @@Exit

  //BufLen <= StartPos ?
  cmp ecx,StartPos
  jle @@Exit

  //save register
  push edi

  mov edi,edx
  add edi,StartPos
  sub ecx,StartPos

@@Compare:
  //jecxz @@NotFound, optimize for speed, 2001.11.6
  test ecx,ecx
  jz @@NotFound

  mov ah,[edi]
  inc edi
  dec ecx
  cmp ah,'"'
  je @@SkipDoubleQuotes
  cmp ah,''''
  je @@SkipSingleQuotes
  cmp ah,9
  je @@Found
  cmp ah,10
  je @@Found
  cmp ah,13
  je @@Found
  cmp ah,32
  jne @@Compare

@@Found:
  mov eax,edi
  sub eax,edx

  //restore register
  pop edi
  jmp @@DecEax

@@SkipDoubleQuotes:
  //jecxz @@NotFound, optimize for speed, 2001.11.6
  test ecx,ecx
  jz @@NotFound

  mov ah,[edi]
  inc edi
  dec ecx
  cmp ah,'"'
  jne @@SkipDoubleQuotes

  //escape ? 2001.11.6
  cmp [edi-2],'\'
  je @@SkipDoubleQuotes

  jmp @@Compare

@@SkipSingleQuotes:
  jecxz @@NotFound
  mov ah,[edi]
  inc edi
  dec ecx
  cmp ah,''''
  jne @@SkipSingleQuotes

  //escape ? 2001.11.6
  cmp [edi-2],'\'
  je @@SkipSingleQuotes

  jmp @@Compare

@@NotFound:
  //restore register
  pop edi

@@Exit:
  xor eax,eax

@@DecEax:
  dec eax
end;

(*
function SkipWhiteSpaces(const Buffer,Length,StartPos: Integer): Integer;
var
  P: PChar;
  Remain: Integer;
begin
  if (StartPos < 0) or (StartPos >= Length) then
  begin // over bounds
    Result:= -1;
    Exit;
  end;

  P:= PChar(Buffer + StartPos);
  Remain:= Length - StartPos;
  Result:= StartPos;

  while Remain > 0 do
  case P^ of
  #9,#10,#13,#32:
    begin
      Inc(P);
      Inc(Result);
      Dec(Remain);
    end;
  else
    break;
  end;

  if Result = Length then
    Result:= -1;
end;
*)

//2001.11.6
//optimize for speed
function SkipWhiteSpaces(const Buffer,Length,StartPos: Integer): Integer;
asm
  //eax <-- Buffer
  //edx <-- Length
  //ecx <-- StartPos

  //Comment out for speed. In this unit, it is impossible! But if you copy and
  //paste this function to other place, it is safe not comment out following 2
  //blocks

  //Buffer is NULL ?
  //test eax,eax
  //jz @@Exit

  //Length <= 0 ?
  //cmp edx,0
  //jle @@Exit

  //StartPos < 0 ?
  cmp ecx,0
  jl @@Exit

  //StartPos >= Length
  cmp ecx,edx
  jge @@Exit

  //store buffer address
  push eax

  //move pointer
  add eax,ecx
  sub edx,ecx

@@Compare:
  test edx,edx
  jz @@Exit

  mov cl,[eax]
  inc eax
  dec edx
  cmp cl,9
  je @@Compare
  cmp cl,10
  je @@Compare
  cmp cl,13
  je @@Compare
  cmp cl,32
  je @@Compare

  //get buffer address
  pop edx
  sub eax,edx
  dec eax
  jmp @@OK

@@Exit:
  xor eax,eax
  dec eax

@@OK:
end;

(*
function ReverseSkipWhiteSpaces(const Buffer,Length,StartPos: Integer): Integer;
var
  P: PChar;
  Remain: Integer;
begin
  if (StartPos < 0) or (StartPos >= Length) then
  begin // over bounds
    Result:= -1;
    Exit;
  end;

  P:= PChar(Buffer + StartPos);
  Remain:= StartPos;
  Result:= StartPos;
  while Remain >= 0 do
  case P^ of
  #9,#10,#13,#32:
    begin
      Dec(P);
      Dec(Result);
      Dec(Remain);
    end;
  else
    break;
  end;
end;
*)

//2001.11.6
//optimize for speed
function ReverseSkipWhiteSpaces(const Buffer,Length,StartPos: Integer): Integer;
asm
  //eax <-- Buffer
  //edx <-- Length
  //ecx <-- StartPos

  //Comment out for speed. In this unit, it is impossible! But if you copy and
  //paste this function to other place, it is safe not comment out following 2
  //blocks

  //Buffer is NULL ?
  //test eax,eax
  //jz @@Exit

  //Length <= 0 ?
  //cmp edx,0
  //jle @@Exit

  //StartPos < 0 ?
  cmp ecx,0
  jl @@Exit

  //StartPos >= Length
  cmp ecx,edx
  jge @@Exit

  //store buffer address
  push eax

  //move pointer
  add eax,ecx
  sub edx,ecx

@@Compare:
  test edx,edx
  jz @@Exit

  mov cl,[eax]
  dec eax
  dec edx
  cmp cl,9
  je @@Compare
  cmp cl,10
  je @@Compare
  cmp cl,13
  je @@Compare
  cmp cl,32
  je @@Compare

  //get buffer address
  pop edx
  sub eax,edx
  inc eax
  jmp @@OK

@@Exit:
  xor eax,eax
  dec eax

@@OK:
end;

function IsHTMLFile(const Buffer,Length: Integer): Boolean;
begin
  Result:= Max(Max(
    FirstSubStrIInBuffer('<html',Buffer,Length,0),
    FirstSubStrIInBuffer('<script',Buffer,Length,0)),
    FirstSubStrIInBuffer('<body',Buffer,Length,0)) >= 0;
end;

{THTMLItem}

function THTMLItem.GetItem: String;
begin
  try
    if (fPosition <> 0) and (fLength > 0) then
    begin
      SetLength(Result,fLength);
      Move(Pointer(fPosition)^,Result[1],fLength);
    end
    else
      Result:= '';
  except
    Result:= '';
  end;
end;

procedure THTMLItem.SetItem(const Position,Length: Integer);
begin
  fPosition:= Position;
  fLength:= Length;
end;

{THTMLParam}

constructor THTMLParam.Create;
begin
  inherited Create;
  fRaw:= THTMLItem.Create;
  fKey:= THTMLItem.Create;
  fValue:= THTMLItem.Create;
end;

destructor THTMLParam.Destroy;
begin
  fRaw.Free;
  fKey.Free;
  fValue.Free;
  inherited Destroy;
end;

function THTMLParam.GetRaw: String;
begin
  Result:= fRaw.GetItem;
end;

function THTMLParam.GetKey: String;
begin
  Result:= fKey.GetItem;
end;

function THTMLParam.GetValue: String;
begin
  Result:= fValue.GetItem;
end;

{THTMLTag}

constructor THTMLTag.Create;
begin
  inherited Create;
  fParams:= nil;
  fName:= THTMLItem.Create;
  fRaw:= THTMLItem.Create;
end;

destructor THTMLTag.Destroy;
var
  I: Integer;
begin
  if fParams <> nil then begin
    for I:= 0 to fParams.Count - 1 do begin
      THTMLparam(fParams[I]).Free;
    end;
    fParams.Free;
  end;
  fName.Free;
  fRaw.Free;
  inherited Destroy;
end;

function THTMLTag.GetParam: TList;
begin
  if fParams = nil then decodeParam;
  Result:= fParams;
end;

function THTMLTag.GetName: String;
begin
  Result:= fName.GetItem;
end;

function THTMLTag.GetRaw: String;
begin
  Result:= fRaw.GetItem;
end;

procedure THTMLTag.SetName(const Position, Length: Integer);
var
  SpacePos: Integer;
begin
  fRaw.SetItem(Position,Length);
  SpacePos:= FirstWhiteSpaceInBufferNotInQuotes(' ',Position,Length,0);
  if SpacePos < 0 then begin //Space not found, so while content is tag name
    fName.SetItem(Position, Length);
  end
  else begin
    fName.SetItem(Position, SpacePos);
  end;
end;

//     SpacePos EqualPos      NewSpacePos
//     |        |             |
//     |        |             |
//    a   href  =      "XXXXX"    taget=_blank       title='XXXX  X"XXXXX'
//        |  |         |
//        |            |
//        NonSpacePos  NewNonSpacePos
procedure THTMLTag.decodeParam;
var
  Position,
  Length,
  SpacePos, NonSpacePos,
  EqualPos, KeyReversePos: Integer;
  NewSpacePos, NewNonSpacePos: Integer;
  ValueStartPos, ValueEndPos: Integer;
  Param: THTMLParam;
  P: PChar;
begin
  Position:= fRaw.Position;
  Length:= fRaw.Length;
  SpacePos:= FirstWhiteSpaceInBufferNotInQuotes(' ',Position,Length,0);
    repeat
      Inc(SpacePos);
      NonSpacePos:= SkipWhiteSpaces(Position,Length,SpacePos);
      if NonSpacePos < 0 then Exit;

      EqualPos:= FirstCharInBufferNotInQuotes('=',Position,Length,NonSpacePos);

      //add non equal string as a key
      if EqualPos < 0 then begin
        EqualPos:= Length;
        KeyReversePos:= ReverseSkipWhiteSpaces(Position,Length,EqualPos - 1);

        if KeyReversePos >= NonSpacePos then begin
          if fParams = nil then begin
            fParams:= TList.Create;
          end;
          Param:= THTMLParam.Create;
          Param.fKey.SetItem(Position + NonSpacePos,KeyReversePos - NonSpacePos + 1);
          Param.fRaw.SetItem(Position + SpacePos,Length - SpacePos);
          fParams.Add(Param);
        end;

        Exit;
      end;

      NewNonSpacePos:= SkipWhiteSpaces(Position,Length,EqualPos + 1);
      if NewNonSpacePos < 0 then NewNonSpacePos:= Length;

      NewSpacePos:= FirstWhiteSpaceInBufferNotInQuotes(' ',Position,Length,NewNonSpacePos);
      if NewSpacePos < 0 then NewSpacePos:= Length;

      //Skip " or '
      ValueStartPos:= NewNonSpacePos;
      P:= PChar(Position + ValueStartPos);
      if (P^ = '"') or (P^ = '''') then
        Inc(ValueStartPos);
      ValueEndPos:= NewSpacePos - 1;
      P:= PChar(Position + ValueEndPos);
      if (P^ = '"') or (P^ = '''') then
        Dec(ValueEndPos);

      KeyReversePos:= ReverseSkipWhiteSpaces(Position,Length,EqualPos - 1);
      if KeyReversePos >= NonSpacePos then
      begin
        if fParams = nil then
          fParams:= TList.Create;
        Param:= THTMLParam.Create;
        Param.fKey.SetItem(Position + NonSpacePos,KeyReversePos - NonSpacePos + 1);
        Param.fValue.SetItem(Position + ValueStartPos,ValueEndPos - ValueStartPos + 1);
        Param.fRaw.SetItem(Position + SpacePos,NewSpacePos - SpacePos + 1);
        fParams.Add(Param);
      end
      else //key not defined in tag!
      if Assigned(fOnHTMLParseError) then
        fOnHTMLParseError(KeyNotDefinedInTag,'<' + fRaw.GetItem + '>');

      SpacePos:= NewSpacePos;
    until false;
end;

{TTAGExtractor}

constructor TTAGExtractor.Create;
begin
  inherited Create;

  Memory:= TMemoryStream.Create;
  Parsed:= TList.Create;
end;

destructor TTAGExtractor.Destroy;
begin
  Memory.Free;

  Final;
  Parsed.Free;

  inherited Destroy;
end;

procedure TTAGExtractor.Init;
begin
  Final;

  LTPos:= 0;
  GTPos:= 0;
  LastGTPos:= -1;
end;

procedure TTAGExtractor.Final;
var
  I: Integer;
begin
  try
    for I:= 0 to Parsed.Count - 1 do
      TObject(Parsed[I]).Free;
  except
  end;

  Parsed.Clear;
end;

procedure TTAGExtractor.AddText;
begin
end;

procedure TTAGExtractor.AddTag;
var
  HTMLTag: THTMLTag;
  Len,Buffer: Integer;
  P: PChar;
  First3Chars: String;
begin
  Len:= GTPos - LTPos - 1;
  if Len > 0 then
  begin
    Buffer:= Integer(Memory.Memory);
    P:= PChar(Buffer + LTPos + 1);

    if P^ = '%' then begin//<%....%>
    end
    else
    begin
      SetLength(First3Chars,3);
      try
        move(P^,First3Chars[1],3);
      except
        First3Chars:= '';
      end;

      if SameText(First3Chars,'!--') then begin
      end
      else
        try
          HTMLTag:= THTMLTag.Create;
          HTMLTag.fOnHTMLParseError:= fOnHTMLParseError;
          HTMLTag.SetName(Buffer + LTPos + 1,Len);
          LastTagName:= HTMLTag.GetName;
          Parsed.Add(HTMLTag);
        except
        end;
    end;
  end;

  LTPos:= GTPos;
  LastGTPos:= GTPos;
end;

procedure TTAGExtractor.Execute;
var
  P: PChar;
  Buffer,Size: Integer;
  ErrorHTMLItem: THTMLItem;
  First3Chars: string;       { ALEX }
begin
  Init;
  Buffer:= Integer(Memory.Memory);
  Size:= Memory.Size;

  //2001.11.6
  //add this line, get rid of many many condition compares !!!
  if Size <= 0 then Exit;

  //file is html file ?
  if not IsHtmlFile(Buffer,Size) then
  begin//maybe .js or .css file
    LTPos:= Size;
    AddText;
    Exit;
  end;

  repeat
    P:= PChar(Buffer + LTPos);

    if P^ = '<' then
    begin
      Inc(P);

      if P^ = '%' then
      begin
        GTPos:= FirstSubStrIInBuffer('%>',Buffer,Size,LTPos + 2);
        if GTPos > 0 then Inc(GTPos);
      end
      {---- ALEX 2001.11.5 ----}
      else if P^ = '!' then
      begin
        SetLength(First3Chars,3);
        try
          move(P^,First3Chars[1],3);
        except
          First3Chars:= '';
        end;
        if SameText(First3Chars,'!--') then
        begin
          GTPos:= FirstSubStrIInBuffer('-->',Buffer,Size,LTPos + 2);
          if GTPos > 0 then inc(GTPos, 2);
        end
        else
          GTPos:= FirstCharInBufferNotInQuotes('>',Buffer,Size,LTPos + 1);
      end
      {---- ALEX 2001.11.5 ----}
      else
        //search ">"
        GTPos:= FirstCharInBufferNotInQuotes('>',Buffer,Size,LTPos + 1);

      //GT not found
      if GTPos < 0 then
      begin
        if Assigned(fOnHTMLParseError) then
        begin
          ErrorHTMLItem:= THTMLItem.Create;
          with ErrorHTMLItem do
          begin
            SetItem(Buffer + LTPos,Size - LTPos);
            fOnHTMLParseError(GTNotFound,GetItem);
            Free;
          end;
        end;
        Exit;
      end;

      AddTag;
    end
    else
    begin
      //search "<"
      if SameText(LastTagName,'script') then
      begin
        LTPos:= FirstSubStrIInBuffer('</script',Buffer,Size,GTPos + 1);
        //</script> not found
        if LTPos < 0 then
        begin
          if Assigned(fOnHTMLParseError) then
          begin
            ErrorHTMLItem:= THTMLItem.Create;
            with ErrorHTMLItem do
            begin
              SetItem(Buffer + GTPos + 1,Size - GTPos - 1);
              fOnHTMLParseError(EndScriptTagNotMatch,GetItem);
              Free;
            end;
          end;
          Exit;
        end;
      end
      else if SameText(LastTagName,'style') then
      begin
        LTPos:= FirstSubStrIInBuffer('</style',Buffer,Size,GTPos + 1);
        //</style> not found
        if LTPos < 0 then
        begin
          if Assigned(fOnHTMLParseError) then
          begin
            ErrorHTMLItem:= THTMLItem.Create;
            with ErrorHTMLItem do
            begin
              SetItem(Buffer + GTPos + 1,Size - GTPos - 1);
              fOnHTMLParseError(EndStyleTagNotMatch,GetItem);
              Free;
            end;
          end;
          Exit;
        end;
      end
      else
      begin
        LTPos:= FirstCharInBuffer('<',Buffer,Size,GTPos + 1);
        //"<" not Found
        if LTPos < 0 then begin
          LTPos:= Size;
          AddText;
          Exit;
        end;
      end;

      AddText;
    end;
  until false;
end;
{$ENDIF}

end.
