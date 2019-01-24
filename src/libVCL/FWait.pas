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
unit FWait;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
   SysUtils, Classes, Forms, ComCtrls, Controls, StdCtrls, Buttons;

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

implementation

{$IFDEF FPC}
  {$R *.LFM}
{$ELSE}
  {$R *.DFM}
{$ENDIF}

uses
  eLibVCL;

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

