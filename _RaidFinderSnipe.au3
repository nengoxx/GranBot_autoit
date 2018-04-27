#include "lib\functions.au3"

;bot instance for window management
Local $bi_rfs = 0

;~ Stages:
;~ 0:	waiting for tweet
;~ 1:	tweet found
;~ 2:	id copied
;~ 3:	id pasted(room closed/full or selecting summon)
;~ 4:	summon selected(confirming)
;~ 5:	battle starting or raid full/closed
;~ -1: 	feed reload needed
;~ -2: 	unknown, restart game/try to locate
Global $raidSnipeStage = -2
Local $lastState_rfs = $raidSnipeStage
Local $lastData = ""

;Sleep(5000)
;prepareGranblueWindow()
;While 1
;checkState_rfs()
;Wend

;~ BOT FUNCTIONS ~
Func checkState_rfs()
   If $raidSnipeStage = 0 Then
	  If $use_berries Or checkEP() Then
		 waitForTweet()
	  EndIf
   ElseIf $raidSnipeStage = 1 Then
	  ;copyID() TODO: delete this state
   ElseIf $raidSnipeStage = 2 Then
	  pasteID()
   ElseIf $raidSnipeStage = 3 Then
	  useBerries($bi_rfs)
	  If clickOk($bi_rfs) and not checkForImage($used,$bi_rfs) Then				;raid is full or closed, restart TODO: change the way the bot checks if raid is closed after using berries
		 _ConsoleWrite('Raid Full or Closed!' & @CRLF)
		 $raidSnipeStage = 0
	  EndIf
	  If selectSummon($bi_rfs) Then
		 $raidSnipeStage = 4
	  EndIf
   ElseIf $raidSnipeStage = 4 Then
	  If clickOk($bi_rfs) Then					;accept the summon selection
		 _ConsoleWrite('Summon Selected!' & @CRLF)
		 $raidSnipeStage = 5
	  EndIf
   ElseIf $raidSnipeStage = 5 Then
	  If Not prepareBetterCombat($bi_rfs) Then		;raid is full or closed, restart(redirect to home window)
		 $raidSnipeStage = -2
	  Else								;either way we gotta return to home
		 _ConsoleWrite('Attack Succeed! Resetting...' & @CRLF)
		 reloadGame($bi_rfs)
		 $raidSnipeStage = -2
	  EndIf
   ElseIf $raidSnipeStage = -1 Then		;feed reaload needed
	  restartTweets()
	  checkVerification()
   ElseIf $raidSnipeStage = -2 Then		;unknown state(restart game)
	  _ConsoleWriteError('Unexpected State!' & @CRLF)
	  checkVerification()
	  locateIngame_rfs()
   ElseIf $raidSnipeStage = -3 Then		;unknown state(restart game)
	  _ConsoleWriteError('Telegram Restart' & @CRLF)
	  reloadGame($bi_rfs)
	  $raidSnipeStage = -2
   EndIf

;~    Nested loops and state error managing
   If $raidSnipeStage = $lastState_rfs Then
	  If $raidSnipeStage = 0 Then
		 If Not _onTime_bi(getIdleTime(),$bi_rfs) Then
			_ConsoleWriteError('Unknown State in Stage: ' & $raidSnipeStage & @CRLF)
			checkVerification()
			restartTweets()
			restartGame($bi_rfs)				;force a reload of the game and the tweets
			$raidSnipeStage = -2
		 EndIf
	  ElseIf $raidSnipeStage = 3 Then
		 If Not _onTime_bi(getErrorTime(),$bi_rfs) Then
			_ConsoleWriteError('Unknown State in Stage: ' & $raidSnipeStage & @CRLF)
			checkVerification()
			reloadGame($bi_rfs)
			$raidSnipeStage = -2
		 EndIf
	  Else
		 If Not _onTime_bi(getErrorTime(),$bi_rfs) Then
			_ConsoleWriteError('Unknown State in Stage: ' & $raidSnipeStage & @CRLF)
			checkVerification()
			$raidSnipeStage = -2
		 EndIf
	  EndIf
   Else
	  _resetTime_bi($bi_rfs)
   EndIf

   $lastState_rfs = $raidSnipeStage
EndFunc

Func checkEP()
   #cs
   If checkForImage($epsRaid[$neededEP-1],$bi_rfs) or checkForImage($epsRaid[5],$bi_rfs) Then
	  _ConsoleWrite('Enough EP!' & @CRLF)
	  Return 1
   EndIf
   Return 0
   #ce
   For $i = $neededEP-1 to Ubound($epsRaid) - 1
	  If checkForImage($epsRaid[$i],$bi_rfs) Then
		 _ConsoleWrite('Enough EP!' & @CRLF)
		 Return 1
	  EndIf
   Next
   Return 0
EndFunc


;~ Web Functions
Func restartTweets()
   activateTweetWindow()
   _ConsoleWrite('Reloading Tweets...' & @CRLF)
   ControlSend($tweetWnd, "", "", "{F5}")
   If $raidSnipeStage = -1 Then
	  $raidSnipeStage = 0
   Endif
EndFunc

Func waitForTweet()	;wait for tweet & copy ID
   If checkForImage($now_raidfinder2) or checkForImage($now_raidfinder) or checkForImage($now_raidfinder4) or checkForImage($now_raidfinder3) or checkForImage($gbf_raiderID) or checkForImage($gbf_raiderID75) Then				;check for ID, let it time to load the page
	  If checkForImage($tweet_extension) Then
		 Sleep(1000)
	  EndIf
	  _ConsoleWrite('Raid ID Found!' & @CRLF)
	  MouseClick("left", $x, $y, 1)			;click into the ID to copy it
	  ControlSend($tweetWnd, "", "", "^c")
	  If $lastData <> ClipGet() Then
		 ControlSend($tweetWnd, "", "", "^c")									;retry again
	  EndIf
	  _ConsoleWrite('Raid ID Copied to Clipboard!' & @CRLF)
	  $raidSnipeStage = 2
	  $lastData = ClipGet()
	  return
   EndIf
   $raidSnipeStage = 0
EndFunc

;~ Ingame Functions(use randomized clicks)
Func pasteID()
   activateGBWindow($bi_rfs)
   Sleep(50)
   ControlSend($granblue_windows[$bi_rfs][0], "", "", "{TAB}")
   ControlSend($granblue_windows[$bi_rfs][0], "", "", "^v")
   _ConsoleWrite('Attempting to Join Raid...' & @CRLF)
   If checkForImage($raid_join,$bi_rfs) or checkForImage($raid_joinstuck,$bi_rfs) Then
	  $Xaux = 114
	  $Yaux = 25
	  randomClick($x,$y,$Xaux,$Yaux)
	  $raidSnipeStage = 3
	  restartTweets()
	  return
   Else
	  $raidSnipeStage = -2
	  return
   EndIf
EndFunc

Func locateIngame_rfs()
   activateGBWindow($bi_rfs)
   _resetTime_bi($bi_rfs)
   While _onTime_bi(getErrorTime(),$bi_rfs)
	  rewardRoom($bi_rfs)   							;handle the pending battle reward and regular reward
	  If clickOk($bi_rfs) Then
		 ;TODO: handle what happens when an ok button appears in this stage(usually it's the pending battles dialog)
	  EndIf
	  If gotoRaid()	Then
		 $raidSnipeStage = 0	;-1
		 _resetTime_bi($bi_rfs)
		 Return 1
	  EndIf
   WEnd
   _ConsoleWriteError('State Not Located Ingame' & @CRLF)
   restartGame($bi_rfs)
   _resetTime_bi($bi_rfs)
   Return 0
EndFunc

Func gotoRaid()
;~    rewardRoom()   							;handle the pending battle reward and regular reward
;~    If clickOk() Then
;~ 	  ;TODO: handle what happens when an ok button appears in this stage(usually it's the pending battles dialog)
;~    EndIf
   cancelResumeQuest($bi_rfs)
   If checkForImage($quest2,$bi_rfs) Then
	  _ConsoleWrite('Accesing Quest Menu...' & @CRLF)
	  $xReal = $x - 20
	  $yReal = $y - 40
	  $Xaux = 95
	  $Yaux = 69							;it doesn't matter if we click the raid crew button
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  _resetTime_bi($bi_rfs)
   EndIf
   clickQuestsButton($bi_rfs)
   If checkForImage($enterid,$bi_rfs) Then
	  _ConsoleWrite('Accesing ID Form...' & @CRLF)
	  $xReal = $x
	  $yReal = $y
	  $Xaux = 81
	  $Yaux = 22
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  _resetTime_bi($bi_rfs)
   EndIf
   clickRaidButton($bi_rfs)
;~    If checkForImage($raid) Then
;~ 	  _ConsoleWrite('Accesing Raid Menu...' & @CRLF)
;~ 	  $xReal = $x + 55
;~ 	  $yReal = $y
;~ 	  $Xaux = 110
;~ 	  $Yaux = 28
;~ 	  randomClick($xReal,$yReal,$Xaux,$Yaux)
;~ 	  _resetTime_bi($bi_rfs)
;~    EndIf
   If checkForImage($pending,$bi_rfs) And Not checkForImage($eventraids,$bi_rfs) Then
	  _ConsoleWrite('Finishing Pending Battle...' & @CRLF)
	  $xReal = $x - 360						;correct the image into the real button pixel coordinates
	  $yReal = $y - 25
	  $Xaux = 380							;button pixel size
	  $Yaux = 80
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  _resetTime_bi($bi_rfs)
   EndIf
   If checkForImage($destination,$bi_rfs) Then
	  _ConsoleWrite('Correct Menu!' & @CRLF)
	  Return 1
   EndIf
   Return 0
EndFunc
