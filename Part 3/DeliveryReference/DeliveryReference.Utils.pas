unit DeliveryReference.Utils;

interface

function IsPalindrome(const ReferenceCode: string): Boolean;
function IsPalindromeCaseInsensitive(const ReferenceCode: string): Boolean;

implementation

uses
  System.SysUtils;

function IsPalindrome(const ReferenceCode: string): Boolean;
var
  i: Integer;
  reversed: string;
begin
  for i := Length(ReferenceCode) downto 1 do
    reversed := reversed + ReferenceCode[i];

  Result := ReferenceCode = reversed;
end;

function IsPalindromeCaseInsensitive(const ReferenceCode: string): Boolean;
var
  i: Integer;
  reversed: string;
begin
  for i := Length(ReferenceCode) downto 1 do
    reversed := reversed + ReferenceCode[i];

  Result := UpperCase(ReferenceCode) = UpperCase(reversed);
end;

end.
