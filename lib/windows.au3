#include-once

Global $granblueWnd = null
Global $tweetWnd = null
Global $raidFinder = 0 		; 1=raid finder, 2=tweetdeck

;~ 'x' has to be 469 and 'y' 742 for 1366x768 screens
Local $workingX = 469 		;352
Local $workingY = 742		;609

Local $max_granblue_windows = 2
Global $granblue_windows[$max_granblue_windows][3]	;[[HWND,xTop,yTop],...] array of game windows TODO use those coords to speed up the bot
Global $gameInstances = 0

Global $multiraid_prio = 0
Global $tweet_prio[2][2]		;[[x0,y0],...]	raid priority system(only two at a time)  0=less 1=most priority
Local $prioRaid_offset = 300	;offset pixels for the raid title in raidfinder webpage

;~~ setup windows
Func getWindows()
   ConsoleWrite('- Windows' & @CRLF)
   Local $window_elem = 0
   Local $winpos_aux = null
   Local $aWindows = WinList()
   For $i = 0 To UBound($aWindows)-1
	  If $aWindows[$i][0] = "Granblue Fantasy - Google Chrome" and $window_elem <= $max_granblue_windows Then
		 ;ConsoleWrite('Found Instance! ' & @CRLF)
		 $granblue_windows[$window_elem][0] = $aWindows[$i][1]
		 $winpos_aux = WinGetPos($aWindows[$i][1])
		 $granblue_windows[$window_elem][1] = $winpos_aux[0]
		 $granblue_windows[$window_elem][2] = $winpos_aux[1]
		 $window_elem = $window_elem + 1
	  EndIf
   Next
   $gameInstances = $window_elem
   ConsoleWrite('Game Instances: ' & $window_elem & @CRLF)
   #cs
   For $i = 0 To UBound($granblue_windows)-1
	  If $granblue_windows[$i][0] <> "" Then
		 ConsoleWrite('Game Instance ' & $i & ': ' & $granblue_windows[$i][0] & ' x: ' & $granblue_windows[$i][1] & ' y: ' & $granblue_windows[$i][2] & @CRLF)
	  EndIf
   Next
   #ce
   prepareAllWindows()
   ;$granblueWnd = $granblue_windows[0][0]	;acess the element 0(HWND) of the array in pos 0
   getTweetWindows()
EndFunc

Func getTweetWindows()
   $tweetWnd = WinWait("[TITLE:Granblue Raid Finder - Google Chrome; CLASS:Chrome_WidgetWin_1]", "", 1)	;raidfinder window
   $raidFinder = 1
   If $tweetWnd == null  or $tweetWnd == 0 Then
	  $tweetWnd = WinWait("[TITLE:TweetDeck - Pale Moon; CLASS:MozillaWindowClass]", "", 1)	;tweetdeck window
	  $raidFinder = 2
   EndIf
EndFunc

Func prepareTweetPrio()
   Local $highPrioFound = 0
   If $multiraid_prio == 1 Then
	  For $i = 0 to Ubound($lowPrio_raids) - 1
		 If checkForImage($lowPrio_raids[$i]) Then	;less priority raid
			$tweet_prio[0][0]= $x
			$tweet_prio[0][1]= $y
			ExitLoop
		 EndIf
	  Next
	  For $i = 0 to Ubound($highPrio_raids) - 1
		 If checkForImage($highPrio_raids[$i]) Then	;most priority raid
			$tweet_prio[1][0]= $x
			$tweet_prio[1][1]= $y
			$highPrioFound = 1
			ExitLoop
		 EndIf
	  Next
   EndIf
   If $highPrioFound == 0 Then	;if the raid is not found ignore priority
	  $multiraid_prio = 0
   EndIf
EndFunc

;~ Window Management
Func activateGBWindow($bot_instance=0)
   If Not WinActive($granblue_windows[$bot_instance][0]) Then
	  WinActivate($granblue_windows[$bot_instance][0])
   EndIf
EndFunc

Func REactivateGBWindow($bot_instance=0)
   WinSetState($granblue_windows[$bot_instance][0],"",@SW_MINIMIZE)
   Sleep(100)
   WinSetState($granblue_windows[$bot_instance][0],"",@SW_RESTORE)
   WinActivate($granblue_windows[$bot_instance][0])
   Sleep(5000) ;TODO it takes too long to reload after restoring
EndFunc

Func activateGBWindowInstances($bot_instance=0)
   For $i = 0 To UBound($granblue_windows)-1
	  If WinActive($granblue_windows[$i][0]) Then
		 Return 1
	  EndIf
   Next
   WinActivate($granblue_windows[$bot_instance][0])
   Return 0
EndFunc

Func activateTweetWindow()
   If Not WinActive($tweetWnd) Then
	  WinActivate($tweetWnd)
   EndIf
EndFunc

Func prepareGranblueWindowAbsolute()		;resize if x or y are wrong
   Local $aPos = WinGetPos($granblueWnd)
   If $aPos[2] <> $workingX Or $aPos[3] <> $workingY Then
	  _ConsoleWrite('Resizing Window...' & @CRLF)
	  WinMove($granblueWnd, "", 0, 0, $workingX, $workingY)
   EndIf
;~    WinActivate($granblueWnd)
EndFunc

Func prepareGranblueWindow()				;resize only if X is wrong
   Local $aPos = WinGetPos($granblueWnd)
   If $aPos[2] <> $workingX Then
	  _ConsoleWrite('Resizing Window...' & @CRLF)
	  WinMove($granblueWnd, "", 0, 0, $workingX, $workingY)
   EndIf
;~    WinActivate($granblueWnd)
EndFunc

Func prepareAllWindows()				;resize only if X is wrong
   For $i = 0 To UBound($granblue_windows)-1
	  If $granblue_windows[$i][0] <> "" Then
		 WinActivate($granblue_windows[$i][0])
		 Local $aPos = WinGetPos($granblue_windows[$i][0])
		 ;ConsoleWrite($i & ' Window ' & $granblue_windows[$i][0] & ' ' & $aPos[2] & @CRLF)
		 If $aPos[0] <> $i*$workingX or $aPos[2] <> $workingX Then
			ConsoleWrite('Resizing Window ' & $i & '...' & @CRLF)
			WinMove($granblue_windows[$i][0], "", $i*$workingX, 0, $workingX, $workingY)
		 EndIf
	  EndIf
   Next
EndFunc

;~ ImageSearch Functions
#cs
# - Generic image search
# If bot_instance is not provided it will search the whole area,
# else if provided will search the game window assigned to the instance
#ce
Func checkForImage($img,$bot_instance=10)
   Local $search = 0
   If $bot_instance == 10 Then
	  $search = _ImageSearch($img, 0, $x, $y, 5)
   Else
	  activateGBWindowInstances($bot_instance)	;only activate if both inactive	;activateGBWindow($bot_instance)
	  Local $aPos = WinGetPos($granblue_windows[$bot_instance][0])
	  ;ConsoleWrite('Searching For Instance: ' & $bot_instance & @CRLF)
	  ;ConsoleWrite('Coords: ' &$aPos[0]&$aPos[1]&$aPos[2]&$aPos[3]& @CRLF)
	  $search = _ImageSearchArea($img,0,$aPos[0],$aPos[1],$aPos[0]+$aPos[2],$aPos[1]+$aPos[3],$x,$y,5)
	  ;_ImageSearchArea($findImage,$resultPosition,0,0,@DesktopWidth,@DesktopHeight,$x,$y,$tolerance,$HBMP)
   EndIf
   Return $search
EndFunc

;~ redundant image search to get through lag
Func checkForImageT($img,$time,$bot_instance=10)
   Local $search = 0
   Local $hTimer = TimerInit() 		; Begin the timer and store the handle in a variable.
   If $bot_instance == 10 Then
	  While $search = 0 And TimerDiff($hTimer) <= $time
		 $search = _ImageSearch($img, 0, $x, $y, 5)
	  WEnd
   Else
	  activateGBWindowInstances($bot_instance)	;activateGBWindow($bot_instance)
	  Local $aPos = WinGetPos($granblue_windows[$bot_instance][0])
	  While $search = 0 And TimerDiff($hTimer) <= $time
		 $search = _ImageSearchArea($img,0,$aPos[0],$aPos[1],$aPos[0]+$aPos[2],$aPos[1]+$aPos[3],$x,$y,5)
	  WEnd
   EndIf
   Return $search
EndFunc

Func checkForImageRaidFinderPrio($prioRaid=0)
   Local $search = 0
   ;x0,y0,x0+offset,bottom of the display
   $search = _ImageSearchArea($img,0,$tweet_prio[$prioRaid][0],$tweet_prio[$prioRaid][1],$tweet_prio[$prioRaid][0]+$prioRaid_offset,@DesktopHeight,$x,$y,5)
   Return $search
EndFunc