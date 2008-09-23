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
unit eLibVCL;

interface

uses
  Windows, Forms, Graphics, Controls, Tabs;

procedure Rescale(Self: TForm; OldPixelsPerInch: longint);

procedure DrawTab(TS: TTabSet; TabCanvas: TCanvas; R: TRect; Index: Integer; Selected: Boolean);

function AskYesNo(const Msg: string): TModalResult;
function AskYesCancel(const Msg: string): TModalResult;
function AskYesNoCancel(const Msg: string): TModalResult;

procedure Inform(const S: string);
procedure UnderConstruction;
procedure Warn(const Msg: string);

procedure CloseHelp(const HelpFileName: string);
procedure OpenHelpContents(const HelpFileName: string);

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

end.
