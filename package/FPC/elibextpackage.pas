{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit eLibExtPackage;

{$warn 5023 off : no warning about unused units}
interface

uses
  eLibDB, eLibTAGExtractor, eLibBDE, eLibLegacy, eLibRX, eLibVCL, FAboutGPL, 
  FWait, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('eLibExtPackage', @Register);
end.
