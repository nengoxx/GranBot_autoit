#include "lib\functions.au3"

Local $bi_4b = 0

Local $currentEP = 0
Local $onlyBigRaids = True
Local $currentBeast = 0
;~ 0 - Unknown
;~ 1 - Zhuque
;~ 2 - Xuanwu
;~ 3 - Baihu
;~ 4 - Qinglong

;~ Stages:
;~ 0:	check ep & beast(if big beast found go to 2)
;~ 1:	too much ep
;~ 2:	spam refresh until 1ep
;~ 3:	clicked raid(room closed/full or selecting summon)
;~ 4:	summon selected(confirming)
;~ 5:	battle starting or raid full/closed
;~ -1:	TODO:change this
;~ -2:	unknown, restart game/try to locate
Local $raidSnipeStage = -2
Local $lastState = $raidSnipeStage
Local $lastData = ""

#cs
Sleep(5000)
prepareGranblueWindow()
While 1
checkState_4b()
Wend
#ce

;~ BOT FUNCTIONS ~
Func checkState_4b()
   If $raidSnipeStage = 0 Then			;look for big raid or too much ep
	  checkEP_4b()
	  If $use_berries Or $currentEP > 0 Then
		 If $currentEP >= 4 Then
			$raidSnipeStage = 1
		 EndIf
		 If not $onlyBigRaids Then	;TODO: delete this
			If checkBigBeast() Then
			   $raidSnipeStage = 2
			EndIf
		 Else
			If checkBigRaidEp() <> 0 Then
			   $raidSnipeStage = 2
			EndIf
		 EndIf
		 refreshEventRaids(2)			;slow spam
	  EndIf
   ElseIf $raidSnipeStage = 1 Then		;too much ep
	  checkEP_4b()
	  If $use_berries Or $currentEP > 0 Then
		 enterBigRaid()
		 enterRaid()
		 refreshEventRaids(1)			;fast spam
	  EndIf
   ElseIf $raidSnipeStage = 2 Then		;big raid found, w8 for 1 ep
	  checkEP_4b()
	  If not $onlyBigRaids and not checkBigBeast() Then
		 $raidSnipeStage = -2
	  EndIf
	  If $use_berries Or $currentEP > 0 Then
		 enterBigRaid()
		 If checkBigRaidEp() > 3 Then	;check the ep required to spam faster or slower
			refreshEventRaids(1)
		 Else
			refreshEventRaids(0)
		 EndIf
	  EndIf
   ElseIf $raidSnipeStage = 3 Then
	  useBerries($bi_4b)
	  If clickOk($bi_4b) Then					;raid is full or closed, restart
		 _ConsoleWrite('Raid Full or Closed!' & @CRLF)
		 $raidSnipeStage = 0
	  EndIf
	  If selectSummon($bi_4b) Then
		 $raidSnipeStage = 4
	  EndIf
   ElseIf $raidSnipeStage = 4 Then
	  If clickOk($bi_4b) Then					;accept the summon selection
		 _ConsoleWrite('Summon Selected!' & @CRLF)
		 $raidSnipeStage = 5
	  EndIf
   ElseIf $raidSnipeStage = 5 Then
	  If Not prepareBetterCombat($bi_4b) Then	;raid is full or closed, restart(redirect to home window)
		 $raidSnipeStage = -2
	  Else								;either way we gotta return to home
		 _ConsoleWrite('Attack Succeed! Resetting...' & @CRLF)
		 reloadGame($bi_4b)
		 $raidSnipeStage = -2
	  EndIf
   ElseIf $raidSnipeStage = -1 Then
	  ;TODO needed?
   ElseIf $raidSnipeStage = -2 Then		;unknown state(restart game)
	  _ConsoleWriteError('Unexpected State!' & @CRLF)
	  checkVerification()
	  locateIngame_4b()
   EndIf

;~    Nested loops and state error managing
   If $raidSnipeStage = $lastState Then
	  If $raidSnipeStage = 0 Then
		 If Not _onTime_bi(getIdleTime(),$bi_4b) Then
			_ConsoleWriteError('Unknown State in Stage: ' & $raidSnipeStage & @CRLF)
			checkVerification()
			restartGame($bi_4b)				;force a reload of the game and the tweets
			$raidSnipeStage = -2
		 EndIf
	  ElseIf $raidSnipeStage = 2 or $raidSnipeStage = 1 Then
		 If Not _onTime_bi(getIdleTime(),$bi_4b) Then
			_ConsoleWriteError('Unknown State in Stage: ' & $raidSnipeStage & @CRLF)
			checkVerification()
			reloadGame($bi_4b)
			$raidSnipeStage = -2
		 EndIf
	  ElseIf $raidSnipeStage = 3 Then
		 If Not _onTime_bi(getErrorTime(),$bi_4b) Then
			_ConsoleWriteError('Unknown State in Stage: ' & $raidSnipeStage & @CRLF)
			checkVerification()
			reloadGame($bi_4b)
			$raidSnipeStage = -2
		 EndIf
	  Else
		 If Not _onTime_bi(getErrorTime(),$bi_4b) Then
			_ConsoleWriteError('Unknown State in Stage: ' & $raidSnipeStage & @CRLF)
			checkVerification()
			$raidSnipeStage = -2
		 EndIf
	  EndIf
   Else
	  _resetTime_bi($bi_4b)
   EndIf

   $lastState = $raidSnipeStage
EndFunc

Func checkEP_4b()
   Local $epfound = False
   For $i = 0 to Ubound($epsRaid) - 1
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

Func checkBigRaidEp()
   If checkForImage($1epBraid) Or checkForImage($1epBraid2) or checkForImage($1epBraidHalf) or checkForImage($1epBraidHalf2) Then
	  _ConsoleWrite('Big Raid Found With 1 EP Left!' & @CRLF)
	  return 1
   ElseIf checkForImage($3epBraid) or checkForImage($2epBraidHalf) or checkForImage($2epBraidHalf2) Then
	  _ConsoleWrite('Big Raid Found With 3 EP Left!' & @CRLF)
	  return 3
   ElseIf (checkForImage($5epBraid) or checkForImage($3epBraidHalf) or checkForImage($3epRaid) or checkForImage($3epRaid2)) _ ;workaround for half ap scenario
	  and not (checkForImage($1epBraid) Or checkForImage($1epBraid2) or checkForImage($1epBraidHalf) or checkForImage($1epBraidHalf2) _
	  Or checkForImage($3epBraid) or checkForImage($2epBraidHalf) or checkForImage($2epBraidHalf2))Then	;the only one
	  _ConsoleWrite('Big Raid Found With 5 EP Left!' & @CRLF)
	  return 5
   EndIf
return 0
EndFunc

Func enterBigRaid()
   If $currentEP = 5 Then
	  If checkForImage($3epBraid) or checkForImage($2epBraidHalf) or checkForImage($2epBraidHalf2) Then
		 _ConsoleWrite('Joining Raid...' & @CRLF)
		 $xReal = $x - 300			;correct the image into the real button pixel coordinates
		 $yReal = $y - 35
		 $Xaux = 350					;button pixel size(care for the chat bubble)
		 $Yaux = 80
		 randomClick($xReal,$yReal,$Xaux,$Yaux)
		 $raidSnipeStage = 3
		 return 1
	  EndIf
   EndIf
   If checkForImage($1epBraid) Or checkForImage($1epBraid2) or checkForImage($1epBraidHalf) or checkForImage($1epBraidHalf2) Then
	  _ConsoleWrite('Joining Raid...' & @CRLF)
	  $xReal = $x - 300
	  $yReal = $y - 35
	  $Xaux = 350
	  $Yaux = 80
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  $raidSnipeStage = 3
	  return 1
   EndIf
return 0
EndFunc

Func enterRaid()
   If $currentEP = 5 Then
	  If checkForImage($2epRaid) Then
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
;~    checkBeast()
   If checkForImage($1epRaid) Then
	  _ConsoleWrite('Joining Raid...' & @CRLF)
	  $xReal = $x - 320
	  $yReal = $y - 38
	  $Xaux = 350
	  $Yaux = 80
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  $raidSnipeStage = 3
	  return 1
   EndIf
;~    If $currentBeast = 0 Then
;~ 	  $raidSnipeStage = -2
;~ 	  return 0
;~    EndIf
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

Func locateIngame_4b()
   activateGBWindow($bi_4b)
   _resetTime_bi($bi_4b)
   While _onTime_bi(getErrorTime(),$bi_4b)
	  rewardRoom($bi_4b)   							;handle the pending battle reward and regular reward
	  If clickOk($bi_4b) Then
		 ;TODO: handle what happens when an ok button appears in this stage(usually it's the pending battles dialog)
	  EndIf
	  If gotoRaid_4b()	Then
		 $raidSnipeStage = 0
		 _resetTime_bi($bi_4b)
		 Return 1
	  EndIf
   WEnd
   restartGame($bi_4b)
   _resetTime_bi($bi_4b)
   Return 0
EndFunc

Func gotoRaid_4b()
   cancelResumeQuest($bi_4b)
   If checkForImage($quest2) Then
	  _ConsoleWrite('Accesing Quest Menu...' & @CRLF)
	  $xReal = $x - 20
	  $yReal = $y - 40
	  $Xaux = 95
	  $Yaux = 69							;it doesn't matter if we click the raid crew button
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  _resetTime_bi($bi_4b)
   EndIf
   clickQuestsButton($bi_4b)
   clickRaidButton($bi_4b)
   If checkForImage($pending) And Not checkForImage($eventraids) Then	;check also that we aren't in the raids section
	  _ConsoleWrite('Finishing Pending Battle...' & @CRLF)
	  $xReal = $x - 360						;correct the image into the real button pixel coordinates
	  $yReal = $y - 25
	  $Xaux = 380							;button pixel size
	  $Yaux = 80
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  _resetTime_bi($bi_4b)
   EndIf
   If checkForImage($eventraids) Then
	  _ConsoleWrite('Correct Menu!' & @CRLF)
	  Return 1
   EndIf
   Return 0
EndFunc

;#### old functions
#cs
Func checkBeast()
   For $i = 0 to $beastamount - 1
	  If checkForImage($beasts[$i]) Then
		 $currentBeast = $i + 1
;~ 		 _ConsoleWrite('Current Beast: ' & $currentBeast & @CRLF)
		 return 1
	  EndIf
   Next
   $currentBeast = 0
   _ConsoleWriteError('Current Beast Unknown!' & @CRLF)
   return 0
EndFunc
#ce
Func checkBigBeast()
   For $i = 0 to $bbeastamount - 1
	  If checkForImage($bbeasts[$i]) Then
		 _ConsoleWrite('Big Raid Found!' & @CRLF)
		 return 1
	  EndIf
   Next
   return 0
EndFunc