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
unit eSillaba;

{$IFDEF FPC}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
  Classes, SysUtils, eComp;

(*
Procedura per sillabare una parola secondo le regole di sillabazione italiane
@param(Parola da sillabare)
@param(TStrings che conterra' le sillabe della parola)
*)
procedure Sillaba(Parola: string; Sil: TStrings);

(*
Funzione che restituisce una stringa con tutte le sillabe
@param(Sillabe da visualizzare
@param(Separatore da utilizzare per dividere le sillabe
@returns(La concatenazione delle sillabe o '' se non vi ne erano)
*)
function WriteSillabe(Sil: TStrings; const Sep: string): string;

type
  (* Classe wrapper per la gestione della sillabazione di una parola *)
  TeSillabITA = class(TComponent)
    private
     FSillabe: TStrings;
     FParola : string;
     FSep    : string;
     procedure SetParola(const Parola: string);
     function  GetParolaSillabata: string;
    public
     constructor Create(AOwner: TComponent); override;
     destructor  Destroy; override;
    published
     property Sillabe: TStrings
       read FSillabe;
     property Parola: string
       read FParola
       write SetParola;
     property Separatore: string
       read FSep
       write FSep;
     property ParolaSillabata: string
       read GetParolaSillabata;
  end;

procedure Register;

implementation

procedure Sillaba(Parola: string; Sil: TStrings);
var
  OldPos: integer;
  CurPos: integer;
  len   : integer;
  function IsVocale(ps: integer): boolean;
  begin
    Result:= CharInSet(UpCase(Parola[ps]), ['A','E','I','O','U','Y','à','è','é','ì','ò','ù']);
  end;
  function IsSemiConsonante(ps: integer): boolean;
  begin
    Result:= CharInSet(UpCase(Parola[ps]), ['I','U','Y']);
  end;
  function IsDoppia(ps: integer): boolean;
  begin
    Result:= Upcase(Parola[ps])=Upcase(Parola[ps+1]);
  end;
  function IsPlatale(ps: integer): boolean;
  begin
    Result:= (Upcase(Parola[ps])='G') and CharInSet(Upcase(Parola[ps+1]), ['L','N']);
  end;
  function IsEsse(ps: integer): boolean;
  begin
    Result:= Upcase(Parola[ps])='S';
  end;
  function IsLegata(ps: integer): boolean;
  begin
    Result:= CharInSet(Upcase(Parola[ps+1]), ['H','L','R']) and
      (not CharInSet(Upcase(Parola[ps]), ['N','M','H','L','R']));
  end;
  function IsDoppiaFissa(ps: integer): boolean;
  begin
    Result:= (not IsDoppia(ps)) and (IsPlatale(ps) or IsEsse(ps) or IsLegata(ps));
  end;
  procedure PushSillaba;
  begin
    if (CurPos>OldPos) and (CurPos<=Len) then begin
      Sil.Add(Copy(Parola, OldPos+1, CurPos-OldPos));
      OldPos:=CurPos;
    end;
  end;
begin
  Sil.Clear;
  Len:= length(Parola);
  if Len <= 2 then begin
    Sil.Add(Parola);
    exit;
  end;
  OldPos:= 0;
  CurPos:= 0;
  repeat
    inc(CurPos);
    if CurPos>=Len then break;
    if not IsVocale(CurPos) then continue;
    if CurPos+1>=Len then break;
    if IsVocale(CurPos+1) then begin
      if not IsSemiConsonante(CurPos) then PushSillaba;
      continue;
    end;
    if CurPos+2>Len then break;
    if IsVocale(CurPos+2) then begin
      PushSillaba;
      continue;
    end;
    if CurPos+2=Len then break;
    if not IsDoppiaFissa(CurPos+1) then begin
      inc(CurPos);
    end;
    PushSillaba;
  until false;
  CurPos:= Len;
  PushSillaba;
end;

function WriteSillabe(Sil: TStrings; const Sep: string): string;
var
  i: integer;
begin
  Result:= '';
  if Sil.Count > 0 then begin
    Result:= Sil[0];
    for i:= 1 to Sil.Count-1 do begin
      Result:= Result + Sep + Sil[i];
    end;
  end;
end;

constructor TeSillabITA.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSep:= '-';
  FParola:= '';
  FSillabe:= TStringList.Create;
end;

procedure TeSillabITA.SetParola(const Parola: string);
begin
  if Parola <> FParola then begin
    FParola:= Parola;
    Sillaba(Parola, Sillabe);
  end;
end;

function  TeSillabITA.GetParolaSillabata: string;
begin
  Result:= WriteSillabe(Sillabe, Separatore);
end;

destructor  TeSillabITA.Destroy;
begin
  FSillabe.Free;
  inherited Destroy;
end;

procedure Register;
begin
  RegisterComponents(eCompPage, [TeSillabITA]);
end;

end.

