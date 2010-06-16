/**
 *              
 * \file winio.h
 * Protypes for entry functions into WINIO.DLL
 *              
 * $Authors:    Rob Purser $
 *              
 * $Copyright 2004 The MathWorks, Inc. $
 * $Date: 2004/12/18 07:35:15 $
 * $Revision: 1.1.6.3 $
 *
 * $Log: winio.h,v $
 * Revision 1.1.6.3  2004/12/18 07:35:15  batserve
 * 2004/12/05  1.1.4.3  batserve
 *   2004/12/01  1.1.4.2.2.1  dleffing
 *     Related Records: 243757
 *     Code Reviewer: TBRB:rpurser
 *     Make error message more user-friendly when another running MATLAB is already
 *     using the parallel driver WinIO.sys.
 *   Accepted job 4884 in Atestmeas
 * Accepted job 25974 in A
 *
 * Revision 1.1.4.3  2004/12/05 10:42:55  batserve
 * 2004/12/01  1.1.4.2.2.1  dleffing
 *   Related Records: 243757
 *   Code Reviewer: TBRB:rpurser
 *   Make error message more user-friendly when another running MATLAB is already
 *   using the parallel driver WinIO.sys.
 * Accepted job 4884 in Atestmeas
 *
 * Revision 1.1.4.2.2.1  2004/12/01 15:24:39  dleffing
 * Related Records: 243757
 * Code Reviewer: TBRB:rpurser
 * Make error message more user-friendly when another running MATLAB is already
 * using the parallel driver WinIO.sys.
 *
 * Revision 1.1.4.2  2004/06/25 14:11:21  batserve
 * 2004/06/24  1.1.4.1.2.1  rpurser
 *   Related Records: 209861,223993
 *   Sinificant rewrite of the way that parallel port code finds the WINIO.SYS
 *   file. It now starts in the same directory as the exe, then looks for a
 *   subdirectory with the name <MYEXE>_MCR and recursively searches it for
 *   WINIO.SYS. Added more fault information on why the load of the device driver
 *   failed, and added check for an already running service, so that
 *   non-administrators can use the parallel port if an administrative user has
 *   set it up.
 * Accepted job 2332a in Atestmeas
 *
 * Revision 1.1.4.1.2.1  2004/06/24 20:51:11  rpurser
 * Related Records: 209861,223993
 * Sinificant rewrite of the way that parallel port code finds the WINIO.SYS
 * file. It now starts in the same directory as the exe, then looks for a
 * subdirectory with the name <MYEXE>_MCR and recursively searches it for
 * WINIO.SYS. Added more fault information on why the load of the device driver
 * failed, and added check for an already running service, so that
 * non-administrators can use the parallel port if an administrative user has
 * set it up.
 *
 *
 */

#define WINIO_SUCCESS 0
#define WINIO_ERR_GENERAL 1
#define WINIO_ERR_COULD_NOT_START_WINIO_SYS 2
#define WINIO_ERR_NO_WINIO_SYS 3
#define WINIO_ERR_COULD_NOT_COPY_WINIO_SYS 4
#define WINIO_ERR_WINIO_SYS_DID_NOT_START 5
#define WINIO_ERR_COULD_NOT_CONNECT_WINIO_SYS 6
#define WINIO_ERR_WINIO_SYS_IN_USE 7

bool _stdcall InitializeWinIo();
int _stdcall InitializeWinIoV2();
void _stdcall ShutdownWinIo();

