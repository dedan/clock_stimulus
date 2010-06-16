// Copyright 1998-2004 The MathWorks, Inc. 
// $Revision: 1.3.4.9 $  $Date: 2004/12/18 07:35:11 $


/******************************************************************************
 *
 * NIUTIL.CPP
 * Utilities for the MWNIDAQ DLL
 * 
 * GBL
 * 2/5/97
 */

#include "stdafx.h"
#include <stdio.h>
#include <vector>
#include <math.h>
#include "daqmex.h"
#include "daqtypes.h"	// data types
#include <nidaq.h>	// required for NI-DAQ
#include <nidaqcns.h>	// required for NI-DAQ
#include "niutil.h"

double round(double x);

CComBSTR TranslateErrorCode(HRESULT code)
{
	//first try the resource file
    CComBSTR retval;
	// Must cast to USHORT for CComBSTR::LoadString to work
    if(!retval.LoadString((USHORT)code)) 
    {
        code=-code;
        if(!retval.LoadString((USHORT)code))
            return CComBSTR();
            // translate error message?
    }
    if (code>-20000 && code <-10000)
    {
       CComBSTR nd(L"NI-DAQ: ");
       nd+=retval;
       return nd;
    }

    return retval; 
}




//
//  Use the nidaq ini file to gather information about the device
//

template <class T>
long ParseStringToFixed(char *string, T** ptr)
{
    std::vector<T> output;
    while (string!=NULL && *string!=0) 
    {
        output.push_back(static_cast<T>(strtol(string,&string,10)));
        string=strchr(string,',');
        if (string)
        {
            string++;
        }
    }
    *ptr=new T[output.size()];
    memcpy(*ptr,&output[0],output.size()*sizeof(T));
    return output.size();
}

long ParseStringToDouble(char *string,double **ptr)
{
	std::vector<double> output;
    while (string!=NULL && *string!=0) 
    {
        output.push_back(strtod(string,&string));
        string=strchr(string,',');
        if (string)
        {
            string++;
        }
    }
    *ptr=new double[output.size()];
	memcpy(*ptr,&output[0],output.size()*sizeof(double));
	return output.size();
}

short *ParseStringToShorts(int count,char *string)
{
    short *p=new short[count];
    memset(p,0,sizeof(*p)*count);
    for (int i=0;i<count;i++)
    {
        p[i]=static_cast<short>(strtol(string,&string,10));
        string=strchr(string,',');
        if (string==NULL || *string==0 || *++string==0)
        {
            _ASSERTE(i==count-1);
            break;
        }
    }
    return p;
}

double *ParseStringToDoubles(int count,char *string)
{
    double *p=new double[count];
    memset(p,0,sizeof(*p)*count);
    for (int i=0;i<count;i++)
    {
        p[i]=strtod(string,&string);
        string=strchr(string,',');
        if (string==NULL || *string==0 || *++string==0)
        {
            _ASSERTE(i==count-1);
            break;
        }
    }
    return p;
}

inline bool GetPrivateProfileBool(    LPCTSTR lpAppName,LPCTSTR lpKeyName,bool nDefault, LPCTSTR lpFileName)
{
    return GetPrivateProfileInt( lpAppName,lpKeyName,nDefault,lpFileName) == 0 ? false : true;
}

double GetPrivateProfileDouble(    LPCTSTR lpAppName,LPCTSTR lpKeyName,double Default, LPCTSTR lpFileName)
{
    char buf[30],*ptr;
    int outLen=GetPrivateProfileString(lpAppName,lpKeyName,"",buf,29,lpFileName);
    if (outLen==0) return Default;
    double outval=strtod(buf,&ptr);
    if(ptr!=buf)
        return outval;
    else
        return Default;
}

int DevCaps::LoadDeviceInfo()
{  
    
    char Section[16];
    
    char fname[512];
    char tmpString[512];
    
    // we expect the ini file to be in the same directory as the application,
    // namely, this DLL. It's the only way to find the file if it's not
    // in the windows subdirectory

    if (GetModuleFileName(_Module.GetModuleInstance(), fname, 512)==0)
        return E_FAIL;
    
    // replace .dll with .ini
    strrchr(fname, '.' )[1]='\0';
    strcat(fname,"ini"); 
    
    // create a key to search on
    sprintf(Section, "board%d", deviceCode);
    

    DWORD outLen = GetPrivateProfileString(Section,
        "name", "unknown", tmpString, 32, fname);

    deviceName = new char [strlen(tmpString)+1];
    strcpy(deviceName, tmpString);    

    deviceType= GetPrivateProfileInt(Section, "device", 0, fname);

    adcResolution = GetPrivateProfileInt(Section, 
        "adcResolution", 12, fname);

    dacResolution = GetPrivateProfileInt(Section, 
        "dacResolution", 12, fname);

    minSampleRate = GetPrivateProfileDouble(Section,
        "minSR", .006 , fname);

    maxAISampleRate = GetPrivateProfileDouble(Section,
        "maxAISR", 100000, fname);

    maxAOSampleRate = GetPrivateProfileDouble(Section,
        "maxAOSR", 100000, fname);

    AIFifoSize = GetPrivateProfileInt(Section,
        "ADCFIFO", 512, fname);

    AOFifoSize = GetPrivateProfileInt(Section,
        "DACFIFO", 2048, fname);
    
    HasMite= GetPrivateProfileBool(Section,
        "MITE", 0, fname);

    settleTime = GetPrivateProfileDouble(Section,
        "settleTime", 10, fname);

    nInputs = GetPrivateProfileInt(Section,
        "inputs", 0, fname);

    outLen=GetPrivateProfileString(Section,"coupling","DC",tmpString, 
        512, fname);
    Coupling=tmpString;
    
    outLen=GetPrivateProfileString(Section,"SEInputIDs","",tmpString, 
        512, fname);
    if (outLen==0)
    {
        nSEInputIDs=nInputs;
        SEInputIDs=new short[nInputs];
        for (int i=0;i<nInputs;i++)
            SEInputIDs[i]=i;
    }
    else
    {
        nSEInputIDs=static_cast<short>(ParseStringToFixed(tmpString,&SEInputIDs));
    }

    outLen=GetPrivateProfileString(Section,"DIInputIDs","",tmpString, 
        512, fname);
    if (outLen==0)
    {
        nDIInputIDs=nInputs/2;
        DIInputIDs=new short[nInputs/2];
        for (int i=0;i<nInputs/2;i++)
            DIInputIDs[i]=i;
    }
    else
    {
        nDIInputIDs=static_cast<short>(ParseStringToFixed(tmpString,&DIInputIDs));
    }

    nOutputs = GetPrivateProfileInt(Section,
        "outputs", 0, fname);

    nDIOLines= GetPrivateProfileInt(Section,"diolines", 0, fname);

    scanning = GetPrivateProfileBool(Section,
        "scanning", true, fname);

    analogTrig = GetPrivateProfileBool(Section,
        "analogTrig", true, fname);

    digitalTrig = GetPrivateProfileBool(Section,
        "digitalTrig",true, fname);


    unipolarRange=GetPrivateProfileDouble(Section, "unipolarRange", 0, fname);
    bipolarRange=GetPrivateProfileDouble(Section, "bipolarRange", 5, fname);
    supportsUnipolar=unipolarRange!=0;

    dacUnipolarRange=GetPrivateProfileDouble(Section, "dacUnipolarRange", 0, fname);
    dacBipolarRange=GetPrivateProfileDouble(Section, "dacBipolarRange", 0, fname);

    // now read in the gain info unipolar first
 //   sprintf(GainSection, "GainType%d", unipolarGainType);
    //numUnipolarGains=GetPrivateProfileInt(GainSection, "NumGains", 0, fname);
    if (supportsUnipolar)
    {
        outLen = GetPrivateProfileString(Section, "unipolarGains", "", tmpString, 512, fname);
        numUnipolarGains=static_cast<short>(ParseStringToDouble(tmpString,&unipolarGains));
        outLen = GetPrivateProfileString(Section, "unipolarGainsInt", tmpString , tmpString, 512, fname);
        ParseStringToFixed(tmpString,&unipolarGainSettings);
    }
    else
        numUnipolarGains=0;
    
    outLen = GetPrivateProfileString(Section, "bipolarGains", "", tmpString, 512, fname);
    numBipolarGains=static_cast<short>(ParseStringToDouble(tmpString,&bipolarGains));
    outLen = GetPrivateProfileString(Section, "bipolarGainsInt", tmpString , tmpString, 512, fname);
    ParseStringToFixed(tmpString,&bipolarGainSettings);



    return S_OK;

}

DevCaps::DevCaps():
deviceType(-1),
deviceCode(0),
deviceName(NULL),
unipolarGains(NULL),
unipolarGainSettings(NULL),
bipolarGains(NULL),
bipolarGainSettings(NULL),
DIInputIDs(NULL),
SEInputIDs(NULL)
{
}

DevCaps::~DevCaps()
{
    delete [] deviceName;
    
    if (bipolarGains!=unipolarGains)
    {
        delete [] bipolarGains;
        delete [] bipolarGainSettings;
    }
    delete [] unipolarGains;
    delete [] unipolarGainSettings;
    delete [] DIInputIDs;
    delete [] SEInputIDs;

 }

int DevCaps::GetDeviceData(int deviceNum)
{
    int status;	
    
    status = Get_DAQ_Device_Info(deviceNum, 
        ND_DEVICE_TYPE_CODE, 
        &deviceCode);
    DAQ_CHECK(status);      


//   should we use other options like : ND_AI_CHANNEL_COUNT?
    status = Get_DAQ_Device_Info(deviceNum, 
        ND_DATA_XFER_MODE_AI,
        &transferModeAI);
    
    if (status) transferModeAI=0L;

    status = Get_DAQ_Device_Info(deviceNum, 
        ND_DATA_XFER_MODE_AO_GR1,
        &transferModeAO);
    
    if (status) transferModeAO=0L;
        
    status = Get_DAQ_Device_Info(deviceNum,
        ND_DMA_A_LEVEL,
        &dmaLevelA);
    
    if (status) dmaLevelA=0L;
    
    status = Get_DAQ_Device_Info(deviceNum,
        ND_DMA_B_LEVEL,
        &dmaLevelB);
    
    if (status) dmaLevelB=0L;
    
    status = Get_DAQ_Device_Info(deviceNum,
        ND_DMA_C_LEVEL,
        &dmaLevelC);
    
    if (status) dmaLevelC=0L;
    
    
    status = Get_DAQ_Device_Info(deviceNum,
        ND_INTERRUPT_A_LEVEL,
        &irqLevelA);
    
    if (status) irqLevelA=0L;
    
    
    status = Get_DAQ_Device_Info(deviceNum,
        ND_INTERRUPT_B_LEVEL,
        &irqLevelB);
    
    if (status) irqLevelB=0L;
    
    status = GetDriverVersion((char*)drvVersion);
    DAQ_CHECK(status);
        
    return LoadDeviceInfo();
       
}

double round(double x)
{
	// Trivial implementation of integer rounding operation
	// If fractional part of X is greater or equal than .5, then return
	// integer part + 1.  If it's less, then return integer part + 0.
	double intpart;

	if(modf(x,&intpart) >= 0.5)
		return intpart + 1.0;
	else
		return intpart;
}

double DevCaps::FindRate(double rate, short *pTimeBase,unsigned short *pInterval)
{
    if(IsDSA())
    {
        // fix to geck 224629
        // if this is a DSA board, don't do this at all.  We'll use Set_Clock to do this
        // and this will erroneously limit the DSA card to non E-series sampling rates
        // DSA boards essentially support all rates.
        *pTimeBase = 0;
        *pInterval = 0;
        return rate;
    }


	if(!IsESeries())
	{
		// Call DAQ_Rate() to calculate timebase and interval
		DAQ_Rate(rate, 0, pTimeBase, pInterval);
	}
    else
    {
	    // fix to geck 230904 -- superceeds fix to 194165
	    // if this is an eseries board, don't use DAQ_Rate, due to bug in NI-DAQ
        // see http://digital.ni.com/public.nsf/3efedde4322fef19862567740067f3cc/862567530005f09f862569de005c87ea?OpenDocument
        // for more info
        CalculateClosestESeriesTimeBaseAndInterval(rate,pTimeBase,pInterval);
    }

	// Return SampleRate calculated from timebase/interval
    return CalculateSampleRate(*pInterval,*pTimeBase);
}

double DevCaps::CalculateClosestESeriesTimeBaseAndInterval(double RequestedSampleRate, short * ptimebase, unsigned short * psampleInterval)
{
    /** This structure contains information about the various clocks avaliable on the eseries boards */
    struct
    {
        i16 timebase;   /// The clock ID as defined by nidaq
        double period;  /// The period of the clock in seconds: e-3 is ms, e-6 is microsec, e-9 is ns.
    } timebaseList[] = {
                        // These are in ascending speed order intentionally!
        {5,10e-3},    //0 - 100Hz/10ms
        {4,1e-3},     //1 - 1KHz/1ms
        {3,100e-6},   //2 - 10KHz/100 microsecs
        {2,10e-6},   //3 - 100KHz/10 microsecs
        {1,1e-6},     //4 - 1MHz/1 microsec
        {-3,50e-9}}; //5 - 20MHz/50ns
    #define cTimebaseList (sizeof(timebaseList)/sizeof(timebaseList[0]))
        
    double requestedPeriod = 1/RequestedSampleRate; //Convert the requested sample rate into a requested period
    bool foundViableOption = false;  //flag to indicate that we've got at least one solution
    double minimumDistanceFound; //Distance between the best option found and the requested rate
    double bestSampleRate; //The best sample rate we've found so far
    i16 bestTimebase;   // The best timebase we've found so far.
    u16 bestInterval; // The best interval we've found so far.

    // Iterate through the various hardware clocks, from slowest to fastest
    for(int iTimebaseList = 0; iTimebaseList < cTimebaseList; iTimebaseList++)
    {
        /* The requested period divided by the period of the clock under evaluation gives the
        *  interval needed to give that sample rate, using this clock.  Interval is restricted
        *  to an integer, which is why the floor(x+0.5) -- which is the same as rounding it to the
        *  closest integer
        */
        double calculatedInterval = floor((requestedPeriod / timebaseList[iTimebaseList].period) + 0.5);
        // Plus, interval is restricted from 2 to 65535 in hardware
        if(calculatedInterval >= 2.0 && calculatedInterval <= 65535.0)
        {
            // If the interval is viable, calulate what the resulting sample rate would be
            double calculatedSampleRate =  CalculateSampleRate((int)calculatedInterval,timebaseList[iTimebaseList].timebase);

            // Calulate how far between the requested sample rate and the calculated sample rate
            double distance = fabs(RequestedSampleRate - calculatedSampleRate);
            // If this is the best one we've seen (or the only one), record it
            if(!foundViableOption || distance < minimumDistanceFound)
            {
                foundViableOption = true;
                minimumDistanceFound = distance;
                bestTimebase = timebaseList[iTimebaseList].timebase;
                bestInterval = (u16)calculatedInterval;
                bestSampleRate = calculatedSampleRate;
                // If it's a perfect match to the requested sample rate, stop searching
                if(distance == 0)
                    break;
            }
        }
    }
    // If we don't find a viable option, return a safe setup (500 Samples/sec)
    if(!foundViableOption)
    {
        bestTimebase = 4;
        bestInterval = 2;
    }

    // Return the best timebase, interval, and sample rate we found.
    if(psampleInterval != NULL)
        *psampleInterval = bestInterval;
    if(ptimebase != NULL)
        *ptimebase = bestTimebase;
    return bestSampleRate;
}


/*
 * Get the NI-DAQ driver version. The version is stored in the lower
 * two bytes of the value passed in.
 */
int GetDriverVersion(char *version)
{
    ULONG ver;
    
    int	status = Get_NI_DAQ_Version(&ver);
    DAQ_CHECK(status);
    
    ver &= 0xFFFF;		
    
    char tmpBuf[8];		
    sprintf(tmpBuf,"%x",ver);	
    
    sprintf(version, "%c.%c.%c",tmpBuf[0],tmpBuf[1],tmpBuf[2]);

    return 0;
}


double Timebase2ClockResolution(int timeBase)
{
    switch (timeBase)
    {
    case -3:
        return 50e-9;
    case -1:
        return 200e-9;
    case 1:
        return 1e-6;
    case 2:
		return 10e-6;
    case 3:
        return 100e-6;
    case 4:
        return 1e-3;
    case 5:
        return 10e-3;
    }

    return 0.;
}

double CalculateSampleRate(int interval, int timeBase)
{
    // Geck 237676: DO NOT CALCULATE samplerate = 1/(timebase * interval).  Too many of the
    // constants are near points where a missed bit causes problems.  Calculate using
    // samplerate = 1 / interval / timebase -- that's safer.
	return 1.0 / Timebase2ClockResolution(timeBase) / (double)interval;
}

_bstr_t StringToLower(const _bstr_t& in) 
{
    _bstr_t out(in,true);
    LPWSTR p=in;
    LPWSTR pout=out;
    for (unsigned int i=0;i<in.length();i++)
    {
        *pout++=towlower(*p++);
    }
    return out;
}



