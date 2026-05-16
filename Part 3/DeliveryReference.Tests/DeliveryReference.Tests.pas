unit DeliveryReference.Tests;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TDeliveryReferenceTests = class
  public
    [Test]
    procedure TestIsPalindrome_WithPalindrome_ReturnsTrue;
    [Test]
    procedure TestIsPalindrome_WithNonPalindrome_ReturnsFalse;
    [Test]
    procedure TestIsPalindrome_SingleChar_ReturnsTrue;
    [Test]
    procedure TestIsPalindrome_EmptyString_ReturnsTrue;
    [Test]
    procedure TestIsPalindromeCaseInsensitive_MixedCase_ReturnsTrue;
    [Test]
    procedure TestIsPalindromeCaseInsensitive_NonPalindrome_ReturnsFalse;
    [Test]
    procedure TestIsPalindrome_CaseSensitive_ReturnsFalse;
  end;

implementation

uses
  DeliveryReference.Utils;

procedure TDeliveryReferenceTests.TestIsPalindrome_WithPalindrome_ReturnsTrue;
begin
  Assert.IsTrue(IsPalindrome('A1B1A'));
  Assert.IsTrue(IsPalindrome('abcba'));
  Assert.IsTrue(IsPalindrome('12321'));
end;

procedure TDeliveryReferenceTests.TestIsPalindrome_WithNonPalindrome_ReturnsFalse;
begin
  Assert.IsFalse(IsPalindrome('ABC123'));
  Assert.IsFalse(IsPalindrome('Hello'));
  Assert.IsFalse(IsPalindrome('ABA123ABA'));
end;

procedure TDeliveryReferenceTests.TestIsPalindrome_SingleChar_ReturnsTrue;
begin
  Assert.IsTrue(IsPalindrome('A'));
end;

procedure TDeliveryReferenceTests.TestIsPalindrome_EmptyString_ReturnsTrue;
begin
  Assert.IsTrue(IsPalindrome(''));
end;

procedure TDeliveryReferenceTests.TestIsPalindromeCaseInsensitive_MixedCase_ReturnsTrue;
begin
  Assert.IsTrue(IsPalindromeCaseInsensitive('Aa'));
  Assert.IsTrue(IsPalindromeCaseInsensitive('AbBa'));
  Assert.IsTrue(IsPalindromeCaseInsensitive('RaCeCaR'));
end;

procedure TDeliveryReferenceTests.TestIsPalindromeCaseInsensitive_NonPalindrome_ReturnsFalse;
begin
  Assert.IsFalse(IsPalindromeCaseInsensitive('Hello'));
  Assert.IsFalse(IsPalindromeCaseInsensitive('ABC123'));
end;

procedure TDeliveryReferenceTests.TestIsPalindrome_CaseSensitive_ReturnsFalse;
begin
  Assert.IsFalse(IsPalindrome('Aa'));
  Assert.IsFalse(IsPalindrome('AbBa'));
end;

initialization
  TDUnitX.RegisterTestFixture(TDeliveryReferenceTests);

end.
