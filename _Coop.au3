#include "lib\functions.au3"

;Define the instance which this bot works with(granblue_windows)
Local $bi_c = 1

;~ Stages:
;~ -1:	locate the state of the game
;~ 0:	selecting correct roomtype
;~ 1:	selecting room
;~ 2:	inroom

$target_roomTypeImage = Null
$target_roomTypeImage_hovered = Null
$target_roomType_correct = Null
$target_roomType_roomSelection = Null
setCoopRoomSelectionImages()

Global $coopStage = -1
Local $lastState_c = $coopStage

Global $leave_room = 0
Global $slime = 1
Global $soloSlime = 1

;Sleep(2000)
;prepareGranblueWindowAbsolute()

;While 1
;checkState_c()
;Wend

Func setCoopRoomSelectionImages()
;Set the images to target depending on the input
   If $join_pandemonium == 1 Then
	  $target_roomTypeImage = $pandemonium
	  $target_roomTypeImage_hovered = $pandemonium2
	  $target_roomType_correct = $pandemoniumcorrect
	  $target_roomType_roomSelection = $pandemoniumnorank
   Else
	  $target_roomTypeImage = $anyone
	  $target_roomTypeImage_hovered = $anyone2
	  $target_roomType_correct = $anyonecorrect
	  $target_roomType_roomSelection = $roomnorank
   EndIf
EndFunc

;~ BOT FUNCTIONS ~

;check the location of the bot inside the game(based on images)
Func checkState_c()
   ;_ConsoleWriteError('Stage: ' & $coopStage & @CRLF)
   If checkForImage($neterror,$bi_c) Then
	  $coopStage = -1
   EndIf
   If $coopStage = -1 Then
	  checkVerification()
	  locateIngame_c()
   ElseIf $coopStage = 0 Then
	  #cs
	  If checkRoom() Then	;when we already in a room after entering coop
		 $coopStage = 2
		 _resetTime_bi($bi_c)
	  Else
		 #ce
		 If selectCoopRoomType() Then
			$coopStage = 1
		 ;EndIf
	  EndIf
   ElseIf $coopStage = 1 Then
	  If selectCoopRoom() Then
		 $coopStage = 2
	  EndIf
   ElseIf $coopStage = 2 Then
	  inRoom()
	  rewardRoom($bi_c)	;handle reward room here too
   ElseIf $coopStage = 3 Then
	  checkRoom()
	  If $slime = 1 Then
		 If slimeCombat($bi_c) Then
			reloadGame($bi_c)
			$coopStage = 2
		 EndIf
	  Else
		 If simpleCombat($bi_c) Then
			reloadGame($bi_c)
			$coopStage = 2
		 EndIf
	  EndIf
   ElseIf $coopStage = -3 Then
	  _ConsoleWriteError('Telegram Reset' & @CRLF)
	  restartGame($bi_c)
	  $coopStage = -1
   EndIf

   ;~    Nested loops and state error managing
   If $coopStage = $lastState_c Then
	  If $coopStage = 3 Or $coopStage = 1 Then
		 If Not _onTime_bi(getIdleTime(),$bi_c) Then
			_ConsoleWriteError('Too Much Time Idle in Stage: ' & $coopStage & ', Restarting...' & @CRLF)
			checkVerification()
			switchPandemonium(); check if timeout happened by lack of pandemonium rooms
			checkCoopCombatFailed();check if combat has failed/all players left
			resetAttack()
			restartGame($bi_c)
			$coopStage = -1
		 EndIf
	  ElseIf $coopStage = 2 Then	;rechek if we're inroom every 2min
		 If Not _onTime_bi(120000,$bi_c) Then
			_ConsoleWriteError('Too Much Time Idle in Stage: ' & $coopStage & ', Restarting...' & @CRLF)
			checkVerification()
			switchPandemonium(); check if timeout happened by lack of pandemonium rooms
			checkCoopCombatFailed();check if combat has failed/all players left
			resetAttack()
			reloadGame($bi_c)
			$coopStage = -1
		 EndIf
	  Else
		 If Not _onTime_bi(getErrorTime(),$bi_c) Then
			_ConsoleWriteError('Error in Stage: ' & $coopStage & ', Locating...' & @CRLF)
			checkVerification()
			$coopStage = -1
		 EndIf
	  EndIf
   Else
	  _resetTime_bi($bi_c)
   EndIf

   $lastState_c = $coopStage
EndFunc

Func locateIngame_c()
   _resetTime_bi($bi_c)
   While _onTime_bi(getErrorTime(),$bi_c)
	  If checkRoom() Then
		 $coopStage = 2
		 _resetTime_bi($bi_c)
		 Return 1
	  EndIf
	  If checkForImage($attack,$bi_c) Then
		 _ConsoleWrite('Ready not Found!' & @CRLF)
		 resetAttack()
		 $coopStage = 3
	  EndIf
	  If clickOk($bi_c) Then
		 _ConsoleWrite('Ok when locating ingame...' & @CRLF)
		 ;TODO: handle what happens when an ok button appears in this stage
	  EndIf

	  If checkForImage($pending,$bi_c) Then
		 _ConsoleWrite('Finishing Pending Battle...' & @CRLF)
		 $xReal = $x - 360						;correct the image into the real button pixel coordinates
		 $yReal = $y - 25
		 $Xaux = 380							;button pixel size
		 $Yaux = 80
		 randomClick($xReal,$yReal,$Xaux,$Yaux)
		 _resetTime_bi($bi_rfs)	;TODO wrong?
		 Sleep($wtl)
		 restartGame($bi_c)
	  EndIf

	  If gotoCoop()	Then
		 $coopStage = 0
		 _resetTime_bi($bi_c)
		 Return 1
	  EndIf
	  leaveCombatRoom($bi_c)
   WEnd
   _ConsoleWriteError('State Not Located Ingame' & @CRLF)
   restartGame($bi_c)
   _resetTime_bi($bi_c)
   Return 0
EndFunc

Func checkCoopCombatFailed()
   If $coopStage = 3 Then
	  sendTelegramMessage("co-op combat failed/timeout")
	  reloadGame($bi_c)
	  Sleep(10000)
	  leaveCombatRoom($bi_c)
   EndIf
EndFunc

Func gotoCoop()
   clickCoopButton($bi_c)
   retreatedFromRaid($bi_c)
   Return clickJoinaRoomButton($bi_c)
EndFunc

Func selectCoopRoomType()
   ;First change the room type(keep checking the image for the lag)
   _ConsoleWrite('Checking Room Type...' & @CRLF)
   Sleep($wt)			;Let time to change room types
   If $join_pandemonium = 0 Then	;don't check anything
	  For $i = 0 to 9
		 ControlSend($granblue_windows[$bi_c][0], "", "", "{DOWN}")
	  Next
	  Return 1
   EndIf

   If Not checkForImageT($target_roomType_correct,$wtl,$bi_c) Then								;The room type has already been changed
	  _ConsoleWrite('Incorrect Type, Changing...' & @CRLF)
	  If checkForImage($allrooms,$bi_c) Or checkForImage($allrooms2,$bi_c) Or checkForImage($allrooms3,$bi_c) Or checkForImage($allrooms4,$bi_c) Then				;click All(two images)
		 $Xaux = 233
		 $Yaux = 27
		 randomClick($x,$y,$Xaux,$Yaux)
		 _ConsoleWrite('Expanding Types Menu...' & @CRLF)
		 If checkForImageT($target_roomTypeImage,$wtl,$bi_c) or checkForImageT($target_roomTypeImage_hovered,$wtl,$bi_c) Then	;click Anyone
			$Xaux = 260
			$Yaux = 21
			;Sleep($wt)
			randomClick($x,$y,$Xaux,$Yaux)
			_ConsoleWrite('Room Type Changed!' & @CRLF)
			Sleep($wt)			;Let time to change room types
			For $i = 0 to 9		;Scroll down to see more rooms
			   ControlSend($granblue_windows[$bi_c][0], "", "", "{DOWN}")
			Next
			return 1
		 EndIf
	  EndIf
   Else
	  _ConsoleWrite('Correct Room Type!' & @CRLF)
	  For $i = 0 to 9		;Scroll down to see more rooms
			ControlSend($granblue_windows[$bi_c][0], "", "", "{DOWN}")
	  Next
	  return 1
   EndIf

   return 0
EndFunc

;Switch pandemonium if the timeout triggered in the room selection menu(no pandemonium rooms available)
Func switchPandemonium()
   If $coopStage = 1 and $join_pandemonium = 1 Then
	  $join_pandemonium = 0
	  setCoopRoomSelectionImages()
	  sendTelegramMessage("timeout at pandemonium room selection")
   EndIf
EndFunc

;~ This function will force a refresh on every launch to avoid any problem and to get the most recent room 1st.
Func selectCoopRoom()
   If checkForImage($refreshrooms,$bi_c) Then 		;refresh
	  $Xaux = 23
	  $Yaux = 24
	  randomClick($x,$y,$Xaux,$Yaux)
	  _ConsoleWrite('Refreshing Rooms...' & @CRLF)
	  Sleep(1000)
	  If checkForImage($target_roomType_roomSelection,$bi_c) Then			;select 1st room
		 $xReal = $x - 10
		 $yReal = $y - 55
		 $Xaux = 355								;the chat bubble obstructs some part
		 $Yaux = 100
		 randomClick($xReal,$yReal,$Xaux,$Yaux)
		 _ConsoleWrite('Selecting Room...' & @CRLF)
	  EndIf
   EndIf
   If checkForImage($joinroom,$bi_c) Then				;join room
	  $Xaux = 150
	  $Yaux = 27
	  randomClick($x,$y,$Xaux,$Yaux)
	  _ConsoleWrite('Joining Room...' & @CRLF)
	  Sleep(1000)								;let some time to load if room is full or closed
	  If checkForImage($pendingdialog,$bi_c) or Not clickOk($bi_c) Then
		 _ConsoleWrite('Joined Room!' & @CRLF)
		 Return 1
	  EndIf
   EndIf
   If checkForImage($notmet,$bi_c) Then				;join room
	  If checkForImage($notmetcancel,$bi_c) Then
		 $Xaux = 148
		 $Yaux = 26
		 randomClick($x,$y,$Xaux,$Yaux)
		 _ConsoleWrite('Requirements not Met...' & @CRLF)
	  EndIf
   EndIf
   Return 0
EndFunc


;~ Tests if we already selected a party for our team. It will select the team, wait for the quest and get ready.
;~ If time passed without events it will return 0, so the stateCheck() function will try to get if you where kicked,
;~ room was closed or relaunch the function to keep waiting for everyone to get ready.
Func checkRoom()
   activateGBWindow($bi_c)
   If checkForImage($inroom,$bi_c) Then				;move down the granblue window as we cant click the select party button
	  randomMove($x,$y,20,20);MouseMove($x,$y) ;move the mouse to prevent the game from not scrolling down
	  Sleep(500)
	  ;ControlSend($granblue_windows[$bi_c][0], "", "", "{DOWN}")
	  ;ControlSend($granblue_windows[$bi_c][0], "", "", "{DOWN}")
	  MouseWheel($MOUSE_WHEEL_DOWN, 1) ;TODO-TESTING
	  Sleep(500)
	  #cs
	  If checkForImage($inroom,$bi_c) or checkForImage($inroom2,$bi_c) Then	;DIDNT SCROLL DOWN
		 clickTopMenu($bi_c)	;reactivate window to let it scroll down
		 Sleep(500)
		 closeTopMenu($bi_c)
		 Sleep(500)
		 MouseWheel($MOUSE_WHEEL_DOWN, 1)
		 ;REactivateGBWindow($bi_c)
	  EndIf
	  #ce

	  Return 1
   EndIf
   If checkForImage($closedroom,$bi_c) or checkForImage($pendingdialog,$bi_c) Then
	  _ConsoleWrite('Room Closed or Pending Battles!' & @CRLF)
	  clickOk($bi_c)
	  $coopStage = -1
   EndIf
   Return 0
EndFunc

Func inRoom()
   _ConsoleWrite('In Room...' & @CRLF)
   checkRoom()
   retreatedFromRaid($bi_c)
   ;check if party has already been selected
   If Not checkForImage($skipparty,$bi_c) Then
	  If checkForImage($disabledready,$bi_c) And checkForImage($selsummbanner,$bi_c) Then	;go to party selection
		 $xReal = $x
		 $yReal = $y + 39
		 $Xaux = 227
		 $Yaux = 25
		 randomClick($xReal,$yReal,$Xaux,$Yaux)
		 _ConsoleWrite('Selecting Party...' & @CRLF)
		 Sleep(1000)
	  EndIf
   EndIf

   ;check if party has already been selected
   If Not checkForImage($skipparty,$bi_c) Then
	  If selectSummon($bi_c) Then
		 Sleep($wt)
		 _ConsoleWrite('Ok after summon selection...' & @CRLF)
		 clickOk($bi_c);test
	  EndIf
   EndIf

   ;check first if the ready button is not red nor gray
;~    checkRoom()
   If Not checkForImage($alreadyready,$bi_c) And Not checkForImage($disabledready,$bi_c) and checkForImage($skipparty,$bi_c) Then
	  If checkRoom() Then
		 Return
	  EndIf
;~ 	  _ConsoleWrite('Checking Ready...' & @CRLF)
	  If checkForImage($clickready2,$bi_c) Then	;the ap needed indicator is faster as its static
		 $xReal = $x + 170
		 $yReal = $y - 5
		 $Xaux = 52
		 $Yaux = 27
		 randomClick($xReal,$yReal,$Xaux,$Yaux)
;~ 		 _ConsoleWrite('Ready!' & @CRLF)
;~ 		 resetAttack()
;~ 		 $coopStage = 3
	  EndIf
   EndIf

   If $soloSlime = 1 and $use_elixirs Then
	  useElixirs($bi_c)	;USING ELIXIRS FOR SOLO
   EndIf

   If checkForImage($alreadyready,$bi_c) Then ;make sure we clicked(sometimes fails)
	  _ConsoleWrite('Ready!' & @CRLF)
	  resetAttack()
	  $coopStage = 3
   EndIf
   If checkForImage($attack,$bi_c) Then
	  _ConsoleWrite('Ready not Found!' & @CRLF)
	  resetAttack()
	  $coopStage = 3
   EndIf
   leaveRoom()
EndFunc

Func leaveRoom()
   If $leave_room = 0 Then Return 0
   _ConsoleWrite('Leaving room' & @CRLF)
   activateGBWindow($bi_c)
   Sleep(500)
   For $i=0 to 20
	  ControlSend($granblue_windows[$bi_c][0], "", "", "{DOWN}")
   Next
   If checkForImage($leaveroomb,$bi_c) Then
	  $Xaux = 77
	  $Yaux = 36
	  randomClick($x,$y,$Xaux,$Yaux)
	  _ConsoleWrite('Leaving Room...' & @CRLF)
	  Sleep(1000)
	  If checkForImage($confirmleaveroomb,$bi_c) Then
		 $Xaux = 144
		 $Yaux = 26
		 randomClick($x,$y,$Xaux,$Yaux)
		 _ConsoleWrite('Left Room' & @CRLF)
	  EndIf
   EndIf
   $leave_room = 0
   $coopStage = -1
   Return 1
EndFunc
