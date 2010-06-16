// advantechUtil.h : Declaration of Advantech Utility functions
// Copyright 2002-2003 The MathWorks, Inc.
// $Revision: 1.1.6.2 $  $Date: 2004/07/30 01:55:55 $

#ifndef __ADVANTECHUTIL_H_
#define __ADVANTECHUTIL_H_
#define portMask4		(1<<4)-1
#define portMask5		(1<<5)-1
#define portMask8		(1<<8)-1
#define portMask16		(1<<16)-1
	
// Define Masks
// NOTE: The following code defines masks that are used to determine certain attributes supported by the 
//		 Advantech devices.
#define DWP_SOFTWARE_AI			(1<<0)	
#define	DWP_DMA_AI				(1<<1)	
#define DWP_DUALDMA_AI          (1<<21)
#define DWP_INTERUPTS_AI		(1<<2)	
#define DWP_AUTO_CHANNEL_SCAN   (1<<17)
#define DWP_INTERNAL_AI			(1<<18)	
#define DWP_EXTERNAL_AI			(1<<19) 
#define DWP_DMA_AO				(1<<5)
#define DWP_INT_AO				(1<<6)
		
/**
    * returns true if the requested section exists in the INI file.  Used to determine
    * if a board is supported
    *
    * @param lpAppName: Section/Board name
    * @param lpFileName: Name of the file to search
    *
    * @return bool: true if the sectino exists.  False, otherwise.
    */
bool isBoardinINIFile(LPCTSTR lpAppName,LPCTSTR lpFileName);

double GetPrivateProfileDouble(LPCTSTR lpAppName,LPCTSTR lpKeyName,double Default, LPCTSTR lpFileName);

bool GetPrivateProfileBool(LPCTSTR lpAppName,LPCTSTR lpKeyName,bool nDefault, LPCTSTR lpFileName);

#endif //__ADVANTECHUTIL_H_