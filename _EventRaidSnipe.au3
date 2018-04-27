#include "lib\functions.au3"

Local $currentEP = 0

;~ Stages:
;~ 0:	check ep and decide the refresh speed(15min if < 3)
;~ 1:	>= 3 ep
;~ 2:	>= 4 (spam refresh until)
;~ 3:	clicked raid(room closed/full or selecting summon)
;~ 4:	summon selected(confirming)
;~ 5:	battle starting or raid full/closed
;~ -1: 	TODO:change this
;~ -2: 	unknown, restart game/try to locate
Local $raidSnipeStage = -2
Local $lastState = $raidSnipeStage
Local $lastData = ""

Sleep(5000)
prepareGranblueWindow()
While 1
checkState()
Wend

;~ BOT FUNCTIONS ~
Func checkState()
   If $raidSnipeStage = 0 Then			;look for big raid or too much ep
	  checkEP()
	  If $use_berries Or $currentEP > 0 Then
		 If $currentEP >= 3 Then
			$raidSnipeStage = 1
		 EndIf
		 If $currentEP >= 4 Then
			$raidSnipeStage = 2
		 EndIf
		 ;refreshEventRaids(2)			;slow spam(not needed as we gotta spam the refresh each 15min)
	  EndIf
   ElseIf $raidSnipeStage = 1 Then
	  checkEP()
	  If $use_berries Or $currentEP > 0 Then
		 enterRaid()
		 refreshEventRaids(1)
	  EndIf
   ElseIf $raidSnipeStage = 2 Then
	  checkEP()
	  If $use_berries Or $currentEP > 0 Then
		 enterRaid()
		 refreshEventRaids(0)
	  EndIf
   ElseIf $raidSnipeStage = 3 Then
	  useBerries()
	  If clickOk() Then					;raid is full or closed, restart
		 _ConsoleWrite('Raid Full or Closed!' & @CRLF)
		 $raidSnipeStage = 0
	  EndIf
	  If selectSummon() Then
		 $raidSnipeStage = 4
	  EndIf
   ElseIf $raidSnipeStage = 4 Then
	  If clickOk() Then					;accept the summon selection
		 _ConsoleWrite('Summon Selected!' & @CRLF)
		 $raidSnipeStage = 5
	  EndIf
   ElseIf $raidSnipeStage = 5 Then
	  If Not prepareBetterCombat() Then	;raid is full or closed, restart(redirect to home window)
		 $raidSnipeStage = -2
	  Else								;either way we gotta return to home
		 _ConsoleWrite('Attack Succeed! Resetting...' & @CRLF)
		 $raidSnipeStage = -2
	  EndIf
   ElseIf $raidSnipeStage = -1 Then
	  ;TODO needed?
   ElseIf $raidSnipeStage = -2 Then		;unknown state(restart game)
	  _ConsoleWriteError('Unexpected State!' & @CRLF)
	  checkVerification()
	  locateIngame()
   EndIf

;~    Nested loops and state error managing
   If $raidSnipeStage = $lastState Then
	  If $raidSnipeStage = 0 Then
		 If Not _onTime(getIdleTime()) Then
			_ConsoleWriteError('Unknown State in Stage: ' & $raidSnipeStage & @CRLF)
			checkVerification()
			restartGame()				;force a reload of the game and the tweets
			$raidSnipeStage = -2
		 EndIf
	  ElseIf $raidSnipeStage = 2 or $raidSnipeStage = 1 Then
		 If Not _onTime(getIdleTime()) Then
			_ConsoleWriteError('Unknown State in Stage: ' & $raidSnipeStage & @CRLF)
			checkVerification()
			reloadGame()
			$raidSnipeStage = -2
		 EndIf
	  ElseIf $raidSnipeStage = 3 Then
		 If Not _onTime(getErrorTime()) Then
			_ConsoleWriteError('Unknown State in Stage: ' & $raidSnipeStage & @CRLF)
			checkVerification()
			reloadGame()
			$raidSnipeStage = -2
		 EndIf
	  Else
		 If Not _onTime(getErrorTime()) Then
			_ConsoleWriteError('Unknown State in Stage: ' & $raidSnipeStage & @CRLF)
			checkVerification()
			$raidSnipeStage = -2
		 EndIf
	  EndIf
   Else
	  _resetTime()
   EndIf

   $lastState = $raidSnipeStage
EndFunc

Func checkEP()
   Local $epfound = False
   For $i = 0 to Ubound($epsRaid) - 1 ;5ep image doesn't exist yet
	  If checkForImage($epsRaid[$i]) Then
		 $currentEP = $i + 1
		 $epfound = True
	  EndIf
   Next
   If $epfound Then
;~ 	  _ConsoleWrite('Got ' & $currentEP & ' EP' & @CRLF)
   Else
	  $currentEP = 0
;~ 	  _ConsoleWrite('Got Zero EP' & @CRLF)
   EndIf
EndFunc

Func checkRaidEp()	;unused
   If checkForImage($2epRaid) and not checkForImage($3epRaid) and not checkForImage($3epRaid2) Then
	  _ConsoleWrite('Raid Found With 2 EP!' & @CRLF)
	  return 2
   ElseIf checkForImage($3epRaid) Then
	  _ConsoleWrite('Big Raid Found With 3 EP Left!' & @CRLF)
	  return 3
   EndIf
return 0
EndFunc

Func enterRaid()
   If checkForImage($3epRaid) or checkForImage($3epRaid2) Then
	  _ConsoleWrite('Joining Raid...' & @CRLF)
	  $xReal = $x - 320
	  $yReal = $y - 38
	  $Xaux = 350
	  $Yaux = 80
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  $raidSnipeStage = 3
	  return 1
   EndIf
   If $currentEP = 5 Then
	  If checkForImage($2epRaid) and not checkForImage($3epRaid) Then
		 _ConsoleWrite('Joining Raid...' & @CRLF)
		 $xReal = $x - 320
		 $yReal = $y - 38
		 $Xaux = 350
		 $Yaux = 80
		 randomClick($xReal,$yReal,$Xaux,$Yaux)
		 $raidSnipeStage = 3
		 return 1
	  EndIf
   EndIf
   return 0
EndFunc

Func refreshEventRaids($t)	;spam fast or slow depending on the input
   If Not _onTime2(getSpamTime($t)) Then
	  If checkForImage($eventraids) Then
		 _ConsoleWrite('Refreshing Event Raids...' & @CRLF)
		 $xReal = $x
		 $yReal = $y
		 $Xaux = 116
		 $Yaux = 42
		 randomClick($xReal,$yReal,$Xaux,$Yaux)
		 _resetTime2()
		 return 1
	  EndIf
   EndIf
   return 0
EndFunc

Func locateIngame()
   activateGBWindow()
   _resetTime()
   While _onTime(getErrorTime())
	  rewardRoom()   							;handle the pending battle reward and regular reward
	  If clickOk() Then
		 ;TODO: handle what happens when an ok button appears in this stage(usually it's the pending battles dialog)
	  EndIf
	  If gotoRaid()	Then
		 $raidSnipeStage = 0
		 _resetTime()
		 Return 1
	  EndIf
   WEnd
   restartGame()
   _resetTime()
   Return 0
EndFunc

Func gotoRaid()
   ;rejoinRaid()								;rejoin an unfinished raid
   cancelResumeQuest()
   If checkForImage($quest2) Then
	  _ConsoleWrite('Accesing Quest Menu...' & @CRLF)
	  $xReal = $x - 20
	  $yReal = $y - 40
	  $Xaux = 95
	  $Yaux = 69							;it doesn't matter if we click the raid crew button
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  _resetTime()
   EndIf
   clickQuestsButton()
   clickRaidButton()
   If checkForImage($pending) And Not checkForImage($eventraids) Then	;check also that we aren't in the raids section
	  _ConsoleWrite('Finishing Pending Battle...' & @CRLF)
	  $xReal = $x - 360						;correct the image into the real button pixel coordinates
	  $yReal = $y - 25
	  $Xaux = 380							;button pixel size
	  $Yaux = 80
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  _resetTime()
   EndIf
   If checkForImage($eventraids) Then
	  ;and not rejoinRaid() Then
	  _ConsoleWrite('Correct Menu!' & @CRLF)
	  Return 1
   EndIf
   Return 0
EndFunc
