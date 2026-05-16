program DeliveryDiscount;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  DeliveryDiscount.Utils in 'DeliveryDiscount.Utils.pas';

begin
  try
    CalculateDeliveryDiscount(1200);
    CalculateDeliveryDiscount(600);
    CalculateDeliveryDiscount(200);
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;

end.
