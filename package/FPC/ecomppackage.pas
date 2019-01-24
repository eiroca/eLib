{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit eCompPackage;

{$warn 5023 off : no warning about unused units}
interface

uses
  eComp, eDataPick, eGauge, eReport, eReportEditor, eReportPreview, eSillaba, 
  eBDE, eBDEXTab, eBDEXTabEditor, eCompBDE, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('eCompPackage', @Register);
end.
