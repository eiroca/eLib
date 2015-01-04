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
unit eLibCore;

interface

uses
  SysUtils, Classes;

type
  TCharSet = TSysCharSet;

const

  SInvalidInteger = 65408;
  SInvalidFloat = 65409;
  SInvalidDate = 65410;
  SInvalidTime = 65411;
  SInvalidDateTime = 65412;
  STimeEncodeError = 65413;
  SDateEncodeError = 65414;
  SOutOfMemory = 65415;
  SInOutError = 65416;
  SFileNotFound = 65417;
  SInvalidFilename = 65418;
  STooManyOpenFiles = 65419;
  SAccessDenied = 65420;
  SEndOfFile = 65421;
  SDiskFull = 65422;
  SInvalidInput = 65423;
  SDivByZero = 65424;
  SRangeError = 65425;
  SIntOverflow = 65426;
  SInvalidOp = 65427;
  SZeroDivide = 65428;
  SOverflow = 65429;
  SUnderflow = 65430;
  SInvalidPointer = 65431;
  SInvalidCast = 65432;
  SAccessViolation = 65433;
  SStackOverflow = 65434;
  SControlC = 65435;
  SPrivilege = 65436;
  SOperationAborted = 65437;
  SException = 65438;
  SExceptTitle = 65439;
  SInvalidFormat = 65440;
  SArgumentMissing = 65441;
  SInvalidVarCast = 65442;
  SInvalidVarOp = 65443;
  SDispatchError = 65444;
  SReadAccess = 65445;
  SWriteAccess = 65446;
  SResultTooLong = 65447;
  SFormatTooLong = 65448;
  SVarArrayCreate = 65449;
  SVarNotArray = 65450;
  SVarArrayBounds = 65451;
  SExternalException = 65452;

  SShortMonthNames = 65472;
  SLongMonthNames = 65488;
  SShortDayNames = 65504;
  SLongDayNames = 65511;

type
  Encoding = class
    public
     class function HexDecode(src: string): string; static;
     class function HexEncode(const src: string): string; static;
  end;

type
  Parser = class
    public
     class function DVal(s: string): double; static;
     class function IVal(const s: string): integer; static;
  end;

type
  CRC = class
    public
     class function  CalcCRC(const buf: array of byte): integer;
     class procedure UpdateCRC(var CRC: integer; const buf: array of byte; from: integer = -1; size: integer = -1);
  end;

type
  Crypt = class
    public
     class function SimpleCrypt(const msg, key: string): string; static;
     class function SimpleDecrypt(const msg, key: string): string; static;
  end;

type
  StrUtil = class
    public
     class function RemoveSpace(const inStr: string): string; static;
     class function ShiftWord(var s: string; const separator: string): string; static;
     class function TabToSpace(const s: string; const tab: string): string; static;
     class function Chars(n: integer; ch: char = ' '): string; static;
     class function OutFloat(x: double; l, d: integer): string; static;
     class function isLitteral(ch: char): boolean; static;
  end;

const
  NoDate = -1e10;

type
  DateUtil = class
    public
     class procedure SetLongYear; static;
     class function  DateToYMD(aDate: TDateTime; time: boolean): string; static;
     class function  YMDToDate(const YMD: string; time: boolean): TDateTime; static;
     class function  AddWorkDay(aDate: TDateTime; dd: integer): TDateTime; static;
     class function  IsNotWorkDay(aDate: TDateTime): boolean; static;
     class function  GetTimeLen(const duration: string): TDateTime; static;
     class function  MyStrToDate(aDate: string): TDateTime; static;
     class function  MyDateToStr(aDate: TDateTime): string; static;
     class function  ChangeDay(aDate: TDateTime; newY: word; newM: word; newD: word): TDateTime; static;
  end;

type
  TURL = class
    private
      FURL: string;
      FProtocol: string;
      FDomain: string;
      FPath: string;
      FFileName: string;
    protected
      procedure SetURL(aURL: string);
    public
      constructor Create; overload;
      constructor Create(aURL: string); overload;
      procedure MakeURL(aProtocol: string = 'http'; aDomain: string = ''; aPath: string = ''; aFileName: string = '');
      function GetBasePath(withPath: boolean = true): string;
      function Rel2Abs(aURL: string): string;
      property URL: string read FURL write SetURL;
      property Protocol: string read FProtocol;
      property Domain: string read FDomain;
      property Path: string read FPath;
      property FileName: string read FFileName;
  end;

type
  TProgressNotify = procedure (sender: TObject) of object;

  IProgress = interface
     function  GetAborted: boolean;
     procedure Init(aMin, aMax: integer);
     procedure SetProgress(count: integer);
     procedure Step;
  end;


type
  ECSVEOF = class(Exception);

  CSVCallBack = function (const row: string; fields: TStrings): boolean of object;

  TCSVReader = class
    public
      LineSep : TCharSet;
      FieldSep: TCharSet;
      Escape  : TCharSet;
      Fld     : TStringList;
      count   : integer;
    private
      progress: IProgress;
      function GetChar(var src: TextFile): char;
      function ExecuteCallBack(var row: string; callBack: CSVCallBack): boolean;
    public
      constructor Create;
      procedure Process(path: string; callBack: CSVCallBack; progress: IProgress);
  end;

type
  ECounterException = class(Exception);
  EInvalidID      = class(ECounterException);
  EInvalidName    = class(ECounterException);
  EInvalidDataSet = class(ECounterException);
  EInvalidCounter = class(ECounterException);

  TCounterSet = class;
  ICounterStorage = interface;

  TCounter = class
    protected
     FOwner : TCounterSet;
     FID    : integer;
     FValue : integer;
     FName  : string;
     FModifyDate: TDateTime;
     FResetDate: TDateTime;
    protected
     Index  : integer;
     procedure SetID(AID: integer);
     procedure SetValue(AValue: integer);
     function  GetValue: integer;
     procedure SetName(const AName: string);
     procedure SetOwner(AOwner: TCounterSet);
    public
     procedure SetResetDate(dt: TDateTime);
     procedure SetModifyDate(dt: TDateTime);
    public
     Changed: boolean;
     constructor Create(AOwner: TCounterSet);
     destructor  Destroy; override;
     property    Owner: TCounterSet read FOwner write SetOwner;
     property    ID: integer read FID write SetID;
     property    Value: integer read GetValue write SetValue;
     property    LastValue: integer read FValue;
     property    Name: string read FName write SetName;
     property    ModifyDate: TDateTime read FModifyDate;
     property    ResetDate: TDateTime read FResetDate;
  end;

  TCounterSet = class
    private
     { Private declarations }
     FCounter: TList;
     procedure AssignIndex(Cnt: TCounter);
     procedure FreeCounters;
    protected
     function  GetValidID: integer; virtual;
     function  ValidID(Cnt: TCounter; AID: integer): boolean; virtual;
     function  ValidName(Cnt: TCounter; const AName: string): boolean; virtual;
     procedure FreeItem(Cnt: TCounter); virtual;
     procedure InsertItem(Cnt: TCounter); virtual;
    protected
     function  GetCounterByName(const AName: string): TCounter;
     function  GetCounterByID(AID: integer): TCounter;
     function  GetCounterByIndex(Index: integer): TCounter;
     function  GetValue(AID: integer): integer;
     procedure SetValue(AID: integer; vl: integer);
    public
     { Public declarations }
     Storage: ICounterStorage;
     constructor Create;
     procedure   Load; virtual;
     procedure   MakeCounter(ID: integer; const Name: string; Val: integer); virtual;
     procedure   Save; virtual;
     function    Count: integer;
     destructor  Destroy; override;
    public
     property    CounterByName[const AName: string]: TCounter read GetCounterByName;
     property    Counter[AID: integer]: TCounter read GetCounterByID;
     property    Items[i: integer]: TCounter read GetCounterByIndex;
     property    Value[AID: integer]: integer read GetValue write SetValue;
  end;

  ICounterStorage = interface
    procedure LoadCounters(CS: TCounterSet);
    procedure SaveCounters(CS: TCounterSet);
  end;

type
  TLogFunc = function(const path: string; const SRec: TSearchRec): boolean of object;
  TDirChangeEvent   = function (Sender: TObject): boolean of object;
  TProcessFileEvent = function (Sender: TObject; const SRec: TSearchRec): boolean of object;

  eSortOrder = (soName, soSize, soTime);

  TFileElem = class
    public
     Path: String;
     Size: integer;
     Time: TDateTime;
     TAG : integer;
    public
      constructor Create(const APath: string; SRec: TSearchRec);
  end;

  TDirScan = class(TComponent)
   private
    FStartPath: string;
    FCurDir: string;
    FRecurse: boolean;
    FMask: string;
    FTag: integer;
    FProcessMaskADD: integer;
    FProcessMaskSUB: integer;
    FDirChange: TDirChangeEvent;
    FProcessFileEvent: TProcessFileEvent;
   protected
    procedure SetMask(aMask: string);
    function  DirChange: boolean; virtual;
    function  ProcessFile(const SRec: TSearchRec): boolean; virtual;
   public
    constructor Create(AOwner: TComponent); override;
    procedure Scan; virtual;
   published
    property StartPath: string read FStartPath write FStartPath;
    property CurDir: string read FCurDir;
    property Recurse: boolean read FRecurse write FRecurse;
    property Mask: string read FMask write SetMask;
    property Tag: integer read FTag write FTag;
    property ProcessMaskADD: integer read FProcessMaskADD write FProcessMaskADD;
    property ProcessMaskSUB: integer read FProcessMaskSUB write FProcessMaskSUB;
   published
    property OnDirChange  : TDirChangeEvent read FDirChange  write FDirChange;
    property OnProcessFile: TProcessFileEvent read FProcessFileEvent write FProcessFileEvent;
  end;

  TFiles = class(TList)
    protected
     function ProcessFile(Sender: TObject; const SRec: TSearchRec): boolean;
     function GetFileElem(i: integer): TFileElem;
    public
     property FileElem[i: integer]: TFileElem read GetFileElem;
    public
     constructor Create;
     procedure ReadDirectory(const path: string; const mask: string; subDir: boolean; fAddPath: boolean); virtual;
     procedure ClearItems; virtual;
     procedure SortFiles(by: eSortOrder);
     destructor Destroy; override;
  end;

  TCondFile = class
    private
     out: text;
     NeedClose: boolean;
     FileName: string;
    public
     constructor Create(AFileName: string);
     procedure   writeln(cmd: string);
     destructor  Destroy; override;
  end;

const
  FILEBUFFERSIZE = 128*1024;

type
  FileUtil = class
    public
     class procedure DeleteFile(Path: string); static;
     class function  GetTempDir: string; static;
     class function  GetUniqueName(const Mask: string): string; static;
     class procedure FindRecursive(const path: string; const mask: string; LogFunction: TLogFunc); static;
     class function  ExtractFileNameWithoutExt(const FullPath: string): string; static;
     class function  Compare(const FE1, FE2: string): boolean; static;
     class function  CalcCRC(const FileName: string; maxSize: integer = -1): integer; static;
     class function  GetFileSize(const FileName: string): integer; static;
     class function  isSystemAliasDirectory(const Name: string): boolean; static;
     class procedure DeleteFiles(sMask: string); static;
     class procedure Open(var f: text; Nam: string);
     class procedure FGetStr(var f: text; var x: string);
     class procedure FGetInt(var f: text; var x: integer);
     class procedure FGetDouble(var f: text; var x: double);
  end;

function _sortByName(Item1, Item2: Pointer): Integer;
function _sortBySize(Item1, Item2: Pointer): Integer;
function _sortByTime(Item1, Item2: Pointer): Integer;

const
  Comment  : TCharSet = ['!',';','*'];
  Number   : TCharSet = ['0'..'9','.','+','-'];
  Separator: TCharSet = [' ',',',';','=','''',#9];

  DoUpCase  = 1;
  DoLoCase  = 2;

  MaxArg = 30;

type

  ArgStr = string;

  TCmd = record
    Tokn: integer;
    Name: string;
    Parm: string;
  end;

  TAlias = record
    Name: string;
    NewStr: string;
  end;

  TArg = record
    Num: integer;
    Arg0: string;
    Arg: array[1..MaxArg] of ArgStr;
  end;

type
  ShellUtil = class
    public
     class function  GetToken(NumCmd: integer; const Cmds: array of TCmd; CmdStr: string; defCmnd: integer; Flg: boolean): integer;
     class procedure SplitStr(var Raw, Cmd, prm: string);
     class function  GetParm(var prm: string; opr: integer): string;
     class procedure SplitArg(ArgStr: string; var Args: TArg; const FS: TCharSet; const Cmt: TCharSet);
     class function  IsAlias(wht: string; NumAlias: integer; var Alias: array of TAlias; Flg: boolean): integer;
     class procedure ExpandAlias(var Arg: TArg; NumAlias: integer; var Alias: array of TAlias);
  end;

type
  TAwkParser = class
    private
     FieldSep: string;
     FLine: string;
     NumFields: byte;
     Index, Count: array[0..255] of integer;
     function GetArg(n: byte): string;
    public
     constructor CreateParse(const fs, line: string);
     procedure   Parse(const Line: string);
    public
     property FS: string read FieldSep write FieldSep;
     property NF: byte read NumFields;
     property Arg[n: byte]: string read GetArg; default;
  end;

type

  TStorable = class(TComponent)
    public
     class function ComponentToString(Component: TComponent): string; static;
     class function StringToComponent(Value: string): TComponent; static;
     class function  CheckCreate(Instance: TComponent; ClassKind: TComponentClass; const Name: string = ''; const Owner: TComponent = nil): TComponent;
   protected
     procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
     function  GetChildOwner: TComponent; override;
    public
      constructor Create(AOwner: TComponent); override;
    public
     function  Equals(Obj: TObject): Boolean; override;
     procedure _SetDouble(var Prop: double; const Value: double);
     procedure _SetInt(var Prop: integer; const Value: integer);
     procedure _SetBool(var Prop: Boolean; const Value: Boolean);
  end;

implementation

uses
  DateUtils;

(*
Encoding
*)

resourcestring
  sHexConvertErrorText = 'Wrong char';

const
  HexDigit: string = '0123456789ABCDEF';

(*
  a sequence of Hex digits in a string.
  Hex digits are case insensitive.
  @param(hex digits sequence)
  @returns(converted string)
  @raises(EConvertError if the name can not be found)
*)
class function Encoding.HexDecode(src: string): string;
var
  i: integer;
  n1, n2: byte;
  ch: char;
begin
  Result:= '';
  if (src='') then exit;
  if Odd(length(src)) then Insert('0', src, 1);
  i:= 1;
  while (i <= length(src)) do begin
    n1:= Pos(UpCase(src[i  ]), HexDigit);
    n2:= Pos(UpCase(src[i+1]), HexDigit);
    if (n1=0) or (n2=0) then raise EConvertError.Create(sHexConvertErrorText);
    ch:= chr((n1-1) shl 4 + (n2-1));
    Result:= Result + ch;
    inc(i, 2);
  end;
end;

class function Encoding.HexEncode(const src: string): string;
var
  i: integer;
  l: integer;
  ps: integer;
  ch: byte;
begin
  Result:= '';
  l:= length(src);
  if (l>0) then begin
    SetLength(Result, l*2);
    ps:= 0;
    for i:= 1 to l do begin
      ch:= ord(src[i]);
      inc(ps);
      Result[ps]:= HexDigit[(ch shr 4)+1];
      inc(ps);
      Result[ps]:= HexDigit[(ch and $0F)+1];
    end;
  end;
end;

(*
Parser
*)

class function Parser.DVal(s: string): double;
var
  p: integer;
begin
  s:= Trim(s);
  p:= Pos(FormatSettings.CurrencyString, s);
  if p <> 0 then Delete(s, p, length(FormatSettings.CurrencyString));
  repeat
    p:= Pos(FormatSettings.ThousandSeparator, s);
    if p = 0 then break;
    Delete(s, p, length(FormatSettings.ThousandSeparator));
  until false;
  repeat
    p:= Pos(' ', s);
    if p = 0 then break;
    Delete(s, p, 1);
  until false;
  try
    if s <> '' then Result:= StrToFloat(s)
    else Result:= 0;
  except
    Result:= 0;
  end;
end;

class function Parser.IVal(const s: string): integer;
begin
  Result:= trunc(DVal(s));
end;

(*
CRC
*)

const
  CRCtable : array[0..255] of integer = (
     (          0),( 1996959894),( -301047508),(-1727442502),(  124634137),( 1886057615),( -379345611),(-1637575261),
     (  249268274),( 2044508324),( -522852066),(-1747789432),(  162941995),( 2125561021),( -407360249),(-1866523247),
     (  498536548),( 1789927666),( -205950648),(-2067906082),(  450548861),( 1843258603),( -187386543),(-2083289657),
     (  325883990),( 1684777152),(  -43845254),(-1973040660),(  335633487),( 1661365465),(  -99664541),(-1928851979),
     (  997073096),( 1281953886),( -715111964),(-1570279054),( 1006888145),( 1258607687),( -770865667),(-1526024853),
     (  901097722),( 1119000684),( -608450090),(-1396901568),(  853044451),( 1172266101),( -589951537),(-1412350631),
     (  651767980),( 1373503546),( -925412992),(-1076862698),(  565507253),( 1454621731),( -809855591),(-1195530993),
     (  671266974),( 1594198024),( -972236366),(-1324619484),(  795835527),( 1483230225),(-1050600021),(-1234817731),
     ( 1994146192),(   31158534),(-1731059524),( -271249366),( 1907459465),(  112637215),(-1614814043),( -390540237),
     ( 2013776290),(  251722036),(-1777751922),( -519137256),( 2137656763),(  141376813),(-1855689577),( -429695999),
     ( 1802195444),(  476864866),(-2056965928),( -228458418),( 1812370925),(  453092731),(-2113342271),( -183516073),
     ( 1706088902),(  314042704),(-1950435094),(  -54949764),( 1658658271),(  366619977),(-1932296973),(  -69972891),
     ( 1303535960),(  984961486),(-1547960204),( -725929758),( 1256170817),( 1037604311),(-1529756563),( -740887301),
     ( 1131014506),(  879679996),(-1385723834),( -631195440),( 1141124467),(  855842277),(-1442165665),( -586318647),
     ( 1342533948),(  654459306),(-1106571248),( -921952122),( 1466479909),(  544179635),(-1184443383),( -832445281),
     ( 1591671054),(  702138776),(-1328506846),( -942167884),( 1504918807),(  783551873),(-1212326853),(-1061524307),
     ( -306674912),(-1698712650),(   62317068),( 1957810842),( -355121351),(-1647151185),(   81470997),( 1943803523),
     ( -480048366),(-1805370492),(  225274430),( 2053790376),( -468791541),(-1828061283),(  167816743),( 2097651377),
     ( -267414716),(-2029476910),(  503444072),( 1762050814),( -144550051),(-2140837941),(  426522225),( 1852507879),
     (  -19653770),(-1982649376),(  282753626),( 1742555852),( -105259153),(-1900089351),(  397917763),( 1622183637),
     ( -690576408),(-1580100738),(  953729732),( 1340076626),( -776247311),(-1497606297),( 1068828381),( 1219638859),
     ( -670225446),(-1358292148),(  906185462),( 1090812512),( -547295293),(-1469587627),(  829329135),( 1181335161),
     ( -882789492),(-1134132454),(  628085408),( 1382605366),( -871598187),(-1156888829),(  570562233),( 1426400815),
     ( -977650754),(-1296233688),(  733239954),( 1555261956),(-1026031705),(-1244606671),(  752459403),( 1541320221),
     (-1687895376),( -328994266),( 1969922972),(   40735498),(-1677130071),( -351390145),( 1913087877),(   83908371),
     (-1782625662),( -491226604),( 2075208622),(  213261112),(-1831694693),( -438977011),( 2094854071),(  198958881),
     (-2032938284),( -237706686),( 1759359992),(  534414190),(-2118248755),( -155638181),( 1873836001),(  414664567),
     (-2012718362),(  -15766928),( 1711684554),(  285281116),(-1889165569),( -127750551),( 1634467795),(  376229701),
     (-1609899400),( -686959890),( 1308918612),(  956543938),(-1486412191),( -799009033),( 1231636301),( 1047427035),
     (-1362007478),( -640263460),( 1088359270),(  936918000),(-1447252397),( -558129467),( 1202900863),(  817233897),
     (-1111625188),( -893730166),( 1404277552),(  615818150),(-1160759803),( -841546093),( 1423857449),(  601450431),
     (-1285129682),(-1000256840),( 1567103746),(  711928724),(-1274298825),(-1022587231),( 1510334235),(  755167117));

class function CRC.CalcCRC(const buf: array of byte): integer;
begin
  Result:= 0;
  UpdateCRC(Result, buf);
end;

class procedure CRC.UpdateCRC(var CRC: integer; const buf: array of byte; from: integer = -1; size: integer = -1);
var
  nTemp1: integer;
  nTemp2: integer;
  i: integer;
begin
  if (from=-1) then size:= low(buf);
  if (size=-1) then size:= high(buf)-low(buf)+1;
  for i:= from to low(buf)+size-1 do begin
    nTemp1:= (CRC shr 8) and $00FFFFFF;
    nTemp2:= CRCtable[(CRC xor Buf[i]) and $FF];
    CRC:= nTemp1 xor nTemp2;
  end;
end;

(*
Crypt
*)

const
  MAXCHARVALUE = 255;

class function Crypt.SimpleCrypt(const msg, key: string): string;
var
  oldRand: integer;
  k: integer;
  i: integer;
begin
  oldRand:= RandSeed;
  k:= 07031972;
  for i:= 1 to length(key) do begin
    k:= (k + ord(key[i])) and $7FFFFFFF;
  end;
  RandSeed:= k;
  Result:= msg;
  for i:= 1 to length(Result) do begin
    Result[i]:= chr(ord(Result[i]) xor (Random(MAXCHARVALUE+1)));
  end;
  RandSeed:= oldRand;
end;

class function Crypt.SimpleDecrypt(const msg, key: string): string;
var
  oldRand: integer;
  k: integer;
  i: integer;
begin
  oldRand:= RandSeed;
  k:= 07031972;
  for i:= 1 to length(key) do begin
    k:= (k + ord(key[i])) and $7FFFFFFF;
  end;
  RandSeed:= k;
  Result:= msg;
  for i:= 1 to length(Result) do begin
    Result[i]:= chr(ord(Result[i]) xor (Random(MAXCHARVALUE+1)));
  end;
  RandSeed:= oldRand;
end;

(*
StrUtil
*)

(*
 This function removes space cedes in the string
*)
class function StrUtil.RemoveSpace(const inStr: string): string;
var
  i: integer;
  ch: char;
begin
  Result:= '';
  for i:= 1 to length(inStr) do begin
    ch:= inStr[I];
    if ch <> ' ' then Result:= Result + ch;
  end;
end;

(*
 This function shifts string.
 S:= 'This is a pen.';
 ShiftWord(S,' ') returns 'This'.
 After execution, S holds 'is a pen.'.
*)
class function StrUtil.ShiftWord(var s: string; const separator: string): string;
var
  l: integer;
  p: integer;
begin
  s:= Trim(s);
  p:= Pos(separator, s);
  l:= Length(separator);
  if p=0 then begin
    Result:= s;
    s:= '';
  end
  else if p=1 then begin
    Result:= '';
    Delete(s, 1, l);
  end
  else begin
    Result:= Copy(s, 1, p-1);
    Delete(s, 1 ,p-1+l); (* Delete shifted part & separator string *)
  end;
end;

class function StrUtil.TabToSpace(const s: string; const tab: string): string;
var
  i: integer;
  ch: char;
begin
  for i:= 1 to Length(s) do begin
    ch:= s[I];
    if ch = #9 then Result:= Result + tab
    else Result:= Result + ch;
  end;
end;

class function StrUtil.Chars(n: integer; ch: char): string;
var
  i: integer;
begin
  Result:= '';
  if (n>0) then begin
    SetLength(Result, n);
    for i:= 1 to n do Result[i]:= ch;
  end;
end;

class function StrUtil.OutFloat(x: double; l, d: integer): string;
var
  tmp: string;
  s: integer;
begin
  tmp:= FloatToStrF(x, ffFixed, l, d);
  s:= l - length(tmp);
  if s>0 then begin
    Result:= Copy('                      ',1,s)+tmp;
  end
  else begin
    Result:= tmp;
  end;
end;

class function StrUtil.isLitteral;
begin
  Result:= false;
  if (ch>#32) and (ch<#127) then begin
    Result:= CharInSet(ch, ['A'..'Z','a'..'z','0'..'9','_']);
  end;
end;

(*
DateUtil
*)

const
  _HOU = 1/24;
  _MIN = 1/(24*60);
  _SEC = 1/(24*60*60);
  _MS  = _SEC * 0.001;

class procedure DateUtil.SetLongYear;
var
  ps: integer;
begin
  if Pos('yyyy', FormatSettings.ShortDateFormat) = 0 then begin
    ps:= Pos('yy', FormatSettings.ShortDateFormat);
    if ps = 0 then FormatSettings.ShortDateFormat:= 'dd/mm/yyyy'
    else begin
      Delete(FormatSettings.ShortDateFormat, ps, 2);
      Insert('yyyy', FormatSettings.ShortDateFormat, ps);
    end;
  end;
end;

class function DateUtil.DateToYMD(aDate: TDateTime; time: boolean): string;
begin
  Result:= FormatDateTime('yyyymmddhhnnss', aDate);
  if not time then SetLength(Result, 8);
end;

class function DateUtil.YMDToDate(const YMD: string; time: boolean): TDateTime;
var
  tmp: string;
  i: integer;
  AA, MM, GG, HH, NN, SS, MS: word;
begin
  tmp:= DateToYMD(Date, true)+'000';
  for i:= 1 to length(YMD) do tmp[i]:= YMD[i];
  AA:= Parser.IVal(Copy(tmp, 1,4));
  MM:= Parser.IVal(Copy(tmp, 5,2));
  GG:= Parser.IVal(Copy(tmp, 7,2));
  try
    Result:= EncodeDate(AA, MM, GG);
  except
    Result:= 0;
  end;
  if Time then begin
    HH:= Parser.IVal(Copy(tmp, 9,2));
    NN:= Parser.IVal(Copy(tmp,11,2));
    SS:= Parser.IVal(Copy(tmp,13,2));
    MS:= Parser.IVal(Copy(tmp,15,3));
    try
      Result:= Result + EncodeTime(HH, NN, SS, MS);
    except
    end;
  end;
end;

class function DateUtil.AddWorkDay(aDate: TDateTime; DD: integer): TDateTime;
var
  Sgn: integer;
  i: integer;
begin
  if DD > 0 then Sgn:= 1
  else begin
    Sgn:= -1;
    DD:= Abs(DD);
  end;
  for i:= 1 to DD do begin
    repeat
      aDate:= aDate + Sgn;
    until not IsNotWorkDay(aDate);
  end;
  Result:= aDate;
end;

class function DateUtil.IsNotWorkDay(aDate: TDateTime): boolean;
var
  AA, MM, GG: word;
begin
  Result:= false;
  if DayOfWeek(aDate)=1 then begin
    Result:= true;
    exit;
  end;
  DecodeDate(aDate, AA, MM, GG);
  case MM of
    1: if (GG=1) or (GG=6) then Result:= true;
    4: if (GG=25) then Result:= true;
    5: if (GG=1) then Result:= true;
    8: if (GG=15) then Result:= true;
   11: if (GG=1) then Result:= true;
   12: if (GG=8) or (GG=25) or (GG=26) then Result:= true;
  end;
end;

(*
  Evals expression like : hours h minutes' seconds" milliseconds
  e.g. 12h50'20" is converted to 12/24+50/(24*60)+20/(24*60*60)
*)
class function DateUtil.GetTimeLen(const duration: string): TDateTime;
var
  tmp: string;
  ch: char;
  i: integer;
begin
  tmp:= '';
  i:= 0;
  Result:= 0;
  while i < length(duration) do begin
    inc(i);
    ch:= duration[i];
    case UpCase(ch) of
      '0'..'9': tmp:= tmp + ch;
      'H'     : Result:= Result + Parser.DVal(tmp) * _HOU;
      ''''    : begin Result:= Result + Parser.DVal(tmp) * _MIN; tmp:= ''; end;
      '"'     : begin  Result:= Result + Parser.DVal(tmp) * _SEC; tmp:= ''; end;
    end;
  end;
  if (tmp <> '') then begin
    if (Result = 0) then Result:= Parser.DVal(tmp) * _HOU
    else Result:= Result + Parser.DVAL(tmp) * _MS;
  end;
end;

class function DateUtil.MyStrToDate(aDate: string): TDateTime;
begin
  aDate:= trim(aDate);
  if aDate = '' then Result:= NoDate
  else Result:= StrToDate(aDate);
end;

class function DateUtil.MyDateToStr(aDate: TDateTime): string;
begin
  if aDate = NoDate then Result:= ''
  else Result:= DateToStr(aDate);
end;

class function DateUtil.ChangeDay(aDate: TDateTime; newY: word; newM: word; newD: word): TDateTime;
var
  AA, MM, GG: word;
begin
  DecodeDate(aDate, AA, MM, GG);
  if (newY>0) then AA:= newY;
  if (newM>0) then MM:= newM;
  if (newD>0) then GG:= newD;
  Result:= EncodeDate(AA, MM, GG);
end;

(*
TURL
*)

constructor TURL.Create;
begin
  inherited;
end;

constructor TURL.Create(AURL: string);
begin
  SetURL(AURL);
end;

procedure TURL.MakeURL(AProtocol: string = 'http'; ADomain: string = ''; APath: string = ''; AFileName: string = '');
var
  tmp: string;
begin
  tmp:= '';
  if (AProtocol<>'') then begin
    tmp:= AProtocol+':';
  end;
  if (ADomain<>'') then begin
    tmp:= tmp+'//'+ADomain;
  end;
  if (APath<>'') then begin
    tmp:= tmp+'/'+APath;
  end;
  if (AFileName<>'') then begin
    tmp:= tmp+'/'+APath;
  end;
  SetURL(tmp);
end;

procedure TURL.SetURL(AURL: string);
var
  start: integer;
  last: integer;
  ps: integer;
  state: integer;
begin
  FURL:= AURL;
  FPath:= '';
  FFileName:= '';
  FProtocol:= '';
  FDomain:= '';
  ps:= pos(':', AURL);
  if ps <> 0 then begin
    FProtocol:= Copy(AURL, 1, ps-1);
    AURL:= Copy(AURL, ps+1, length(AURL)-ps+1);
  end
  else begin
    FProtocol:= '';
  end;
  if Copy(AURL,1,2) = '//' then begin
    delete(AURL,1, 2);
    state:= 0;
  end
  else begin
    state:= 1;
  end;
  ps:= 1;
  start:= 0;
  last:= 0;
  while (ps<length(AURL))do begin
    inc(ps);
    if (AURL[ps]='/') then begin
      case (state) of
        0: begin
          FDomain:= Copy(AURL, 1, ps-1);
          state:= 1;
          start:= ps;
          last:= ps;
        end;
        1: begin
          last:= ps;
        end;
      end;
    end;
  end;
  if (start<>last) then begin
    FPath:= Copy(AURL, start+1, last-start-1);
    FFileName:= Copy(AURL, last+1, length(AURL)-last);
  end
  else begin
    if (state=0) then begin
      FDomain:= Copy(AURL, last+1, length(AURL)-last);
    end
    else begin
      FFileName:= Copy(AURL, last+1, length(AURL)-last);
    end;
  end;
end;

function TURL.GetBasePath(withPath: boolean): string;
var
  tmp: string;
begin
  tmp:= '';
  if (FProtocol<>'') then begin
    tmp:= FProtocol+':';
  end;
  if (FDomain<>'') then begin
    tmp:= tmp+'//'+FDomain;
  end;
  if (withPath and (FPath<>'')) then begin
    tmp:= tmp+'/'+FPath;
  end;
  Result:= tmp;
end;

function TURL.Rel2Abs(aURL: string): string;
var
  withPath: boolean;
begin
  if ((Pos(':', aURL)<>0) or (Pos('//', aURL)<>0)) then begin
    Result:= aURL;
    exit;
  end;
  if (aURL<>'') and (aURL[1]='/') then begin
    withPath:= false;
  end
  else begin
    withPath:= true;
  end;
  if (Copy(aURL,1,2)='./') then begin
    delete(aURL, 1, 2);
    withPath:= true;
  end;
  Result:= GetBasePath(withPath);
  if (withPath) then Result:= Result+'/';
  Result:= Result + aURL;
end;

(*
CSV
*)

resourcestring
  sCSV_EOF     = 'EOF';
  sCSV_ABORTED = 'Aborted';
  sCSV_STOPPED = 'Stopped';

constructor TCSVReader.Create;
begin
  LineSep := [#13,#10];
  FieldSep:= [';'];
  Escape  := ['"'];
end;

function TCSVReader.GetChar(var src: TextFile): char;
begin
  if eof(src) then begin
    raise ECSVEOF.Create(sCSV_EOF);
  end;
  read(src, Result);
  inc(Count);
end;

function TCSVReader.ExecuteCallBack(var row: string; callBack: CSVCallBack): boolean;
var
  ch, esc: char;
  i, inz, len: integer;
begin
  if (progress<>nil) then begin
    progress.SetProgress(Count);
  end;
  if ((row <> '') and (assigned(callback))) then begin
    i:= 1;
    esc:= #0;
    Fld.Clear;
    inz:= 1;
    len:= 0;
    while (i <= length(row)) do begin
      ch:= row[i];
      if (esc=#0) then begin
        if CharInSet(ch, FieldSep) then begin
          Fld.Add(copy(row,inz,len));
          inz:= i+1;
          len:= 0;
        end
        else begin
          if CharInSet(ch, Escape) then begin
            esc:= ch;
          end
          else begin
            inc(len);
          end;
        end;
      end
      else begin // Escaping
        esc:= #0;
      end;
      inc(i);
    end;
    Fld.Add(copy(row,inz,len));
    Result:= callback(row, Fld);
    row:= '';
  end
  else Result:= true;
end;

procedure TCSVReader.Process(path: string; callBack: CSVCallBack; progress: IProgress);
var
  buffer: array[0..32*1024-1] of byte;
  src: TextFile;
  ch: char;
  row: string;
  f: file;
begin
  if Assigned(progress) then begin
    AssignFile(f, path);
    Reset(f, 1);
    progress.Init(1, FileSize(f));
    CloseFile(f);
  end
  else begin
    progress:= nil;
  end;
  AssignFile(src, path);
  SetTextBuf(src, buffer, sizeOf(buffer));
  row:= '';
  Reset(src);
  Fld:= TStringList.Create;
  Count:= 0;
  try
    try
      repeat
        repeat
          ch:= GetChar(src);
        until not CharInSet(ch, LineSep);
        row:= ch;
        repeat
          ch:= GetChar(src);
          if not CharInSet(ch, LineSep) then begin
            row:= row + ch;
          end
          else begin
            break;
          end;
        until false;
        if Assigned(progress) and (progress.GetAborted) then begin
          raise ECSVEOF.Create(sCSV_ABORTED);
        end;
        if not ExecuteCallBack(row, callback) then begin
          raise ECSVEOF.Create(sCSV_STOPPED);
        end;
      until false;
    except
      on ECSVEOF do begin
        ExecuteCallBack(row, callback);
     end;
    end
  finally
    FreeAndNil(progress);
    CloseFile(src);
    FreeAndNil(Fld);
  end;
end;

(*
Counters
*)

constructor TCounter.Create(AOwner: TCounterSet);
begin
  Index:= -1;
  Owner:= AOwner;
  if Owner <> nil then FID:= Owner.GetValidID;
  FValue := 0;
  FName  := ClassName+IntToStr(FID);
  FModifyDate:= Now;
  FResetDate := Now;
  Changed:= false;
end;

procedure TCounter.SetID(AID: integer);
begin
  if AID <> FID then begin
    if Owner <> nil then begin
      if not Owner.ValidID(Self, AID) then raise EInvalidID.Create(Self.Name+' '+IntToStr(AID));
    end;
    Changed:= true;
    FID:= AID;
  end;
end;

procedure TCounter.SetValue(AValue: integer);
begin
  if AValue <> FValue then begin
    FValue:= AValue;
    FResetDate := Now;
    FModifyDate:= Now;
    Changed:= true;
  end;
end;

function  TCounter.GetValue: integer;
begin
  inc(FValue);
  Result:= FValue;
  FModifyDate:= Now;
  Changed:= true;
end;

procedure TCounter.SetName(const AName: string);
begin
  if AName <> FName then begin
    if Owner <> nil then begin
      if not Owner.ValidName(Self, AName) then raise EInvalidName.Create(Self.Name+' '+AName);
    end;
    Changed:= true;
    FName:= AName;
  end;
end;

procedure TCounter.SetResetDate(dt: TDateTime);
begin
  if FResetDate <> dt then begin
    FResetDate:= dt;
    Changed:= true;
  end;
end;

procedure TCounter.SetModifyDate(dt: TDateTime);
begin
  if FModifyDate <> dt then begin
    FResetDate:= dt;
    Changed:= true;
  end;
end;

procedure TCounter.SetOwner(AOwner: TCounterSet);
begin
  if Owner <> AOwner then begin
    if FOwner <> nil then FOwner.FreeItem(Self);
    if AOwner <> nil then AOwner.InsertItem(Self);
    FOwner:= AOwner;
    Changed:= true;
  end;
end;

destructor TCounter.Destroy;
begin
  Owner:= nil;
  inherited Destroy;
end;

constructor TCounterSet.Create;
begin
  FCounter:= TList.Create;
end;

procedure TCounterSet.MakeCounter(ID: integer; const Name: string; Val: integer);
var
  Cnt: TCounter;
begin
  if not ValidID(nil, ID) then raise EInvalidID.Create('MakeCounter ID:'+IntToStr(ID));
  if not ValidName(nil, Name) then raise EInvalidName.Create('MakeCounter Name:'+Name);
  Cnt:= TCounter.Create(Self);
  Cnt.ID:= ID;
  Cnt.Name:= Name;
  Cnt.Value:= Val;
  Cnt.Changed:= false;
end;

procedure TCounterSet.AssignIndex(Cnt: TCounter);
var
  i: integer;
begin
  Cnt.Index:= -1;
  for i:= 0 to FCounter.Count-1 do begin
    if FCounter[i] = Cnt then begin
      Cnt.Index:= i;
      break;
    end;
  end;
end;

function  TCounterSet.GetValidID: integer;
begin
  Result:= 0;
end;

function  TCounterSet.ValidID(Cnt: TCounter; AID: integer): boolean;
var
  i: integer;
begin
  Result:= true;
  if AID = 0 then exit;
  for i:= 0 to FCounter.Count-1 do begin
    with TCounter(FCounter[i]) do begin
      if (ID = AID) then begin
        Result:= TCounter(FCounter[i]) = Cnt;
        if not Result then break;
      end;
    end;
  end;
end;

function  TCounterSet.ValidName(Cnt: TCounter; const AName: string): boolean;
var
  i: integer;
begin
  Result:= true;
  for i:= 0 to FCounter.Count-1 do begin
    with TCounter(FCounter[i]) do begin
      if (Name = AName) then begin
        Result:= TCounter(FCounter[i]) = Cnt;
        if not Result then break;
      end;
    end;
  end;
end;

procedure TCounterSet.FreeItem(Cnt: TCounter);
begin
  if Cnt.Index = -1 then AssignIndex(Cnt);
  FCounter.Delete(Cnt.Index);
end;

procedure TCounterSet.InsertItem(Cnt: TCounter);
begin
  Cnt.Index:= FCounter.Add(Cnt);
end;

function  TCounterSet.GetCounterByName(const AName: string): TCounter;
var
  i: integer;
begin
  Result:= nil;
  for i:= 0 to FCounter.Count-1 do begin
    if (TCounter(FCounter[i]).Name = AName) then begin
      Result:= TCounter(FCounter[i]);
      break;
    end;
  end;
end;

function  TCounterSet.GetCounterByID(AID: integer): TCounter;
var
  i: integer;
begin
  Result:= nil;
  for i:= 0 to FCounter.Count-1 do begin
    if (TCounter(FCounter[i]).ID = AID) then begin
      Result:= TCounter(FCounter[i]);
      break;
    end;
  end;
end;

function  TCounterSet.GetCounterByIndex(Index: integer): TCounter;
begin
  Result:= FCounter.Items[Index];
end;

function  TCounterSet.GetValue(AID: integer): integer;
begin
  Result:= GetCounterByID(AID).Value;
end;

procedure TCounterSet.SetValue(AID: integer; vl: integer);
begin
  GetCounterByID(AID).Value:= vl;
end;

procedure TCounterSet.Load;
begin
  if Assigned(Storage) then begin
    FreeCounters;
    Storage.LoadCounters(Self);
  end;
end;

procedure TCounterSet.Save;
begin
  if Assigned(Storage) then begin
    Storage.SaveCounters(Self);
  end;
end;

function TCounterSet.Count: integer;
begin
  Result:= FCounter.Count;
end;

procedure TCounterSet.FreeCounters;
var
  i: integer;
begin
  for i:= FCounter.Count-1 downto 0 do begin
    TCounter(FCounter.Items[i]).Free;
  end;
end;

destructor TCounterSet.Destroy;
begin
  FreeCounters;
  FCounter.Free;
end;

(*
FileLib
*)

function _sortByName(Item1, Item2: Pointer): Integer;
var
  FE1, FE2: TFileElem;
begin
  FE1:= TFileElem(Item1);
  FE2:= TFileElem(Item2);
       if (FE1.Path < FE2.Path) then Result:= -1
  else if (FE1.Path > FE2.Path) then Result:=  1
  else Result:= 0;
end;

function _sortBySize(Item1, Item2: Pointer): Integer;
var
  FE1, FE2: TFileElem;
begin
  FE1:= TFileElem(Item1);
  FE2:= TFileElem(Item2);
       if (FE1.Size < FE2.Size) then Result:= -1
  else if (FE1.Size > FE2.Size) then Result:=  1
  else Result:= 0;
end;

function _sortByTime(Item1, Item2: Pointer): Integer;
var
  FE1, FE2: TFileElem;
begin
  FE1:= TFileElem(Item1);
  FE2:= TFileElem(Item2);
  Result:= CompareDateTime(FE1.Time, FE2.Time);
end;

constructor TFileElem.Create(const APath: string; SRec: TSearchRec);
begin
  Path:= APath;
  Size:= SRec.Size;
  Time:= SRec.TimeStamp;
  TAG := 0;
end;

constructor TFiles.Create;
begin
  inherited Create;
end;

procedure TFiles.ReadDirectory(const path: string; const mask: string; subDir: boolean; fAddPath: boolean);
var
  DS: TDirScan;
begin
  ClearItems;
  DS:= TDirScan.Create(nil);
  try
    if fAddPath then DS.Tag:= 1 else DS.Tag:= 0;
    DS.StartPath:= path;
    DS.Mask:= mask;
    DS.Recurse:= subDir;
    DS.OnProcessFile:= ProcessFile;
    DS.Scan;
  finally
    DS.Free;
  end;
end;

procedure TFiles.SortFiles(by: eSortOrder);
begin
  if Count > 0 then begin
    case by of
      soName: Sort(_sortByName);
      soSize: Sort(_sortBySize);
      soTime: Sort(_sortByTime);
    end;
  end;
end;

function TFiles.GetFileElem(i: integer): TFileElem;
begin
  Result:= TFileElem(Items[i]);
end;

function TFiles.ProcessFile(Sender: TObject; const SRec: TSearchRec): boolean;
var
  fullName: string;
  DS: TDirScan;
begin
  DS:= TDirScan(Sender);
  Result:= true;
  if (DS.Tag = 1) then begin
    fullName:= DS.CurDir+SRec.Name;
  end
  else begin
    fullName:= SRec.Name;
  end;
  Add(TFileElem.Create(fullName, SRec));
end;

procedure TFiles.ClearItems;
var
  i: integer;
begin
  for i:= Count-1 downto 0 do begin
    TFileElem(Items[i]).Free;
  end;
  inherited Clear;
end;

destructor TFiles.Destroy;
begin
  Clear;
end;

constructor TCondFile.Create(AFileName: string);
begin
  FileName:= AFileName;
  NeedClose:= false;
end;

procedure TCondFile.writeln(cmd: string);
begin
  if not NeedClose then begin
    Assign(out, FileName);
    Rewrite(out);
    NeedClose:= true;
  end;
  System.writeln(out, cmd);
end;

destructor TCondFile.Destroy;
begin
  if NeedClose then begin
    CloseFile(out);
    NeedClose:= false;
  end;
end;

constructor TDirScan.Create(AOwner: TComponent);
begin
  inherited ;
  FMask:= '*.*';
  FRecurse:= true;
  FProcessMaskADD:= faAnyFile;
  FProcessMaskSUB:= faDirectory or faVolumeID;
end;

function TDirScan.DirChange: boolean;
begin
  if Assigned(FDirChange) then Result:= FDirChange(Self)
  else Result:= true;
end;

function TDirScan.ProcessFile(const SRec: TSearchRec): boolean;
begin
  if Assigned(FProcessFileEvent) then Result:= FProcessFileEvent(Self, SRec)
  else Result:= true;
end;

procedure TDirScan.SetMask(aMask: string);
begin
  if aMask = '' then aMask:= '*.*';
  FMask:= aMask;
end;

procedure TDirScan.Scan;
var
  fullPath: string;
  function Recurse(path: string; const mask: string): boolean;
  var
    SRec: TSearchRec;
    DosError: integer;
  begin
    FCurDir:= path;
    Result:= DirChange;
    if not Result then exit;
    DosError:= FindFirst(path+mask, faAnyFile, SRec);
    while DosError = 0 do begin
      if ((SRec.Attr and FProcessMaskADD) <> 0) then begin
        if ((SRec.Attr and FProcessMaskSUB) = 0) then begin
          if not ProcessFile(SRec) then begin
            Result:= false;
            Break;
          end;
        end;
      end;
      DosError:= FindNext(SRec);
    end;
    FindClose(SRec);
    if not Result then Exit;
    if (FRecurse) then begin
      DosError:= FindFirst(path+'*.*', faDirectory, SRec);
      while DosError = 0 do begin
        if (SRec.Attr and faDirectory) <> 0 then begin
          if not FileUtil.isSystemAliasDirectory(SRec.Name) then begin
            if not Recurse(path + SRec.Name + '\', mask) then begin
              Result:= False;
              Break;
            end;
          end;
        end;
        DosError:= FindNext(SRec);
      end;
      FindClose(SRec);
    end;
  end;
begin
  if FStartPath = '' then GetDir(0, fullpath)
  else fullPath:= FStartPath;
  if fullpath[Length(fullpath)] <> '\' then fullpath:= fullpath + '\';
  Recurse(fullpath, mask);
end;

class function FileUtil.GetFileSize(const FileName: string): integer;
var
  Sr: TSearchRec;
  DosError: integer;
begin
  DosError:= FindFirst(FileName, faAnyFile and (not (faSysFile or faDirectory)),Sr);
  if DosError=0 then GetFileSize:= Sr.size
  else GetFileSize:= -1;
end;

class function FileUtil.CalcCRC(const FileName: string; maxSize: integer = -1): integer;
type
  TBuf = array[0..FILEBUFFERSIZE-1] of byte;
  PBuf = ^TBuf;
var
  f: file;
  buf: PBuf;
  siz: integer;
  oldFileMode: integer;
begin
  Result:= 0;
  New(buf);
  AssignFile(f, FileName);
  oldFileMode:= FileMode;
  FileMode := 0;  { Set file access to read only }
  Reset(f, 1);
  repeat
    BlockRead(f, buf^, SizeOf(TBuf), siz);
    if (siz > 0) then begin
      if (maxSize >= 0) then begin
        if (siz > maxSize) then begin
          siz:= maxSize;
        end;
        if (siz > 0) then begin
          CRC.UpdateCRC(Result, buf^, siz);
        end;
        dec(maxSize, siz);
      end
      else begin
        CRC.UpdateCRC(Result, buf^, siz);
      end;
    end;
  until (siz=0) or (maxSize=0);
  CloseFile(f);
  Dispose(Buf);
  FileMode:= OldFileMode;
end;

class function FileUtil.Compare(const FE1, FE2: string): boolean;
type
  TBuf = array[0..(FILEBUFFERSIZE div SizeOf(integer))-1] of integer;
  PBuf = ^TBuf;
var
  f1, f2: file;
  FS1, FS2: integer;
  Buf1: PBuf;
  Buf2: PBuf;
  Siz1: integer;
  Siz2: integer;
  Siz: integer;
  i: integer;
  OldFileMode: integer;
begin
  Result:= false;
  FS1:= GetFileSize(FE1);
  FS2:= GetFileSize(FE2);
  if (FS1=0) or (FS1 <> FS2) then exit;
  New(Buf1);
  New(Buf2);
  AssignFile(f1, FE1);
  AssignFile(f2, FE2);
  OldFileMode:= FileMode;
  FileMode := 0;  { Set file access to read only }
  Reset(f1, 1);
  Reset(f2, 1);
  Result:= true;
  repeat
    FillChar(Buf1^, SizeOf(TBuf), 0);
    FillChar(Buf2^, SizeOf(TBuf), 0);
    BlockRead(f1, Buf1^, SizeOf(TBuf), Siz1);
    BlockRead(f2, Buf2^, SizeOf(TBuf), Siz2);
    if (Siz1 <> Siz2) then begin
      raise EReadError.Create('Error reading files');
    end;
    if (Siz1 > 0) then begin
      Siz:= Siz1 div SizeOf(integer);
      if (Siz1 mod SizeOf(integer))>0 then begin
        inc(Siz);
      end;
      for i:= 0 to Siz-1 do begin
        if Buf1^[i]<>Buf2^[i] then begin
          Result:= false;
          break;
        end;
      end;
    end;
  until (Siz1=0);
  CloseFile(f1);
  CloseFile(f2);
  Dispose(Buf1);
  Dispose(Buf2);
  FileMode:= OldFileMode;
end;

class function FileUtil.isSystemAliasDirectory(const Name: string): boolean;
begin
  Result:= (Name = '.') or (Name = '..');
end;

class procedure FileUtil.DeleteFiles(sMask: string);
var
  SearchRec: TSearchRec;
begin
  if FindFirst(sMask,faAnyFile,SearchRec) = 0 then begin
    sMask:= ExtractFilePath(sMask);
    SysUtils.DeleteFile(sMask+SearchRec.Name);
    while FindNext(SearchRec) = 0 do begin
      SysUtils.DeleteFile(sMask+SearchRec.Name);
    end;
  end;
  FindClose(SearchRec);
end;

{
Procedure FindRecursive
Parameters:
  path: the directory the scan should start in. if this parameter is an empty string, the current directory will be used.
  mask: the file mask the files we search for should fit. This mask will normally contain DOS wildcards, like in '*.pas'
  to find all Pascal source files. If this parameter is an empty string, '*.*' is used.
  LogFunction: This has to be a class method of the prototype TLogFunct.
Description:
  The procedure starts at the directory given in path and searches it for files matching the mask. LogFunction will be
  called for each file we find with the current directory and the search record filled by FindFirst/Next. The path will
  always end in a backslash, so path+SRec.Name yields the full name of the found file.
  If the function returns False, the recursion will stop and FindRecursive returns immediately.
  After the directory has been scanned for files it is again scanned for directories and each found directory is in turn
  scanned in the same manner.
}
class procedure FileUtil.FindRecursive(const path: string; const mask: string; LogFunction: TLogFunc);
var
  FullPath: string;
  function Recurse(var path: string; const mask: string): boolean;
  var
    SRec: TSearchRec;
    RetVal: integer;
    OldLen: integer;
  begin
    Recurse:= True;
    OldLen:= Length(path);
    RetVal:= FindFirst(path+mask, faAnyFile, SRec);
    while RetVal = 0 do begin
      if (SRec.Attr and (faDirectory or faVolumeID)) = 0 then
        if not LogFunction(path, SRec) then begin
          Result:= False;
          break;
        end;
      RetVal:= FindNext(SRec);
    end;
    FindClose(SRec);
    if not Result then Exit;
    RetVal:= FindFirst(path+'*.*', faDirectory, SRec);
    while RetVal = 0 do begin
      if (SRec.Attr and faDirectory) <> 0 then
        if (SRec.Name <> '.') and (SRec.Name <> '..') then begin
          path:= path + SRec.Name + '\';
          if not Recurse(path, mask) then begin
            Result:= False;
            break;
          end;
          Delete(path, OldLen+1, 255);
        end;
      RetVal:= FindNext(SRec);
    end;
    FindClose(SRec);
  end;
begin
  if path = '' then GetDir(0, FullPath)
  else FullPath:= path;
  if FullPath[Length(FullPath)] <> '\' then
    FullPath:= FullPath + '\';
  if mask = '' then Recurse(FullPath, '*.*')
  else Recurse(FullPath, mask);
end;

class function FileUtil.GetUniqueName(const Mask: string): string;
var
  i: word;
begin
  i:= 0;
  repeat
    Result:= Mask+IntToHex(i, 4);
  until (not FileExists(Result)) or (i=65535);
  if i = 65535 then Result:='';
end;

class procedure FileUtil.DeleteFile(Path: string);
var
  f: file;
begin
  AssignFile(F, Path);
  Erase(f);
end;

class function FileUtil.GetTempDir: string;
begin
  GetTempDir:= '.';
end;

class function FileUtil.ExtractFileNameWithoutExt(const FullPath: string): string;
var
  L: integer;
  FileNameWithExt:  string;
  Ext:  string;
begin
  FileNameWithExt:= ExtractFileName(FullPath);
  Ext:= ExtractFileExt(FullPath);
  if Ext='' then Result:= FileNameWithExt
  else if FileNameWithExt='' then Result:= ''
  else begin
    L:= Length(FileNameWithExt) - Length(Ext);
    Result:= Copy(FileNameWithExt, 1, L);
  end;
end;

class procedure FileUtil.Open;
begin
  Assign(f, Nam);
  {$I-} Reset(f); {$I+}
  if IOResult <> 0 then Rewrite(f);
end;

class procedure FileUtil.FGetStr;
var
  tmp: string;
begin
  tmp:= '';
  repeat
    if eof(F) then break;
    Readln(f, tmp);
    tmp:= trim(tmp);
  until (tmp<>'') and not CharInSet(tmp[1], Comment);
  x:= tmp;
end;

class procedure FileUtil.FGetInt;
var
  tmp: string;
begin
  FGetStr(f, tmp);
  x:= Parser.IVal(tmp);
end;

class procedure FileUtil.FGetDouble;
var
  tmp: string;
begin
  FGetStr(f, tmp);
  x:= Parser.DVal(tmp);
end;

class function ShellUtil.GetToken(NumCmd: integer; const Cmds: array of TCmd; CmdStr: string; defCmnd: integer; Flg: boolean): integer;
var
  tkn, i, Len: integer;
  Found: boolean;
begin
  CmdStr:= LowerCase(CmdStr);
  tkn:= defCmnd;
  if CmdStr <> '' then begin
    Found:= false;
    for i:= 0 to NumCmd-1 do begin
      if CmdStr = Cmds[i].Name then begin
        tkn:= Cmds[i].Tokn;
        Found:= true;
        break;
      end;
    end;
    if (not Found) and (Flg) then begin
      Len:= length(CmdStr);
      for i:= 0 to NumCmd-1 do begin
        if CmdStr = Copy(Cmds[i].Name,1,Len) then begin
          tkn:= Cmds[i].Tokn;
          break;
        end;
      end;
    end;
  end;
  GetToken:= tkn;
end;

class procedure ShellUtil.SplitStr(var Raw, Cmd, prm: string);
var i: integer;
begin
  Raw:= Trim(Raw);
  i:= Pos(' ', Raw);
  if i = 0 then begin
    Cmd:= Raw; prm:= '';
  end
  else begin
    Cmd:= Copy(Raw, 1, i-1);
    prm:= Trim(Copy(Raw, i+1,255));
  end;
end;

class function ShellUtil.GetParm(var prm: string; opr: integer): string;
var
  tmp, New: string;
begin
  SplitStr(prm, tmp, New);
  prm:= New;
  if tmp <> '' then begin
    case opr of
      DoUpCase: tmp:= UpperCase(tmp);
      DoLoCase: tmp:= LowerCase(tmp);
    end;
  end;
  GetParm:= tmp;
end;

class procedure ShellUtil.SplitArg(ArgStr: string; var Args: TArg; const FS: TCharSet; const Cmt: TCharSet);
var
  idx: integer;
  ps: integer;
begin
  with Args do begin
    Num:= 0;
    Arg0:= ArgStr;
    ArgStr:= Trim(ArgStr);
    if (ArgStr='') then exit;
    if CharInSet(ArgStr[1], Cmt) then exit;
    for idx:= 1 to length (ArgStr) do
      if CharInSet(ArgStr[idx], FS) then ArgStr[idx]:= ' '; (* forza lo spazio come separatore *)
    idx:= 1;
    while ArgStr <> '' do begin
      ps:= Pos(' ', ArgStr);
      if ps = 0 then ps:= length(ArgStr) else dec(ps);
      Arg[idx]:= Copy(ArgStr, 1, ps);
      Delete(ArgStr, 1, ps);
      ArgStr:= Trim(ArgStr);
      inc(idx);
      if idx>MaxArg then break;
    end;
    Num:= idx-1;
  end;
end;

class function ShellUtil.IsAlias(wht: string; NumAlias: integer; var Alias: array of TAlias; Flg: boolean): integer;
var
  Ind, i, Len: integer;
  Found: boolean;
begin
  wht:= LowerCase(wht);
  Ind:= 0;
  if wht <> '' then begin
    Found:= false;
    for i:= 0 to NumAlias-1 do begin
      if wht = Alias[i].Name then begin
        Ind:= i+1;
        Found:= true;
        break;
      end;
    end;
    if (not Found) and (Flg) then begin
      Len:= length(wht);
      for i:= 0 to NumAlias-1 do begin
        if wht = Copy(Alias[i].Name,1,Len) then begin
          Ind:= i+1;
          break;
        end;
      end;
    end;
  end;
  IsAlias:= Ind;
end;

class procedure ShellUtil.ExpandAlias(var Arg: TArg; NumAlias: integer; var Alias: array of TAlias);
var i, j: integer;
begin
  with Arg do begin
    for i:= 1 to Num do begin
      j:= IsAlias(Arg[i], NumAlias, Alias, true);
      if j <> 0 then Arg[i]:= Alias[j-1].NewStr;
    end;
  end;
end;

constructor TAwkParser.CreateParse(const fs, line: string);
begin
  inherited Create;
  FieldSep:= fs;
  Parse(line);
end;

function TAwkParser.GetArg(n: byte): string;
begin
  result:= '';
  if n > NumFields then exit;
  if n = 0 then result:= FLine
  else if n > 0 then begin
    dec(n); {0-based arrays!}
    if Index[n] > 0 then {count[n] is assumed to contain a valid count, at least 1!}
      result:= copy(FLine, index[n], count[n]);
  end;
end;

procedure TAwkParser.Parse(const line: string);
var
  n, i, len: integer;
  multFS, inArg: boolean;
  fsep: char;
begin
  multFS:= FieldSep = '';
  if multFS then fsep:= ' ' { special case: multiple blanks treated as one!}
  else begin
    if (FieldSep[1] = '^') and (length(FieldSep) > 1) then begin
      if CharInSet(FieldSep[2], ['A'..'[', 'a'..'z']) then fsep:= chr(ord(FieldSep[2]) - 64) { standard control character}
      else if FieldSep[2] = '^' then fsep:= '^' { literal ^}
      else fsep:= '^'; { don't know what else to do... could raise an exception i suppose, but...}
    end
    else begin
      fsep:= FieldSep[1];
    end;
  end;
  FLine:= line;
  len:= length(line);
  i:= 1;
  n:= 0;
  inArg:= false;
  count[0]:= 0;
  index[0]:= 0; {this is used as indicator of null arg}
  while i <= len do begin { parse line}
    if line[i]=fsep then begin
      if inArg then begin {transition out of arg}
        inArg:= false;
        inc(n);
        index[n]:= 0; {this is used as indicator of null arg}
      end
      else begin {fsep & not inArg, i.e., last char was fsep too}
        if multFS then
          {special case: treat multiple separators as one}
        else begin {arg[n] is null}
          index[n]:= i;
          count[n]:= 0;
          inc(n);
          index[n]:= 0; {this is used as indicator of null arg}
        end;
      end;
    end
    else if not inArg then begin {transition into arg}
      inArg:= true;
      index[n]:= i;
      count[n]:= 1;
    end
    else begin {step along inArg}
      inc(count[n]);
    end;
    inc(i); {next char in line}
  end;
  if multFS and not inArg then begin
    dec(n); { special case: don't count trailing spaces!}
  end;
  if index[0] > 0 then NumFields:= n + 1
  else NumFields:= 0
end;

class function TStorable.ComponentToString(Component: TComponent): string;
var
  BinStream:TMemoryStream;
  StrStream: TStringStream;
  s: string;
begin
  BinStream := TMemoryStream.Create;
  try
    StrStream := TStringStream.Create(s);
    try
      BinStream.WriteComponent(Component);
      BinStream.Seek(0, soFromBeginning);
      ObjectBinaryToText(BinStream, StrStream);
      StrStream.Seek(0, soFromBeginning);
      Result:= StrStream.DataString;
    finally
      StrStream.Free;
    end;
  finally
    BinStream.Free
  end;
end;

class function TStorable.StringToComponent(Value: string): TComponent;
var
  StrStream:TStringStream;
  BinStream: TMemoryStream;
begin
  StrStream := TStringStream.Create(Value);
  try
    BinStream := TMemoryStream.Create;
    try
      ObjectTextToBinary(StrStream, BinStream);
      BinStream.Seek(0, soFromBeginning);
      Result:= BinStream.ReadComponent(nil);
    finally
      BinStream.Free;
    end;
  finally
    StrStream.Free;
  end;
end;

class function TStorable.CheckCreate(Instance: TComponent; ClassKind: TComponentClass; const Name: string = ''; const Owner: TComponent = nil): TComponent;
begin
  Result:= Instance;
  if Result = nil then begin
    if ((Name<>'') and (Owner<>nil)) then Result:= Owner.FindComponent(Name);
    if Result = nil then begin
      Result:= ClassKind.Create(Owner);
      Result.Name:= Name;
    end;
  end;
end;

constructor TStorable.Create(AOwner: TComponent);
begin
  inherited;
  SetSubComponent(true);
end;

procedure TStorable.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  i: Integer;
  OwnedComponent: TComponent;
begin
  inherited GetChildren(Proc, Root);
//  if (Root = Self) then begin
    for i:= 0 to ComponentCount - 1 do begin
      OwnedComponent:= Components[I];
      if not OwnedComponent.HasParent then begin
        Proc(OwnedComponent);
      end;
    end;
//  end;
end;

function TStorable.GetChildOwner: TComponent;
begin
  inherited;
  Result:= Self;
end;

function TStorable.Equals(Obj: TObject): Boolean;
var
  data1, data2: string;
  name1, name2: TComponentName;
  Other: TStorable;
begin
  if Obj is TStorable then begin
    Other:= TStorable(Obj);
    name1:= Self.Name;
    name2:= Other.Name;
    Self.Name:= '';
    Other.Name:= '';
    data1:= TStorable.ComponentToString(Self);
    data2:= TStorable.ComponentToString(TStorable(Obj));
    Self.Name:= name1;
    Other.Name:= name2;
    Result:= data1=data2;
  end
  else Result:= inherited;
end;

const
  errMsg = 'Read-Only proprety';

procedure TStorable._SetDouble(var Prop: double; const Value: double);
begin
  if (csReading in ComponentState) then begin
    Prop:= Value;
  end
  else raise EInvalidOperation.Create(errMsg);
end;

procedure TStorable._SetInt(var Prop: integer; const Value: integer);
begin
  if (csReading in ComponentState) then begin
    Prop:= Value;
  end
  else raise EInvalidOperation.Create(errMsg);
end;

procedure TStorable._SetBool(var Prop: Boolean; const Value: Boolean);
begin
  if (csReading in ComponentState) then begin
    Prop:= Value;
  end
  else raise EInvalidOperation.Create(errMsg);
end;

end.

