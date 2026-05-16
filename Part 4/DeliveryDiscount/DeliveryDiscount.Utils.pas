unit DeliveryDiscount.Utils;

interface

function GetDiscountRate(OrderAmount: Double): Double;
procedure CalculateDeliveryDiscount(OrderAmount: Double);

implementation

uses
  System.SysUtils, Vcl.Dialogs;

function GetDiscountRate(OrderAmount: Double): Double;
begin
  if OrderAmount > 1000 then
    Result := 0.1
  else if OrderAmount > 500 then
    Result := 0.05
  else
    Result := 0;
end;

procedure CalculateDeliveryDiscount(OrderAmount: Double);
var
  DiscountRate: Double;
begin
  DiscountRate := GetDiscountRate(OrderAmount);
  ShowMessage('Discount: R' + FloatToStr(DiscountRate * OrderAmount));
end;

end.
