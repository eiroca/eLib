(* GPL > 3.0
Copyright (C) 1996-2019 eIrOcA Enrico Croce & Simona Burzio

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
unit eLibVCL;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
  SysUtils, Classes, Windows, Forms, Graphics, Controls,
  {$IFNDEF FPC}
  Tabs,
  {$ENDIF}
  eLibCore, FWait, FAboutGPL;

procedure Rescale(Self: TForm; OldPixelsPerInch: longint);

{$IFNDEF FPC}
procedure DrawTab(TS: TTabSet; TabCanvas: TCanvas; R: TRect; Index: Integer; Selected: Boolean);
{$ENDIF}

function AskYesNo(const Msg: string): TModalResult;
function AskYesCancel(const Msg: string): TModalResult;
function AskYesNoCancel(const Msg: string): TModalResult;

procedure Inform(const S: string);
procedure UnderConstruction;
procedure Warn(const Msg: string);

procedure CloseHelp(const HelpFileName: string);
procedure OpenHelpContents(const HelpFileName: string);

type
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

procedure AboutGPL(me: string);

implementation

uses
  Dialogs;

procedure Rescale(Self: TForm; OldPixelsPerInch: longint);
var
  PPI: longint;
begin
  PPI:= Screen.PixelsPerInch;
  if PPI <> OldPixelsPerInch then begin
    Self.Width:= MulDiv(Self.Width,  PPI, OldPixelsPerInch);
    Self.Height:= MulDiv(Self.Height, PPI, OldPixelsPerInch);
    Self.ScaleBy(PPI, OldPixelsPerInch);
  end;
end;

{$IFNDEF FPC}
procedure DrawTab(TS: TTabSet; TabCanvas: TCanvas; R: TRect; Index: Integer; Selected: Boolean);
var
  X, Y: integer;
  tmp: string;
begin
  with TabCanvas do begin
    tmp:= TS.Tabs[Index];
    Y:= R.Top  + (R.Bottom-R.Top-TextHeight(tmp)) div 2;
    X:= R.Left + (R.Right-R.Left-TextWidth(tmp)) div 2;
    TextRect(R, X, Y, tmp);
  end;
end;
{$ENDIF}

function AskYesNo(const Msg: string): TModalResult;
begin
  AskYesNo:= MessageDlg(Msg, mtConfirmation, [mbYes, mbNo], 0);
end;

function AskYesCancel(const Msg: string): TModalResult;
begin
  AskYesCancel:= MessageDlg(Msg, mtConfirmation, [mbYes, mbCancel], 0);
end;

function AskYesNoCancel(const Msg: string): TModalResult;
begin
  AskYesNoCancel:= MessageDlg(Msg, mtConfirmation, [mbYes, mbNo, mbCancel], 0);
end;

procedure Inform(const S: string);
begin
  MessageDlg(S, mtInformation ,[mbOK],0);
end;

procedure UnderConstruction;
begin
  MessageDlg('This function does not work now. Sorry.', mtInformation, [mbOK], 0);
end;

procedure Warn(const Msg: string);
begin
  MessageDlg(Msg, mtWarning, [mbOK], 0);
end;

procedure CloseHelp(const HelpFileName: string);
begin
  Application.HelpFile:= HelpFileName;
  Application.HelpCommand(HELP_QUIT,0);
end;

procedure OpenHelpContents(const HelpFileName: string);
begin
  Application.HelpFile:= HelpFileName;
  Application.HelpCommand(HELP_CONTENTS,0);
end;

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
  FreeAndNil(wait);
end;

procedure AboutGPL(me: string);
var
  fmAbout: TfmAboutGPL;
begin
  fmAbout:= TfmAboutGPL.Create(nil);
  try
    fmAbout.Caption:= 'About - ' + me;
    fmAbout.ShowModal;
  finally
    fmAbout.Free;
  end;
end;

end.
