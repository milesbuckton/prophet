program DeliveryDiscountTests;

{$IFDEF GUIRUNNER}
{$APPTYPE GUI}
{$ELSE}
{$APPTYPE CONSOLE}
{$ENDIF}
{$R *.res}

uses
  System.SysUtils,
  DUnitX.TestFramework,
{$IFDEF GUIRUNNER}
  DUnitX.Loggers.GUI.VCL,
{$ELSE}
  DUnitX.Loggers.Console,
{$ENDIF}
  DeliveryDiscount.Utils in '..\DeliveryDiscount\DeliveryDiscount.Utils.pas',
  DeliveryDiscount.Tests in 'DeliveryDiscount.Tests.pas';

var
  Runner: ITestRunner;
  Results: IRunResults;
  Logger: ITestLogger;

begin
{$IFDEF GUIRUNNER}
  TDUnitX.CheckCommandLine;
  DUnitX.Loggers.GUI.VCL.Run;
{$ELSE}
  try
    TDUnitX.CheckCommandLine;
    Runner := TDUnitX.CreateRunner;
    Logger := TDUnitXConsoleLogger.Create(True);
    Runner.AddLogger(Logger);
    Runner.FailsOnNoAsserts := False;
    Results := Runner.Execute;
    Writeln;
    if Results.AllPassed then
      Writeln('All tests passed.')
    else
    begin
      Writeln('Some tests FAILED.');
      System.ExitCode := 1;
    end;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      System.ExitCode := 1;
    end;
  end;
  Writeln;
  Write('Press Enter to exit...');
  ReadLn;
{$ENDIF}

end.
