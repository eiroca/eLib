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
unit eRX;

interface

{$IFDEF RX}
uses
  RX;
{$ENDIF}

{$IFDEF RX}
function eval(s: string): extended;
{$ENDIF}

implementation

{$IFDEF RX}
var
  parser: TRxMathParser;
{$ENDIF}

{$IFDEF RX}
function eval(s: string): extended;
begin
  Result:= 0;
  if s<>'' then begin
    try
      Result:= parser.Exec(s);
    except
      Result:= 0;
    end;
  end;
end;
{$ENDIF}

initialization
{$IFDEF RX}
  parser:= TRxMathParser.Create;
{$ENDIF}
finalization
{$IFDEF RX}
  parser.Free;
{$ENDIF}
end.
