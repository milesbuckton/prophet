unit PalletCalculator.Utils;

interface

function CalculateAverage(PalletA, PalletB, PalletC: Int64): Double;

implementation

uses
  System.Math;

function CalculateAverage(PalletA, PalletB, PalletC: Int64): Double;
begin
  Result := RoundTo((PalletA + PalletB + PalletC) / 3, -2);
end;

end.
