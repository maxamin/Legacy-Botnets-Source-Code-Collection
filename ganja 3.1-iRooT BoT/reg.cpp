BOOL CMyRegKey::mRegDeleteKey(HKEY mTopKey, TCHAR* mSubKey)
{
	DWORD disposition;
	HKEY mThisKey;
	FILETIME ft;
	TCHAR mbuf[256];

	if (ERROR_SUCCESS != RegOpenKeyEx(mTopKey, mSubKey,0, KEY_ALL_ACCESS,&mThisKey))
		if (ERROR_SUCCESS != RegCreateKeyEx(mTopKey, mSubKey, 0, "", REG_OPTION_NON_VOLATILE,KEY_ALL_ACCESS,NULL, &mThisKey,&disposition))
			return FALSE;
	

	DWORD sz;
	sz=256;
	if (ERROR_SUCCESS != RegEnumKeyEx(mThisKey, 0, mbuf, &sz, NULL, NULL, NULL, &ft))
		return FALSE;

	if (ERROR_SUCCESS != RegDeleteKey(mThisKey, mbuf))
		return FALSE;

	RegCloseKey(mThisKey);
		return TRUE;
}