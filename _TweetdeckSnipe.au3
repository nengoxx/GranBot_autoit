#include "lib\functions.au3"

#cs
Local $neededEP = Int(IniRead("config.ini", "raid", "magna_ep", "3"))
ConsoleWrite('- Raid ' & @CRLF)
ConsoleWrite('Minimum EP for Magnas: ' & $neededEP & @CRLF)
#ce

;~ Stages:
;~ 0:	waiting for tweet
;~ 1:	tweet found
;~ 2:	id copied
;~ 3:	id pasted(room closed/full or selecting summon)
;~ 4:	summon selected(confirming)
;~ 5:	battle starting or raid full/closed
;~ -1:	feed reload needed
;~ -2:	unknown, restart game/try to locate
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
   If $raidSnipeStage = 0 Then
	  If $use_berries Or checkEP() Then
		 waitForTweet()
	  EndIf
   ElseIf $raidSnipeStage = 1 Then
	  copyID()
   ElseIf $raidSnipeStage = 2 Then
	  pasteID()
   ElseIf $raidSnipeStage = 3 Then
	  useBerries()
	  If clickOk() Then				;raid is full or closed, restart
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
	  If Not prepareBetterCombat() Then		;raid is full or closed, restart(redirect to home window)
		 $raidSnipeStage = -2
	  Else								;either way we gotta return to home
		 _ConsoleWrite('Attack Succeed! Resetting...' & @CRLF)
		 reloadGame()
		 $raidSnipeStage = -2
	  EndIf
   ElseIf $raidSnipeStage = -1 Then		;feed reaload needed
	  restartTweets()
   ElseIf $raidSnipeStage = -2 Then		;unknown state(restart game)
	  _ConsoleWriteError('Unexpected State!' & @CRLF)
	  ControlSend($tweetWnd, "", "", "{F5}")
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
   If checkForImage($epsRaid[$neededEP-1]) or checkForImage($epsRaid[5]) Then
	  _ConsoleWrite('Enough EP!' & @CRLF)
	  Return 1
   EndIf
   Return 0
EndFunc


;~ Web Functions
Func restartTweets()
;~    activateTweetWindow()
   _ConsoleWrite('Reloading Tweets...' & @CRLF)
   For $i = 0 to 10							;10 times to force page reload
	  ControlSend($tweetWnd, "", "", "{BACKSPACE}")
   Next
;~    Sleep(2000)
   If checkForImage($check_web) or checkForImage($check_web2) Then		;recheck if it's in a bad state
	  ControlSend($tweetWnd, "", "", "{F5}")
   EndIf
   ControlSend($tweetWnd, "", "", "1")
   If $raidSnipeStage = -1 Then
	  $raidSnipeStage = 0
   Endif
EndFunc

Func waitForTweet()
   Local $tweet_clickLocation = 10
   activateTweetWindow()
   ControlSend($tweetWnd, "", "", "1")
;~    _ConsoleWrite('Checking Tweets...' & @CRLF)
   If checkForImage($tweet_back) Or checkForImage($check_web) Then
	  $raidSnipeStage = -1
	  Return
   EndIf
   If checkForImage($now_tweet2) Or checkForImage($now_tweet) Or checkForImage($recent_tweet2) Or checkForImage($recent_tweet) Then
	  _ConsoleWrite('New Tweet Found!' & @CRLF)
	  MouseClick("left", $x+$tweet_clickLocation, $y+$tweet_clickLocation, 1)	;click into the tweet
	  $raidSnipeStage = 1
	  Return
   EndIf
   $raidSnipeStage = 0
EndFunc


Func copyID()
   Local $id_XclickOffset = 30
   Local $id_YclickOffset = 5
   If checkForImage($tweet_id) Or checkForImage($tweet_id2) Then				;check for ID, let it time to load the page
	  _ConsoleWrite('Raid ID Found!' & @CRLF)
	  MouseMove($x+$id_XclickOffset, $y+$id_YclickOffset)
	  Sleep(50)
	  MouseClick("left", $x+$id_XclickOffset, $y+$id_YclickOffset, 2)			;click into the ID to copy it
	  Sleep(50)
	  ControlSend($tweetWnd, "", "", "^c")
	  If $lastData <> ClipGet() Then
		 ControlSend($tweetWnd, "", "", "^c")									;retry again
	  EndIf
	  _ConsoleWrite('Raid ID Copied to Clipboard!' & @CRLF)
	  $raidSnipeStage = 2
	  $lastData = ClipGet()
	  return
   EndIf
   $raidSnipeStage = 1
EndFunc

;~ Ingame Functions(use randomized clicks)
Func pasteID()
   activateGBWindow()
   Sleep(50)
   ControlSend($granblueWnd, "", "", "{TAB}")
   ControlSend($granblueWnd, "", "", "^v")
   _ConsoleWrite('Attempting to Join Raid...' & @CRLF)
   If checkForImage($raid_join) Then
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

Func locateIngame()
   activateGBWindow()
   _resetTime()
   While _onTime(getErrorTime())
	  rewardRoom()   							;handle the pending battle reward and regular reward
	  If clickOk() Then
		 ;TODO: handle what happens when an ok button appears in this stage(usually it's the pending battles dialog)
	  EndIf
	  If gotoRaid()	Then
		 $raidSnipeStage = 0	;-1
		 _resetTime()
		 Return 1
	  EndIf
   WEnd
   restartGame()
   _resetTime()
   Return 0
EndFunc

Func gotoRaid()
;~    rewardRoom()   							;handle the pending battle reward and regular reward
;~    If clickOk() Then
;~ 	  ;TODO: handle what happens when an ok button appears in this stage(usually it's the pending battles dialog)
;~    EndIf
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
   If checkForImage($enterid) Then
	  _ConsoleWrite('Accesing ID Form...' & @CRLF)
	  $xReal = $x
	  $yReal = $y
	  $Xaux = 81
	  $Yaux = 22
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  _resetTime()
   EndIf
   clickRaidButton()
;~    If checkForImage($raid) Then
;~ 	  _ConsoleWrite('Accesing Raid Menu...' & @CRLF)
;~ 	  $xReal = $x + 55
;~ 	  $yReal = $y
;~ 	  $Xaux = 110
;~ 	  $Yaux = 28
;~ 	  randomClick($xReal,$yReal,$Xaux,$Yaux)
;~ 	  _resetTime()
;~    EndIf
   If checkForImage($pending) And Not checkForImage($eventraids) Then
	  _ConsoleWrite('Finishing Pending Battle...' & @CRLF)
	  $xReal = $x - 360						;correct the image into the real button pixel coordinates
	  $yReal = $y - 25
	  $Xaux = 380							;button pixel size
	  $Yaux = 80
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  _resetTime()
   EndIf
   If checkForImage($destination) Then
	  _ConsoleWrite('Correct Menu!' & @CRLF)
	  Return 1
   EndIf
   Return 0
EndFunc
