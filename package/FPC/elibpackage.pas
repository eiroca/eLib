{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit eLibPackage;

{$warn 5023 off : no warning about unused units}
interface

uses
  eLibComplex, eLibCore, eLibHashList, eLibMath, eLibStat, eLibSystem, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('eLibPackage', @Register);
end.
