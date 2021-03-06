#include "lib\functions.au3"

Local $bi_ah = 1
Global $farmQuestType = 3 	; 0-ah 1-fav 2-dailyShowdown 3-GW
Local $NM90 = 0

;~ Stages:
;~ 0:	waiting for tweet
;~ 1:	tweet found
;~ 2:	id copied
;~ 3:	id pasted(room closed/full or selecting summon)
;~ 4:	summon selected(confirming)
;~ 5:	battle starting or raid full/closed
;~ -1: 	feed reload needed
;~ -2: 	unknown, restart game/try to locate
Global $angelHaloStage = -2
Local $lastState_ah = $angelHaloStage

;Sleep(5000)
;prepareGranblueWindow($bi_ah)
;While 1
;checkState_ah()
;Wend

;~ BOT FUNCTIONS ~
Func checkState_ah()
   If $angelHaloStage = 0 Then
	  If $use_elixirs Or checkAP() Then
		 If $farmQuestType = 0 Then			;choose which kind of quest we enter
			enterHalo()
		 ElseIf $farmQuestType = 1 Then
			enterFavQuest()
		 ElseIf $farmQuestType = 2 Then
			enterDailyShowdownQuest()
		 ElseIf $farmQuestType = 3 Then	;GW
			enterGWQuest()
		 EndIf
	  EndIf
   ElseIf $angelHaloStage = 1 Then
	  ;TODO
   ElseIf $angelHaloStage = 2 Then
	  ;TODO
   ElseIf $angelHaloStage = 3 Then
	  useElixirs($bi_ah)
	  If checkForImage($pendingdialog,$bi_ah) Then
		 _ConsoleWrite('Pending Dialog While Trying to Join!' & @CRLF)
		 $angelHaloStage = -2
	  Else
		 If clickOk($bi_ah) Then				;raid is full or closed, restart
			_ConsoleWrite('Raid Full or Closed!' & @CRLF)
			;$angelHaloStage = 0
		 EndIf
	  EndIf
	  If selectSummon($bi_ah) Then
		 $angelHaloStage = 4
	  EndIf
	  If checkForImage($attack,$bi_ah) Then
		 $angelHaloStage = 5
	  EndIf
   ElseIf $angelHaloStage = 4 Then
	  If clickOk($bi_ah) Then					;accept the summon selection
		 _ConsoleWrite('Summon Selected!' & @CRLF)
		 $angelHaloStage = 5
	  EndIf
   ElseIf $angelHaloStage = 5 Then
	  If $farmQuestType <> 3 and Not prepareHaloCombat($bi_ah) Then		;raid is full or closed, restart(redirect to home window); ONLY when not GW
		 $angelHaloStage = -2
	  ElseIf $farmQuestType = 3 and Not prepareBetterCombat($bi_ah) Then 		;GW
		 $angelHaloStage = -2
	  Else		 ;either way we gotta return to home
		 _ConsoleWrite('Attack Succeed! Resetting...' & @CRLF)
		 ;reloadGame($bi_ah)
		 $angelHaloStage = -2
	  EndIf
   ElseIf $angelHaloStage = -1 Then
	  ;TODO
   ElseIf $angelHaloStage = -2 Then		;unknown state(restart game)
	  _ConsoleWriteError('Unexpected State!' & @CRLF)
	  checkVerification()
	  locateIngame_ah()
   ElseIf $angelHaloStage = -3 Then		;unknown state(restart game)
	  _ConsoleWriteError('Telegram Restart' & @CRLF)
	  restartGame($bi_ah)
	  $angelHaloStage = -2
   EndIf

;~    Nested loops and state error managing
   If $angelHaloStage = $lastState_ah Then
	  If $angelHaloStage = 0 Then
		 If Not _onTime_bi(getIdleTime(),$bi_ah) Then
			_ConsoleWriteError('Unknown State in Stage: ' & $angelHaloStage & @CRLF)
			checkVerification()
			restartGame($bi_ah)				;force a reload of the game and the tweets
			$angelHaloStage = -2
		 EndIf
	  ElseIf $angelHaloStage = 3 Then
		 If Not _onTime_bi(getErrorTime(),$bi_ah) Then
			_ConsoleWriteError('Unknown State in Stage: ' & $angelHaloStage & @CRLF)
			checkVerification()
			reloadGame($bi_ah)
			$angelHaloStage = -2
		 EndIf
	  Else
		 If Not _onTime_bi(getErrorTime(),$bi_ah) Then
			_ConsoleWriteError('Unknown State in Stage: ' & $angelHaloStage & @CRLF)
			checkVerification()
			$angelHaloStage = -2
		 EndIf
	  EndIf
   Else
	  _resetTime_bi($bi_ah)
   EndIf

   $lastState_ah = $angelHaloStage
EndFunc

Func checkAP()
   If checkForImage($minap,$bi_ah) or checkForImage($minap2,$bi_ah) or checkForImage($minap3,$bi_ah)  Then
	  _ConsoleWrite('Enough AP!' & @CRLF)
	  Return 1
   EndIf
   Return 0
EndFunc

;~ Ingame Functions(use randomized clicks)
Func enterHalo()	;Actually used to select a quest from special quests menu TODO implement another quests/scroll down to search
   activateGBWindow($bi_ah)
   For $j = 0 to 3;###### in case theres many quests before ah
   For $i = 0 to 14
	  ControlSend($granblue_windows[$bi_ah][0], "", "", "{DOWN}")
   Next
   Sleep(1000)
   If checkForImage($specialqmenu,$bi_ah) Then	;control send didn't work(sometimes happens)
	  restartGame($bi_ah)
	  $angelHaloStage = -2
	  Return
   EndIf
   ;#cs	ONLY when farming NM
   If checkForImage($ahnm,$bi_ah) or checkForImage($ahnm2,$bi_ah) Then
	  sendTelegramMessage('Angel Halo Nighmare Spawned!')
	  Sleep(120000)
	  $angelHaloStage = -2
	  Return
   EndIf
   ;#ce
   If checkForImage($ahsel,$bi_ah) or checkForImage($ahsel2,$bi_ah) Then
	  _ConsoleWrite('Selecting Angel Halo Quest...' & @CRLF)
	  $xReal = $x + 158
	  $yReal = $y + 67
	  $Xaux = 101
	  $Yaux = 20
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  $angelHaloStage = 2
	  Sleep(3000)
	  If checkForImage($ahplay,$bi_ah) or checkForImage($ahplay2,$bi_ah) or checkForImage($ahplay3,$bi_ah) or checkForImage($ahplay4,$bi_ah) Then
		 _ConsoleWrite('Selecting Correct Mode...' & @CRLF)
		 $xReal = $x + 298
		 $yReal = $y
		 $Xaux = 35
		 $Yaux = 24
		 randomClick($xReal,$yReal,$Xaux,$Yaux)
		 $angelHaloStage = 3
		 Return
	  EndIf
   EndIf
   Next;#######
   $angelHaloStage = -2
EndFunc

Func enterFavQuest()
   activateGBWindow($bi_ah)
   ;TODO scroll downt to check every quest

   For $j = 0 to 10	;start scrolling
	  For $i = 0 to 2
		 ControlSend($granblue_windows[$bi_ah][0], "", "", "{DOWN}")
	  Next
	  _ConsoleWrite('Checking Fav Quest...' & @CRLF)
	  Sleep(1000)
	  If checkForImage($favquest1,$bi_ah) Then
		 _ConsoleWrite('Selecting Fav Quest...' & @CRLF)
		 $xReal = $x+10;+100
		 $yReal = $y
		 $Xaux = 111
		 $Yaux = 40
		 randomClick($xReal,$yReal,$Xaux,$Yaux)
		 Sleep(3000)
		 If checkForImage($multiplequest,$bi_ah) Then
			_ConsoleWrite('Selecting Multiple Choice Fav Quest...' & @CRLF)
			$xReal = $x
			$yReal = $y-86
			$Xaux = 128
			$Yaux = 21
			randomClick($xReal,$yReal,$Xaux,$Yaux)
			Sleep($wt)
			clickOk($bi_ah)
			Sleep(3000)
		 EndIf
		 $angelHaloStage = 3
		 Return 1
	  EndIf
   Next	;end scrolling

   $angelHaloStage = -2
   Return 0
EndFunc

Func enterDailyShowdownQuest()
   activateGBWindow($bi_ah)
   For $i = 0 to 10
	  ControlSend($granblue_windows[$bi_ah][0], "", "", "{DOWN}")
   Next
   Sleep(1000)

   If checkForImage($dailyshowdown,$bi_ah) or checkForImage($dailyshowdown2,$bi_ah) or checkForImage($dailyshowdown3,$bi_ah) or checkForImage($dailyshowdown4,$bi_ah) or checkForImage($dailyshowdown5,$bi_ah) or checkForImage($dailyshowdown6,$bi_ah) Then
	  _ConsoleWrite('Selecting Daily Showdown Quest...' & @CRLF)
	  $xReal = $x
	  $yReal = $y
	  $Xaux = 84
	  $Yaux = 40
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  Sleep($wt)
	  If checkForImage($limitedquestprompt,$bi_ah) and clickOk($bi_ah) Then
		 $angelHaloStage = 3
		 Return 1
	  EndIf
   EndIf

   $angelHaloStage = -2
EndFunc

Func locateIngame_ah()
   activateGBWindow($bi_ah)
   _resetTime_bi($bi_ah)
   While _onTime_bi(getErrorTime(),$bi_ah)
	  rewardRoom($bi_ah,True)   							;handle the pending battle reward and regular reward, skip looting=true
;~ 	  If clickOk() Then
;~ 		 ;TODO: handle what happens when an ok button appears in this stage(usually it's the pending battles dialog)
;~ 	  EndIf
	  combatFailed($bi_ah)
	  ;Fix for when the quest fails
	  If checkForImage($resumequest,$bi_ah) Then
		 ;TODO: make a switch for cancel or resume
		 If checkForImage($acceptresumequest,$bi_ah) Then
		 ;If checkForImage($cancelresumequest,$bi_ah) Then
			_ConsoleWrite('Resuming Quest...' & @CRLF)
			$xReal = $x
			$yReal = $y
			$Xaux = 141
			$Yaux = 24
			randomClick($xReal,$yReal,$Xaux,$Yaux)
			_resetTime_bi($bi_ah)
			$angelHaloStage = 5  ;##
			Return 1
		 EndIf
	  EndIf

	  If checkForImage($pendingdialog,$bi_ah) Then
		 _ConsoleWrite('We Got Pending Battles!' & @CRLF)
		 If clickOk($bi_ah) Then
			_ConsoleWrite('Going to Pending Battles Menu...' & @CRLF)
			If checkForImageT($pending,$wtl,$bi_ah) Then
			   _ConsoleWrite('Finishing Pending Battle...' & @CRLF)
			   $xReal = $x - 360						;correct the image into the real button pixel coordinates
			   $yReal = $y - 25
			   $Xaux = 380							;button pixel size
			   $Yaux = 80
			   randomClick($xReal,$yReal,$Xaux,$Yaux)
			   randomClick($xReal,$yReal,$Xaux,$Yaux) ; often fails
			   _resetTime_bi($bi_ah)
			   Sleep($wtl)
			   restartGame($bi_ah)
			EndIf
		 EndIf
	  EndIf
	  If checkForImage($pending,$bi_ah) Then
		 _ConsoleWrite('Finishing Pending Battle...' & @CRLF)
		 $xReal = $x - 360						;correct the image into the real button pixel coordinates
		 $yReal = $y - 25
		 $Xaux = 380							;button pixel size
		 $Yaux = 80
		 randomClick($xReal,$yReal,$Xaux,$Yaux)
		 randomClick($xReal,$yReal,$Xaux,$Yaux) ; often fails
		 _resetTime_bi($bi_ah)
		 Sleep($wtl)
		 restartGame($bi_ah)
	  EndIf

	  If gotoSpecialQ()	Then
		 $angelHaloStage = 0	;-1
		 _resetTime_bi($bi_ah)
		 Return 1
	  EndIf
   WEnd
   restartGame($bi_ah)
   _resetTime_bi($bi_ah)
   Return 0
EndFunc

Func gotoSpecialQ()
   _ConsoleWrite('Locating Correct Menu for Quest Type: ' &$farmQuestType& @CRLF)
;~    rewardRoom()   							;handle the pending battle reward and regular reward
;~    If clickOk() Then
;~ 	  ;TODO: handle what happens when an ok button appears in this stage(usually it's the pending battles dialog)
;~    EndIf
   ;cancelResumeQuest($bi_ah)
   If checkForImage($pendingdialog,$bi_ah) Then
	  _ConsoleWrite('Room Closed or Pending Battles!' & @CRLF)
	  clickOk($bi_ah)
   EndIf
   If $farmQuestType <> 3 Then ;don't get in quests menu if it's GW
	  If checkForImage($quest2,$bi_ah) Then
		 _ConsoleWrite('Accesing Quest Menu...' & @CRLF)
		 $xReal = $x - 20
		 $yReal = $y - 40
		 $Xaux = 95
		 $Yaux = 69							;it doesn't matter if we click the raid crew button
		 randomClick($xReal,$yReal,$Xaux,$Yaux)
		 _resetTime_bi($bi_ah)
	  EndIf
	  clickQuestsButton($bi_ah)
   EndIf

   If $farmQuestType = 1 and gotoFavquests() Then ;ONLY if FAV QUEST
	  _ConsoleWrite('Inside Favorite Quest Menu...' & @CRLF)
	  Return 1
   EndIf
   If $farmQuestType = 0 Then	;ONLY if AH/Special Quests
	  clickSpecialQButton($bi_ah)
   EndIf

   If checkForImage($pending,$bi_ah) And Not checkForImage($eventraids,$bi_ah) Then
	  _ConsoleWrite('Finishing Pending Battle...' & @CRLF)
	  $xReal = $x - 360						;correct the image into the real button pixel coordinates
	  $yReal = $y - 25
	  $Xaux = 380							;button pixel size
	  $Yaux = 80
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  _resetTime_bi($bi_ah)
   EndIf

   If $farmQuestType = 0 and checkForImage($specialqmenu,$bi_ah) Then	;ONLY if AH
	  _ConsoleWrite('Correct Menu!' & @CRLF)
	  Return 1
   EndIf
   If $farmQuestType = 2 and (checkForImage($questmenu,$bi_ah) or checkForImage($favquestsmenu,$bi_ah)) Then	;ONLY if DailyShowdowns
	  _ConsoleWrite('Correct Menu!' & @CRLF)
	  Return 1
   EndIf
   If $farmQuestType = 3 and gotoGW() Then	;ONLY if GW
	  _ConsoleWrite('Correct Menu!' & @CRLF)
	  Return 1
   EndIf
   Return 0
EndFunc

Func gotoFavquests()
   If $farmQuestType = 1 and (checkForImage($favquestsmenu,$bi_ah) or checkForImage($favquestsmenu2,$bi_ah) or checkForImage($favquestsmenu3,$bi_ah) or checkForImage($favquestsmenu4,$bi_ah)) Then
	  _ConsoleWrite('Accesing Favorite Quest Menu...' & @CRLF)
	  $xReal = $x
	  $yReal = $y
	  $Xaux = 40
	  $Yaux = 31							;it doesn't matter if we click the raid crew button
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  _resetTime_bi($bi_ah)
	  Return 1
   EndIf
   If checkForImage($favquest1,$bi_ah) Then	;Placeholder for the actual favorite quest menu check(this checks the actual quest)
	  _ConsoleWrite('Correct Menu!' & @CRLF)
	  Return 1
   EndIf
   Return 0
EndFunc

Func gotoGW()	;GW
   activateGBWindow($bi_ah)
   ;If checkForImage($GWmenu,$bi_ah) Then
	;  Return 1
  ; EndIf
   _ConsoleWrite('Looking for GW Banner...' & @CRLF)
   clickTopMenu($bi_ah)

   If checkForImage($upperClose,$bi_ah) and checkForImage($GWbanner,$bi_ah) Then
	  _ConsoleWrite('Clicking GW Banner...' & @CRLF)
	  $xReal = $x
	  $yReal = $y
	  $Xaux = 300
	  $Yaux = 20
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  _resetTime_bi($bi_ah)
	  If checkForImageT($GWmenu,$wtl,$bi_ah) Then
		 Return 1
	  EndIf
   EndIf
   Return 0
EndFunc

Func enterGWQuest()	;GW
   activateGBWindow($bi_ah)

   For $i = 0 to 3
	  For $j = 0 to 5;10
		 ControlSend($granblue_windows[$bi_ah][0], "", "", "{DOWN}")
	  Next
	  Sleep(1000)

	  If checkForImageT($GWquestMenu,$wt,$bi_ah) Then
		 _ConsoleWrite('Clicking GW Quest Menu...' & @CRLF)
		 $xReal = $x + 5
		 $yReal = $y + 5
		 $Xaux = 69
		 $Yaux = 56
		 randomClick($xReal,$yReal,$Xaux,$Yaux)
		 randomClick($xReal,$yReal,$Xaux,$Yaux)	;Fails too often
		 _resetTime_bi($bi_ah)
		 If checkForImageT($GWquest,$wtl,$bi_ah) or checkForImageT($GWquestCurr,$wt,$bi_ah) Then
			_ConsoleWrite('Clicking GW EX+...' & @CRLF)
			$xReal = $x
			$yReal = $y
			$Xaux = 49
			$Yaux = 16
			If $NM90 = 1 Then
			   ;when doing nm 90 this menu is different in prelims
			   clickOk($bi_ah)
			   _resetTime_bi($bi_ah)
			   $angelHaloStage = 3
			   Return 1
			EndIf
			randomClick($xReal,$yReal,$Xaux,$Yaux)
			randomClick($xReal,$yReal,$Xaux,$Yaux) ;Fails too often
			_resetTime_bi($bi_ah)
			$angelHaloStage = 3
			Return 1
		 Else
			reloadGame($bi_ah)
			$angelHaloStage = -2
			Return 0
		 EndIf
	  EndIf

	  For $j2 = 0 to 70
		 ControlSend($granblue_windows[$bi_ah][0], "", "", "{UP}")
	  Next
	  Sleep(1000)
   Next

   $angelHaloStage = -2
   Return 0
EndFunc
