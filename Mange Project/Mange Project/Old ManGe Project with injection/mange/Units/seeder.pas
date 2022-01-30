unit seeder;

interface

uses Windows, SysUtils, ShFolder;

    function IsUtorrent(): Boolean;
    function IsBitTorrent(): Boolean;
    function IsVuze(): Boolean;
    procedure SeedIt(ClientPath: AnsiString; LocalPath: AnsiString; torrentPath: AnsiString);
    procedure SeedItVuze(ClientPath: AnsiString; TorrentURL: AnsiString);
    procedure DoIt(torrentPath: AnsiString);
    procedure ExecuteFile(Path: String);
    function GetAppDataPath() : String;
    function GetProgramFilesPath: string;


var    UTorrentPath, UTorrentLocalPath, BitTorrentPath, BitLocalPath, VuzePath, VuzeLocalPath: AnsiString;


implementation


function GetProgramFilesPath: string;
var
P: Array[0..MAX_PATH] of char;
ProgramFilesDir: string;
begin
if SHGetFolderPath(0, CSIDL_PROGRAM_FILES, 0,0, @P[0]) = S_OK then
ProgramFilesDir:= P
else
ProgramFilesDir:= '';
result:= ProgramFilesDir;
end;


function GetAppDataPath() : String;
var
  SHGetFolderPath :TSHGetFolderPath;
  hFolderDLL : THandle;
var
  Buf: array[0..256] of Char;
begin
  hFolderDLL := LoadLibrary('SHFolder.dll');
  try
    SHGetFolderPath := nil;
    if hFolderDLL <> 0 then @SHGetFolderPath := GetProcAddress(hFolderDLL, 'SHGetFolderPathA');
    if Assigned(SHGetFolderPath) and (S_OK = SHGetFolderPath(0, CSIDL_APPDATA or CSIDL_FLAG_CREATE, 0, 0, Buf)) then
    else
    GetTempPath(Max_path, Buf);
  finally
    if hFolderDLL <> 0 then FreeLibrary(hFolderDLL);
    Result := String(Buf);
  end;
end;

procedure ExecuteFile(Path: String);
var
  PI: TProcessInformation;
  SI: TStartupInfo;
begin
  FillChar(SI, SizeOf(SI), $00);
  SI.dwFlags := STARTF_USESHOWWINDOW;
  SI.wShowWindow := SW_HIDE;
  if CreateProcess(nil, PChar(Path), nil, nil, False, IDLE_PRIORITY_CLASS, nil, nil, SI, PI) then
  begin
    CloseHandle(PI.hThread);
    CloseHandle(PI.hProcess);
  end;
end;

function IsUtorrent(): Boolean;
begin
    if FileExists(UTorrentPath) then begin
        Result := true;
    end else begin
        Result := false;
    end;

end;

function IsBitTorrent(): Boolean;
begin
    if FileExists(BitTorrentPath) then begin
        Result := true;
    end else begin
        Result := false;
    end;

end;

function IsVuze(): Boolean;
begin
    if FileExists(VuzePath) then begin
        Result := true;
    end else begin
        Result := false;
    end;

end;

procedure SeedIt(ClientPath: AnsiString; LocalPath: AnsiString; torrentPath: AnsiString);
begin

    ExecuteFile(ClientPath+' /DIRECTORY '+LocalPath+' '+torrentPath);

end;

procedure SeedItVuze(ClientPath: AnsiString; TorrentURL: AnsiString);
begin

    ExecuteFile(ClientPath+' '+TorrentURL);

end;

procedure DoIt(torrentPath: AnsiString);
begin

    if IsVuze() then begin
        SeedItVuze(VuzePath, torrentPath);

    end else if IsBitTorrent() then begin
        SeedIt(BitTorrentPath, BitLocalPath, torrentPath);

    end else if IsUtorrent() then begin
        SeedIt(UTorrentPath, UTorrentLocalPath, torrentPath);

    end;

end;


end.
 
 