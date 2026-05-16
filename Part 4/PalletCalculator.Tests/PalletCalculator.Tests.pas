unit PalletCalculator.Tests;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPalletCalculatorTests = class
  public
    [Test]
    procedure TestCalculateAverage_BasicValues;
    [Test]
    procedure TestCalculateAverage_EqualValues;
    [Test]
    procedure TestCalculateAverage_ZeroValues;
    [Test]
    procedure TestCalculateAverage_LargeValues;
    [Test]
    procedure TestCalculateAverage_RoundsToTwoDecimals;
  end;

implementation

uses
  PalletCalculator.Utils;

procedure TPalletCalculatorTests.TestCalculateAverage_BasicValues;
begin
  Assert.AreEqual(Double(2.0), CalculateAverage(1, 2, 3), 0.01);
end;

procedure TPalletCalculatorTests.TestCalculateAverage_EqualValues;
begin
  Assert.AreEqual(Double(5.0), CalculateAverage(5, 5, 5), 0.01);
end;

procedure TPalletCalculatorTests.TestCalculateAverage_ZeroValues;
begin
  Assert.AreEqual(Double(0.0), CalculateAverage(0, 0, 0), 0.01);
end;

procedure TPalletCalculatorTests.TestCalculateAverage_LargeValues;
begin
  Assert.AreEqual(Double(1000.0), CalculateAverage(500, 1000, 1500), 0.01);
end;

procedure TPalletCalculatorTests.TestCalculateAverage_RoundsToTwoDecimals;
begin
  Assert.AreEqual(Double(4.33), CalculateAverage(2, 5, 6), 0.01);
end;

initialization
  TDUnitX.RegisterTestFixture(TPalletCalculatorTests);

end.
