unit DeliveryDiscount.Tests;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TDeliveryDiscountTests = class
  public
    [Test]
    procedure TestDiscount_Over1000_Returns10Percent;
    [Test]
    procedure TestDiscount_Over500_Returns5Percent;
    [Test]
    procedure TestDiscount_Under500_ReturnsZero;
    [Test]
    procedure TestDiscount_Exactly1000_Returns5Percent;
    [Test]
    procedure TestDiscount_Exactly500_ReturnsZero;
  end;

implementation

uses
  DeliveryDiscount.Utils;

procedure TDeliveryDiscountTests.TestDiscount_Over1000_Returns10Percent;
begin
  Assert.AreEqual(Double(0.1), GetDiscountRate(1200));
end;

procedure TDeliveryDiscountTests.TestDiscount_Over500_Returns5Percent;
begin
  Assert.AreEqual(Double(0.05), GetDiscountRate(600));
end;

procedure TDeliveryDiscountTests.TestDiscount_Under500_ReturnsZero;
begin
  Assert.AreEqual(Double(0), GetDiscountRate(200));
end;

procedure TDeliveryDiscountTests.TestDiscount_Exactly1000_Returns5Percent;
begin
  Assert.AreEqual(Double(0.05), GetDiscountRate(1000));
end;

procedure TDeliveryDiscountTests.TestDiscount_Exactly500_ReturnsZero;
begin
  Assert.AreEqual(Double(0), GetDiscountRate(500));
end;

initialization
  TDUnitX.RegisterTestFixture(TDeliveryDiscountTests);

end.
