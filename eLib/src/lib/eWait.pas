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
unit eWait;

interface

uses
  eLib, SysUtils, Classes, Windows, Forms, ComCtrls, Controls, StdCtrls, Buttons;

type
  TfmWait = class(TForm)
    BitBtn1: TBitBtn;
    PB: TProgressBar;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    Closable: boolean;
    FOnAbort: TNotifyEvent;
  public
    { Public declarations }
    Aborted: boolean;
    property OnAbort: TNotifyEvent read FOnAbort write FOnAbort;
  end;

  TProgress = class(TInterfacedObject, IProgress)
    private
     wait: TfmWait;
     function  GetAborted: boolean;
     function  GetProgress: integer;
     procedure SetProgress(aProgress: integer);
     function  GetOnAbort: TNotifyEvent;
     procedure SetOnAbort(Event: TNotifyEvent);
    protected
     function  getCaption: string;
     procedure setCaption(cap: string);
    public
     property Caption: string read getCaption write setCaption;
    public
     constructor Create(aMin, aMax: integer);
     procedure   Init(aMin, aMax: integer);
     destructor  Destroy; override;
     procedure   Step;
    public
     property Progress: integer read GetProgress write SetProgress;
    property OnAbort: TNotifyEvent
      read  GetOnAbort
      write SetOnAbort;
     property Aborted: boolean
       read GetAborted;
  end;


implementation

{$R *.DFM}

uses
  eLibVCL;

constructor TProgress.Create(aMin, aMax: integer);
begin
  wait:= TfmWait.Create(nil);
  Init(aMin, aMax);
  wait.Show;
end;

procedure TProgress.Init(aMin, aMax: integer);
begin
  wait.PB.Min:= aMin;
  wait.PB.Max:= aMax;
  wait.PB.Position:= aMin;
  wait.Refresh;
end;

function  TProgress.getCaption: string;
begin
  Result:= wait.Caption;
end;

procedure TProgress.setCaption(cap: string);
begin
  wait.Caption:= cap;
end;

function TProgress.GetAborted: boolean;
begin
  Result:= wait.Aborted;
end;

function TProgress.GetProgress: integer;
begin
  Result:= wait.PB.Position;
end;

procedure TProgress.SetProgress(aProgress: integer);
begin
  wait.PB.Position:= aProgress;
  wait.PB.Update;
end;

procedure TProgress.Step;
begin
  Progress:= Progress+1;
end;

function  TProgress.GetOnAbort: TNotifyEvent;
begin
  Result:= wait.OnAbort;
end;

procedure TProgress.SetOnAbort(Event: TNotifyEvent);
begin
  wait.OnAbort:= Event;
end;

destructor TProgress.Destroy;
begin
  wait.Closable:= true;
  wait.Free;
end;

procedure TfmWait.BitBtn1Click(Sender: TObject);
begin
  Aborted:= true;
  if Assigned(OnAbort) then OnAbort(Self);
end;

procedure TfmWait.FormCreate(Sender: TObject);
begin
  Rescale(Self, 96);
  Aborted:= false;
  Closable:= false;
  FOnAbort:= nil;
end;

procedure TfmWait.FormDeactivate(Sender: TObject);
begin
  if not Closable then Show;
end;

procedure TfmWait.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:= Closable;
end;

end.


