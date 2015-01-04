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
unit eLibSystem;

interface

function  Execute(const Action, aFile, aParam: string): boolean;

implementation

uses
 Windows, Forms, ShellAPI;

 function Execute(const Action, aFile, aParam: string): boolean;
begin
  Result:= ShellExecute(Application.Handle, PChar(Action), PChar(AFile), PChar(aParam), nil, SW_SHOWNORMAL) > 32;
end;

end.
