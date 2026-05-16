program PalletCalculator;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  Vcl.Dialogs,
  PalletCalculator.Utils in 'PalletCalculator.Utils.pas';

begin
  try
    ShowMessage(FloatToStr(CalculateAverage(1, 2, 3)));
    ShowMessage(FloatToStr(CalculateAverage(2, 5, 6)));
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;
end.
