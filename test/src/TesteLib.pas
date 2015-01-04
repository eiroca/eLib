(* GPL > 3.0
Copyright (C) 1996-2014 eIrOcA Enrico Croce & Simona Burzio

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
unit TesteLib;

interface

uses
  TestFramework, eLibCore, SysUtils;
type
  // Test methods for class Encoding

  TestEncoding = class(TTestCase)
  strict private
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestHexEncoding_001;
    procedure TestHexEncoding_002;
    procedure TestHexEncoding_003;
    procedure TestHexEncoding_004;
    procedure TestHexEncoding_005;
    procedure TestHexEncoding_006;
  end;

  TestParser = class(TTestCase)
  strict private
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestIVal_001;
    procedure TestIVal_002;
    procedure TestDVal_001;
    procedure TestDVal_002;
    procedure TestDVal_003;
    procedure TestDVal_004;
  end;

implementation

procedure TestEncoding.SetUp;
begin
  randomize;
end;

procedure TestEncoding.TearDown;
begin
end;

procedure TestEncoding.TestHexEncoding_001;
var
  ReturnValue: string;
begin
  ReturnValue := Encoding.HexDecode('');
  Check(ReturnValue='');
end;

procedure TestEncoding.TestHexEncoding_002;
var
  ReturnValue: string;
begin
  ReturnValue := Encoding.HexDecode('');
  Check(ReturnValue='');
end;

procedure TestEncoding.TestHexEncoding_003;
const
  LEN = 16;
var
  encoded: string;
  decoded: string;
  src: string;
  i: Integer;
begin
  SetLength(src, LEN);
  for i:= 1 to 16 do begin
    src[i]:= chr(random(256));
  end;
  encoded:= Encoding.HexEncode(src);
  Check(length(encoded)=(length(src)*2));
  decoded:= Encoding.HexDecode(encoded);
  Check(decoded=src);
end;

procedure TestEncoding.TestHexEncoding_004;
var
  v1: string;
  v2: string;
begin
  v1:= Encoding.HexDecode('0123');
  v2:= Encoding.HexDecode('123');
  Check(v1=v2);
  v1:= Encoding.HexDecode('Ab');
  v2:= Encoding.HexDecode('aB');
  Check(v1=v2);
end;

procedure TestEncoding.TestHexEncoding_005;
var
  v: string;
begin
  try
    v:= Encoding.HexDecode('012x4');
    v:= Encoding.HexDecode('0123x');
  except
    Exit;
  end;
  CheckException(TestHexEncoding_005, EConvertError);
end;

procedure TestEncoding.TestHexEncoding_006;
var
  v: string;
begin
  try
    v:= Encoding.HexDecode('0123x');
  except
    Exit;
  end;
  Check(false);
end;

procedure TestParser.SetUp;
begin
end;

procedure TestParser.TearDown;
begin
end;

procedure TestParser.TestIVal_001;
var
  i1: integer;
  i2: integer;
begin
  i1:= Parser.IVal(' 1 2 3 4');
  i2:= Parser.IVal('1234');
  Check(i1 = i2);
end;

procedure TestParser.TestIVal_002;
var
  i1: integer;
  i2: integer;
begin
  i1:= Parser.IVal('0.999');
  i2:= Parser.IVal('0.001');
  Check(i1 = i2);
  Check(i1 = 0);
end;

procedure TestParser.TestDVal_001;
var
  d1: double;
  d2: double;
begin
  d1:= Parser.DVal('');
  d2:= Parser.DVal('invalid');
  Check(d1 = d2);
end;

procedure TestParser.TestDVal_002;
var
  d1: double;
  d2: double;
begin
  d1:= Parser.DVal('1e3');
  d2:= Parser.DVal('1000');
  Check(d1 = d2);
end;

procedure TestParser.TestDVal_003;
var
  d1: double;
  d2: double;
begin
  d1:= Parser.DVal('');
  d2:= Parser.DVal('0.0');
  Check(d1 = d2);
end;

procedure TestParser.TestDVal_004;
var
  d1: double;
  d2: double;
begin
  d1:= Parser.DVal(' '+FormatSettings.CurrencyString+'1'+FormatSettings.ThousandSeparator+'0 0 0 . 1 '+#9);
  d2:= Parser.DVal('1000.1');
  Check(d1 = d2);
end;

initialization
  RegisterTest(TestEncoding.Suite);
  RegisterTest(TestParser.Suite);
end.

