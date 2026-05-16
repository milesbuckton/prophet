program DeliveryReference;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  DeliveryReference.Utils in 'DeliveryReference.Utils.pas';

begin
  try
    Writeln(BoolToStr(IsPalindrome('ABA123ABA'), True));
    Writeln(BoolToStr(IsPalindrome('A1B1A'), True));
    Writeln(BoolToStr(IsPalindrome('Aa'), True));
    Writeln(BoolToStr(IsPalindromeCaseInsensitive('Aa'), True));
    Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
