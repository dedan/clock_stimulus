// AdvantechUtil.cpp: Advantech Utility and Helper Functions.
// Copyright 2002-2003 The MathWorks, Inc.
// $Revision: 1.1.6.2 $  $Date: 2004/07/30 01:55:54 $

#include "stdafx.h"
#include "advantechUtil.h"


/////////////////////////////////////////////////////////////////////////////
// isBoardinINIFile()
//
// Function is used to check if a board is in the INI file (and therefore exists.
//////////////////////////////////////////////////////////////////////////////
bool isBoardinINIFile(LPCTSTR lpAppName,LPCTSTR lpFileName)
{
    char buf[30];
    int outLen;
    
    // Test to see if the section exists at all
    outLen = GetPrivateProfileString(lpAppName,NULL,"",buf,sizeof(buf) - 1,lpFileName);
    // if the returned length is anything other than 0, then it exists.
    return (outLen!=0);
}

/////////////////////////////////////////////////////////////////////////////
// GetPrivateProfileDouble()
//
// Function is used to obtain doubles from an INI file.
//////////////////////////////////////////////////////////////////////////////
double GetPrivateProfileDouble(LPCTSTR lpAppName, LPCTSTR lpKeyName, double Default, LPCTSTR lpFileName)
{
    char buf[30],*ptr;
    int outLen=GetPrivateProfileString(lpAppName,lpKeyName,"",buf,sizeof(buf) - 1,lpFileName);
    if (outLen==0) return Default;
    double outval=strtod(buf,&ptr);
    if(ptr!=buf)
        return outval;
    else
        return Default;
}

/////////////////////////////////////////////////////////////////////////////
// GetPrivateProfileBool()
//
// Function is used to obtain boolean values from an INI file.
// Taken from ComputerBoards implementation; changed to non-inlined.
//////////////////////////////////////////////////////////////////////////////
bool GetPrivateProfileBool(LPCTSTR lpAppName,LPCTSTR lpKeyName,bool nDefault, LPCTSTR lpFileName)
{
    return GetPrivateProfileInt(lpAppName,lpKeyName,nDefault,lpFileName) == 0 ? false : true;
}
