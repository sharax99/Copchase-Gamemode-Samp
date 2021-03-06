#if !defined _samp_included
	#error Please include a_samp before timerfix.
#endif

#if !defined TF_TICK_INTERVAL
	#define TF_TICK_INTERVAL  5
#endif

#if !defined TF_MAX_SLOTS
	#define TF_MAX_SLOTS  128
#endif

#if !defined TF_MAX_ARGUMENTS
	#define TF_MAX_ARGUMENTS  32
#endif

#if !defined TF_PERFORMANCE_CHECKS
	#define TF_PERFORMANCE_CHECKS  true
#endif

#if !defined TF_DEBUG
	#define TF_DEBUG  false
#endif

#if !defined TF_LOG_TO_CHAT
	#define TF_LOG_TO_CHAT  false
#endif


#define TF TF_

enum TFe_TIMER {
	boole_bIsUsed,
	     e_iNumArguments,
	     e_axArguments[TF_MAX_ARGUMENTS],
#if TF_DEBUG
	     e_aiArgumentTypes[TF_MAX_ARGUMENTS],
#endif
	     e_iFunctionAddress,
	     e_szFunctionName[32],
	     e_iInterval,
	     e_iNextCall,
	boole_bIsRepeating
};

static stock
	gs_Timers[TF_MAX_SLOTS][TFe_TIMER],
	gs_iCurrentTimer = -1
;

#if !TF_DEBUG
	#define TF_Debug(%1)%0;
#endif

#if !TF_LOG_TO_CHAT
	#define TF_Notice(%1)       print(!Timerfix Notice   %1)
	#define TF_Warning(%1)      print(!Timerfix Warning  %1)
	#define TF_Error(%1)        print(!Timerfix Error    %1)
	
	#define TF_Noticef(%1)      printf(Timerfix Notice   %1)
	#define TF_Warningf(%1)     printf(Timerfix Warning  %1)
	#define TF_Errorf(%1)       printf(Timerfix Error    %1)
	
	#if TF_DEBUG
		#define TF_Debug(%1)    printf(Timerfix Debug    %1)
	#endif
#else
	new
		TFgs_szLogMessageBuffer[512],
	;
	
	#define TF_Notice(%1)       print(!Timerfix Notice   %1), SendClientMessageToAll(0xFFFFFFFF, Timerfix Notice   %1)
	#define TF_Warning(%1)      print(!Timerfix Warning  %1), SendClientMessageToAll(0xEBBD17FF, Timerfix Warning  %1)
	#define TF_Error(%1)        print(!Timerfix Error    %1), SendClientMessageToAll(0xCC0000FF, Timerfix Error    %1)

	#define TF_Noticef(%1)      format(TFgs_szLogMessageBuffer, sizeof(TFgs_szLogMessageBuffer), Timerfix Notice   %1), print(TFgs_szLogMessageBuffer), SendClientMessageToAll(0xDDDDDDFF, TFgs_szLogMessageBuffer)
	#define TF_Warningf(%1)     format(TFgs_szLogMessageBuffer, sizeof(TFgs_szLogMessageBuffer), Timerfix Warning  %1), print(TFgs_szLogMessageBuffer), SendClientMessageToAll(0xEBBD17FF, TFgs_szLogMessageBuffer)
	#define TF_Errorf(%1)       format(TFgs_szLogMessageBuffer, sizeof(TFgs_szLogMessageBuffer), Timerfix Error    %1), print(TFgs_szLogMessageBuffer), SendClientMessageToAll(0xCC0000FF, TFgs_szLogMessageBuffer)
	
	#if TF_DEBUG
		#define TF_Debug(%1)    format(TFgs_szLogMessageBuffer, sizeof(TFgs_szLogMessageBuffer), Timerfix Debug    %1), print(TFgs_szLogMessageBuffer), SendClientMessageToAll(0xFFFFFFFF, TFgs_szLogMessageBuffer)
	#endif
#endif


#define _Timer_C(O@  _Timer_C(SetTimerEx

stock SetTimerHook(const szFunctionName[], iInterval, {bool, _}bRepeating, const szFormat[] = !, {_, PlayerText3D, Text, Text3D, Menu, DB, DBResult, File, Float}...)
{
	static
		bools_bTimerTickTimerStarted = false
	;
	
	if (!s_bTimerTickTimerStarted) {
		SetTimer(!TF_TimerTick, TF_TICK_INTERVAL, true);
		
		s_bTimerTickTimerStarted = true;
	}
	
	new
		iSlot = -1
	;
	
	for (new i = 0; i  sizeof(gs_Timers); i++) {
		if (!gs_Timers[i][e_bIsUsed]) {
			iSlot = i;
			
			break;
		}
	}
	
	if (iSlot == -1) {
		TFError((SetTimerHook) Ran out of timer slots. Increase TF_MAX_SLOTS (current value  #TF_MAX_SLOTS ).);
		
		return -1;
	}
	
	if (!(gs_Timers[iSlot][e_iFunctionAddress] = TFGetPublicFunctionAddress(szFunctionName))) {
		new
			szFunctionNameUnpacked[32]
		;
		
		strunpack(szFunctionNameUnpacked, szFunctionName);
		
		TFErrorf((SetTimerHook) Invalid function (%s)., szFunctionNameUnpacked);
		
		return -1;
	}
	
	new
		#if TF_DEBUG
			boolbFormatIsPacked = ispacked(szFormat),
		#endif
		iNumArgs = max(0, numargs() - 4)
	;
	
	if (iNumArgs != strlen(szFormat)) {
		new
			szFormatUnpacked[128 char]
		;
		
		strunpack(szFormatUnpacked, szFormat);
		
		TFErrorf((SetTimerHook) The number of arguments (%d) doesn't match the number of arguments in the format specifier (%s)., iNumArgs, szFormatUnpacked);
		
		return -1;
	}
	
	gs_Timers[iSlot][e_bIsUsed]       = true;
	gs_Timers[iSlot][e_bIsRepeating]  = bRepeating;
	gs_Timers[iSlot][e_iInterval]     = iInterval;
	gs_Timers[iSlot][e_iNextCall]     = GetTickCount() + iInterval;
	gs_Timers[iSlot][e_iNumArguments] = iNumArgs;
	
	strunpack(gs_Timers[iSlot][e_szFunctionName], szFunctionName, 32);
	
	for (new i = 0; i  iNumArgs; i++) {
		gs_Timers[iSlot][e_axArguments][i] = getarg(4 + i);
		
		#if TF_DEBUG
			gs_Timers[iSlot][e_aiArgumentTypes][i] = bFormatIsPacked  szFormat{i}  szFormat[i];
		#endif
	}
	
	TFDebug((SetTimerHook) Timer created; %d = %s., iSlot, gs_Timers[iSlot][e_szFunctionName]);
	
	return iSlot;
}


  summaryKills the timer that is specified.summary
  param name=iTimerThe ID of the timerparam
  returns'true' if the timer was killed, 'false' otherwisereturns
 
stock KillTimerHook(iTimer)
{
	if (0 = iTimer  sizeof(gs_Timers)) {
		if (gs_Timers[iTimer][e_bIsUsed]) {
			gs_Timers[iTimer][e_bIsUsed] = false;
			
			TFDebug((KillTimerHook) Killed timer %d (%s)., iTimer, gs_Timers[iTimer][e_szFunctionName]);
			
			return true;
		}
	}
	
	TFDebug((KillTimerHook) Failed to kill timer %d; not in use  invalid id., iTimer);
	
	return false;
}


  summarySets the interval of a timer.summary
  param name=timeridThe ID of the timerparam
  param name=intervalThe new intervalparam
 
stock SetTimerInterval(timerid, interval)
{
	if (IsValidTimer(timerid) && interval != gs_Timers[timerid][e_iInterval]) {
		gs_Timers[timerid][e_iInterval] = interval;
		
		TFDebug((SetTimerInterval) Timer interval has been changed for %d (%s)., timerid, gs_Timers[timerid][e_szFunctionName]);
		
		return;
	}
	else if (interval == gs_Timers[timerid][e_iInterval]) {
		TFDebug((SetTimerInterval) Failed to set the same interval timer for %d (%s)., timerid, gs_Timers[timerid][e_szFunctionName]);
		
		return;
	}
	
	TFDebug((SetTimerInterval) Failed to set the interval timer %d (not in use  invalid id), timerid);
}


  summaryGets the interval of a timer.summary
  param name=timeridThe ID of the timerparam
  returns0 for invalid timers, the interval otherwise (in miliseconds)returns
 
stock GetTimerInterval(timerid)
{
	if (IsValidTimer(timerid)) {
		return gs_Timers[timerid][e_iInterval];
	}
	
	TFDebug((GetTimerInterval) Failed to get the interval timer %d (not in use  invalid id), timerid);
	
	return 0;
}


  summaryChecks if a timer is still alive.summary
  param name=timeridThe ID of the timerparam
  returns'true' if the timer is valid, 'false' otherwisereturns
 
stock boolIsValidTimer(timerid)
{
	if (0 = timerid  sizeof(gs_Timers) && gs_Timers[timerid][e_bIsUsed]) {
		return true;
	}
	return false;
}

forward TFTimerTick();
public TFTimerTick()
{
	new
		iTick,
		iFunc,
		iArg,
		i, j
	;
	
	if (gs_iCurrentTimer != -1) {
		TFErrorf((TFTimerTick) The function %s didn't properly execute, some timers might not have been called., gs_Timers[gs_iCurrentTimer][e_szFunctionName]);
		
		gs_iCurrentTimer = -1;
	}
	
	for (i = 0; i  sizeof(gs_Timers); i++) {
		if (!gs_Timers[i][e_bIsUsed]) {
			continue;
		}
		
		if ((iTick = GetTickCount()) = gs_Timers[i][e_iNextCall]) {
			iFunc = gs_Timers[i][e_iFunctionAddress];
			
			 This is done before and after execution, in case execution fails
			if (gs_Timers[i][e_bIsRepeating]) {
				gs_Timers[i][e_iNextCall] = iTick + gs_Timers[i][e_iInterval] - 1;
			}
			
			#if TF_DEBUG
				TFPrintFunctionCall(i);
			#endif
			
			j = gs_Timers[i][e_iNumArguments];
			
			
			gs_iCurrentTimer = i;
			
			 Push the arguments
			while (--j = 0) {
				#emit CONST.alt   TF_gs_Timers
				#emit LOAD.S.pri  i
				#emit IDXADDR
				#emit MOVE.alt
				#emit LOAD.I
				#emit ADD
				#emit ADD.C       8  e_axArguments  4
				#emit MOVE.alt
				#emit LOAD.S.pri  j
				#emit IDXADDR
				#emit LOAD.I
				#emit PUSH.pri
			}
			
			 Push the number of arguments
			iArg = gs_Timers[i][e_iNumArguments]  4;
			
			#emit PUSH.S      iArg

			 Push the return address
			#emit LCTRL		  6
			#emit ADD.C		  28
			#emit PUSH.pri

			 Call the function
			#emit LOAD.S.pri  iFunc
			#emit SCTRL		  6
			
			#if TF_PERFORMANCE_CHECKS
				if (GetTickCount() - iTick  10) {
					TFWarningf((TFTimerTick) High CPU usage in timer %s, took %i ms to execute! This will affect other timers., gs_Timers[i][e_szFunctionName], GetTickCount() - iTick);
				}
			#endif
			
			if (gs_Timers[i][e_bIsRepeating]) {
				gs_Timers[i][e_iNextCall] = GetTickCount() + gs_Timers[i][e_iInterval] - 1;
			}
			else {
				gs_Timers[i][e_bIsUsed] = false;
				
				TFDebug((TFTimerTick) Timer %d (%s) finished., i, gs_Timers[i][e_szFunctionName]);
			}
			
			gs_iCurrentTimer = -1;
		}
	}
}

stock TFGetPublicFunctionAddress(const szName[])
{
	new
		iIndex,
		iTemp
	;
	
	if (-1 != (iIndex = funcidx(szName))) {
		 Load the offset to DAT from the prefix
		#emit LCTRL		   1
		
		 Invert it so we have the offset to the prefix from DAT
		#emit NEG
		
		 Copy it to alt for use later
		#emit MOVE.alt
		
		 Add 32 to jump to the offset containing the public function's table
		#emit ADD.C		   32
		
		 Read the value there; must be done using LREF because
		 it's outside of the DAT section
		#emit STOR.S.pri   iTemp
		#emit LREF.S.pri   iTemp
		
		 Add the value we just loaded to the prefix (that we stored in alt)
		#emit ADD
		
		 Add index  8 (each entry contains 2 cells - a pointer to the function's name
		 and a pointer to the function itself, relative to COD).
		#emit LOAD.S.alt   iIndex
		#emit SHL.C.alt	   3
		
		 Add that to the offset
		#emit ADD
		
		 Now get the address it's pointing to. This seems to only work
		 using LREF (as opposed to LOAD.I, for example).
		#emit STOR.S.pri   iTemp
		#emit LREF.S.pri   iTemp
		
		 Restore the stack
		#emit STACK		   8
		
		 Return the address
		#emit RETN
	}
	
	return 0;
}

#if TF_DEBUG
	stock TFPrintFunctionCall(i)
	{
		format(TFgs_szLogMessageBuffer, sizeof(TFgs_szLogMessageBuffer), Timerfix Debug (TFGetPublicFunctionAddress) Calling %s(, gs_Timers[i][e_szFunctionName]);
		
		for (new j = 0; j  gs_Timers[i][e_iNumArguments]; j++) {
			if (j) {
				strcat(TFgs_szLogMessageBuffer, , );
			}
			
			switch (gs_Timers[i][e_aiArgumentTypes][j]) {
				case 'f', 'F' {
					format(TFgs_szLogMessageBuffer, sizeof(TFgs_szLogMessageBuffer), %s%.2f, TFgs_szLogMessageBuffer, gs_Timers[i][e_axArguments][j]);
				}
				
				default {
					format(TFgs_szLogMessageBuffer, sizeof(TFgs_szLogMessageBuffer), %s%d, TFgs_szLogMessageBuffer, gs_Timers[i][e_axArguments][j]);
				}
			}
		}
		
		strcat(TFgs_szLogMessageBuffer, ));
		
		print(TFgs_szLogMessageBuffer);
	}
#endif

 This is done lastly because the fixed function isn't needed within Timerfix
#define SetTimer SetTimerHook
#define SetTimerEx SetTimerHook
#define KillTimer KillTimerHook