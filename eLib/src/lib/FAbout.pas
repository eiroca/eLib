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
unit FAbout;

interface

uses
  SysUtils, Classes, Windows, Forms, Controls, StdCtrls, Buttons;

type
  TfmAbout = class(TForm)
    BitBtn1: TBitBtn;
    Label1: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure About(me: string);

implementation

{$R *.dfm}

procedure About(me: string);
var
  fmAbout: TfmAbout;
begin
  fmAbout:= TfmAbout.Create(nil);
  try
    fmAbout.Caption:= 'About - '+me;
    fmAbout.ShowModal;
  finally
    fmAbout.Free;
  end;
end;

end.
