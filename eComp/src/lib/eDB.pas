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
unit eDB;

interface

uses
  SysUtils, Classes, Windows, Messages, Graphics, Controls, Forms,
  Dialogs, DB, DBTables, INIFiles, dbitypes, dbiprocs;

const
  DirSep        = '\';
  SignatureFile = 'database.dbh';
  SezDatabase   = 'DataBase';
  KeySignature  = 'Signature';
  KeyMagic      = 'Magic';

const
  DBSignatureValid   =  0;
  DBSignatureUnknown = -1;
  DBSignatureInvalid = -2;

type
  TeDataBase = class;
  TDBConnectionLink = class;
  TDBMessageLink    = class;

  EUnknownDataBase = class(exception);
  EInvalidDataBase = class(EUnknownDataBase);

  TValidateNotify = function (const Signature, Magic: string): boolean of object;
  TDBConnectionEvent = procedure(Sender: TeDataBase; Connect: boolean) of object;
  TDBMessageEvent = procedure(Sender: TObject; Cmd: integer; Data: TObject) of object;

  TeDataBase = class(TDataBase)
   private
    ConnList: TList;
    MesgList: TList;
    FSignature : string;
    FOnValidate: TValidateNotify;
    function  GetDBPath: string;
    procedure ConnectTo(const Path: string);
    procedure NotifyConnection(Connect: boolean);
   protected
    function  Validate(const Str, Magic: string): boolean;
    procedure AddConnLink(Link: TDBConnectionLink);
    procedure DelConnLink(Link: TDBConnectionLink);
    procedure AddMesgLink(Link: TDBMessageLink);
    procedure DelMesgLink(Link: TDBMessageLink);
   public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    function  GetSignature(const Path: string; var Sign: string): integer;
    procedure Convalidate(const Path, Magic: string);
    procedure Notify(Sender: TObject; Cmd: integer; Data: TObject);
    function  Disconnect: boolean;
    function  Reconnect: boolean;
    function  SelectDB(const Path: string): boolean;
   public
    property  DBPath: string read GetDBPath;
   published
    property  Signature: string read FSignature write FSignature;
    property  OnValidate: TValidateNotify read FOnValidate write FOnValidate;
  end;

  TDBLink = class(TComponent)
    private
     FDataBase    : TeDataBase;
     FActive      : boolean;
     FStreamActive: boolean;
     procedure   SetActive(vl: boolean);
     function    GetDataBase: TeDataBase;
     procedure   SetDataBase(ADataBase: TeDataBase);
    protected
     procedure   Loaded; override;
     procedure   Notification(AComponent: TComponent; Operation: TOperation); override;
    protected
     procedure   Activate; virtual; abstract;
     procedure   DeActivate; virtual; abstract;
    public
     constructor Create(AOwner: TComponent); override;
     destructor  Destroy; override;
    published
     property Active: boolean read FActive write SetActive;
     property DataBase: TeDataBase read GetDataBase write SetDatabase;
  end;

  TDBConnectionLink = class(TDBLink)
    private
     FOnConnect   : TDBConnectionEvent;
     FOnDisconnect: TDBConnectionEvent;
    protected
     procedure   Activate; override;
     procedure   DeActivate; override;
    public
     constructor Create(AOwner: TComponent); override;
     procedure   Connection(Connected: boolean);
    published
     property OnConnect: TDBConnectionEvent read FOnConnect write FOnConnect;
     property OnDisconnect: TDBConnectionEvent read FOnDisconnect write FOnDisconnect;
   end;

  TDBMessageLink = class(TDBLink)
    private
     FOnMessage   : TDBMessageEvent;
    protected
     procedure   Activate; override;
     procedure   DeActivate; override;
    public
     constructor Create(AOwner: TComponent); override;
     procedure Notify(Sender: TObject; Cmd: integer; Data: TObject);
    published
     property OnMessage: TDBMessageEvent read FOnMessage write FOnMessage;
   end;

procedure ConnectDB(DB: TeDataBase; const Path: string);
function ConnectDataBase(DB: TeDataBase; const Path: string): boolean;

procedure Register;

implementation

uses
  eLib, eCompUtil;

constructor TeDataBase.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ConnList:= TList.Create;
  MesgList:= TList.Create;
end;

destructor TeDataBase.Destroy;
begin
  ConnList.Free;
  MesgList.Free;
  inherited Destroy;
end;

function TeDataBase.GetDBPath: string;
var
  szDirectory: DBIPath;
begin
  if Connected then begin
    Check(DbiGetDirectory(Handle, False, szDirectory));
    Result:= StrPas(szDirectory);
  end
  else Result:= Params.Values['PATH'];
end;

function TeDataBase.Validate(const Str, Magic: string): boolean;
begin
  if Assigned(FOnValidate) then Result:= OnValidate(Str, Magic)
  else Result:= true;
end;

procedure TeDataBase.Notify(Sender: TObject; Cmd: integer; Data: TObject);
var
  i: integer;
begin
  for i:= 0 to MesgList.Count-1 do begin
    TDBMessageLink(MesgList[i]).Notify(Sender, Cmd, Data);
  end;
end;

procedure TeDataBase.NotifyConnection(Connect: boolean);
var
  i: integer;
begin
  for i:= 0 to ConnList.Count-1 do begin
    TDBConnectionLink(ConnList[i]).Connection(Connect);
  end;
end;

procedure TeDataBase.AddConnLink(Link: TDBConnectionLink);
begin
  if ConnList.IndexOf(Link) = -1 then ConnList.Add(Link);
end;

procedure TeDataBase.DelConnLink(Link: TDBConnectionLink);
var
  ps: integer;
begin
  ps:= ConnList.IndexOf(Link);
  if ps <> -1 then begin
    ConnList.Delete(ps);
    ConnList.Pack;
  end;
end;

procedure TeDataBase.AddMesgLink(Link: TDBMessageLink);
begin
  if MesgList.IndexOf(Link) = -1 then MesgList.Add(Link);
end;

procedure TeDataBase.DelMesgLink(Link: TDBMessageLink);
var
  ps: integer;
begin
  ps:= MesgList.IndexOf(Link);
  if ps <> -1 then begin
    MesgList.Delete(ps);
    MesgList.Pack;
  end;
end;

function  TeDataBase.Disconnect: boolean;
begin
  Result:= true;
  if not Connected then exit;
  try
    NotifyConnection(false);
    Connected:= false;
  except
    Result:= false;
  end;
end;

procedure TeDataBase.ConnectTo(const Path: string);
var
  Sign: string;
  Flg: integer;
begin
  if Path = '' then raise EInvalidOperation.Create('Inalid DB Path');
  Flg:= GetSignature(Path, Sign);
  if (Sign <> Signature) or (Flg <> DBSignatureValid) then begin
    if Flg = DBSignatureInvalid then raise EInvalidDataBase.Create(Path+' is not a valid DataBase.')
    else raise EUnknownDatabase.Create(Path+' is a DataBase without a signature.');
  end;
  Params.Values['PATH']:= Path;
  Connected:= true;
  NotifyConnection(true);
end;

function TeDataBase.SelectDB(const Path: string): boolean;
var
  OldDB: string;
begin
  if Connected then OldDB:= DBPath
  else OldDB:= '';
  Result:= false;
  try
    if Disconnect then begin;
      ConnectTo(Path);
      Result:= true;
    end;
  except
    on e: exception do begin
      if OldDB <> '' then begin
        try
          ConnectTo(OldDB);
        finally
        end;
      end;
      if e is EInvalidDatabase then raise;
    end;
  end;
end;

function TeDataBase.GetSignature(const Path: string; var Sign: string): integer;
var
  INI: TINIFile;
  Magic: string;
begin
  if FileExists(Path+DirSep+SignatureFile) then begin
    INI:= nil;
    try
      INI:= TINIFile.Create(Path+DirSep+SignatureFile);
      Sign:= INI.ReadString(SezDataBase, KeySignature, '');
      Magic:= Encoding.HexDecode(INI.ReadString(SezDataBase, KeyMagic, ''));
      INI.Free;
      if Validate(Sign, Magic) then Result:= DBSignatureValid
      else begin
        Result:= DBSignatureInValid;
      end;
    except
      try INI.Free; finally end;
      Result:= DBSignatureInvalid;
    end;
  end
  else begin
    Sign:= '';
    Result:= DBSignatureUnknown;
  end;
end;

procedure TeDataBase.Convalidate(const Path, Magic: string);
var
  INI: TINIFile;
begin
  INI:= nil;
  try
    INI:= TINIFile.Create(Path+DirSep+SignatureFile);
    INI.WriteString(SezDataBase, KeySignature, Signature);
    INI.WriteString(SezDataBase, KeyMagic, Encoding.HexEncode(Magic));
  finally
    INI.Free;
  end;
end;

function TeDataBase.Reconnect: boolean;
begin
  try
    Connected:= true;
    NotifyConnection(true);
    Result:= true;
  except
    Result:= false;
  end;
end;

constructor TDBLink.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FActive      := false;
  FStreamActive:= false;
end;

procedure   TDBLink.SetActive(vl: boolean);
begin
  if csLoading in ComponentState then FStreamActive:= vl
  else begin
    if FDataBase <> nil then begin
      if vl <> FActive then begin
        if vl then Activate
        else Deactivate;
        FActive:= vl;
      end;
    end;
  end;
end;

function    TDBLink.GetDataBase: TeDataBase;
begin
  Result:= FDataBase;
end;

procedure   TDBLink.SetDataBase(ADataBase: TeDataBase);
begin
  if (FDataBase <> nil) and FActive then Deactivate;
  FDataBase:= ADataBase;
  if (FDataBase <> nil) and FActive then Activate;
end;

procedure   TDBLink.Loaded;
begin
  inherited Loaded;
  if FStreamActive then Active:= true;
end;

procedure   TDBLink.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (FDataBase <> nil) and (FDataBase = AComponent) and (Operation=opRemove) then begin
    SetDataBase(nil);
  end;
end;

destructor  TDBLink.Destroy;
begin
  SetDataBase(nil);
  inherited Destroy;
end;

constructor TDBConnectionLink.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOnConnect   := nil;
  FOnDisconnect:= nil;
end;

procedure TDBConnectionLink.Activate;
begin
  if FDataBase<>nil then FDataBase.AddConnLink(Self);
end;

procedure TDBConnectionLink.DeActivate;
begin
  if FDataBase<>nil then FDataBase.DelConnLink(Self);
end;

procedure TDBConnectionLink.Connection(Connected: boolean);
begin
  case Connected of
    true: if Assigned(FOnConnect) then FOnConnect(FDatabase, true);
    else  if Assigned(FOnDisconnect) then FOnDisconnect(FDatabase, false);
  end;
end;

constructor TDBMessageLink.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOnMessage:= nil;
end;

procedure TDBMessageLink.Activate;
begin
  if FDataBase<>nil then FDataBase.AddMesgLink(Self);
end;

procedure TDBMessageLink.DeActivate;
begin
  if FDataBase<>nil then FDataBase.DelMesgLink(Self);
end;

procedure TDBMessageLink.Notify(Sender: TObject; Cmd: integer; Data: TObject);
begin
  if Assigned(FOnMessage) then FOnMessage(Sender, Cmd, Data);
end;

procedure ConnectDB(DB: TeDataBase; const Path: string);
begin
  DB.Connected:= false;
  if not DB.SelectDB(Path) then begin
    DB.Convalidate(Path, Crypt.SimpleCrypt(DB.Signature,DB.Signature));
    if not DB.SelectDB(Path) then begin
      raise EInvalidOperation.CreateFmt('Invalid database: %s', [Path]);
    end;
  end;
end;

function ConnectDataBase(DB: TeDataBase; const Path: string): boolean;
begin
  try
    ConnectDB(DB, Path);
    Result:= true;
  except
    Result:= false;
  end;
end;

procedure Register;
begin
  RegisterComponents(eCompPage, [TeDataBase]);
  RegisterComponents(eCompPage, [TDBConnectionLink]);
  RegisterComponents(eCompPage, [TDBMessageLink]);
end;

end.
