#include-once
#include <Date.au3>
#include <File.au3>
#include <ScreenCapture.au3>

#include "initVariables.au3"
#include "ImageSearch.au3"
#include "images.au3"
#include "windows.au3"
#include "timers.au3"
#include "telegramBot.au3"
#include "combat.au3"
#include "rewardRoom.au3"

getWindows()

Global $verificationNeeded = 0

;~ Configurable variables
#cs
Global $use_elixirs = getBoolean(IniRead("config.ini", "global", "use_elixirs", "0"))
ConsoleWrite('- Global ' & @CRLF)
ConsoleWrite('Use Half Elixir: ' & $use_elixirs & @CRLF)
Global $use_berries = getBoolean(IniRead("config.ini", "global", "use_berries", "0"))
ConsoleWrite('Use Soul Berry: ' & $use_berries & @CRLF)
Global $use_Bberries = getBoolean(IniRead("config.ini", "global", "use_Bberries", "0"))
ConsoleWrite('Use Soul Balm: ' & $use_Bberries & @CRLF)
#ce

Global $y = 0, $x = 0		;relative x/y origin when the image is not the button itself
Global $Yaux = 0, $Xaux = 0	;button size/pixel offsets to randomize(depends on each case)

Local $lastMsg = ""

Local $combatFailedSent = False

;Local $hFile = FileOpen(@ScriptDir & "\Log.log", 1)


HotKeySet("{PAUSE}", "TogglePause")
Global $Paused
Func TogglePause()
   $Paused = Not $Paused
   While $Paused
	  ToolTip('Bot Paused.',0,0)
	  Sleep(100)
	  getCommand()
   WEnd
   ToolTip("")
EndFunc

Func _online()		;check internet connection to prevent the bot to crash
   $ping = Ping("api.telegram.org")
   If Not @error Then
	  Return 1
   Else
	  _ConsoleWrite('Internet Error... ' & @error & @CRLF)
	  Return 0
   EndIf
   Return 0
EndFunc

Func _onlineWait()	;wait until we got internet connection
   $ping = Ping("api.telegram.org")
   If Not @error Then
	  Return
   Else
	  _ConsoleWrite('Internet Error... ' & @error & @CRLF)
	  Do
        $ping = Ping("api.telegram.org")
		Sleep(5000)
	  Until Not @error
	  Return
   EndIf
EndFunc

;~ .ini read functions
Func getBoolean($b)
   If Int($b) == 0 Then
	  Return False
   ElseIf Int($b) == 1 Then
	  Return True
   Else
	  Return Null
   EndIf
EndFunc

;~ Own ConsoleWrite Function To Debug
Func _ConsoleWrite($msg)
   If $lastMsg <> $msg Then			;dont spam messages
	  ConsoleWrite(_NowTime(4) & ' ' & $msg)
   EndIf
   $lastMsg = $msg
EndFunc

Func _ConsoleWriteError($msg)
   If $lastMsg <> $msg Then
	  ConsoleWriteError(_NowTime() & ' ' & $msg)
	  _log($msg)					;log the errors
   EndIf
   $lastMsg = $msg
EndFunc

Func _log($msg)
   ;_FileWriteLog($hFile, $msg)
EndFunc

;~ General Bot Functions
Func restartGame($bot_instance)
   If checkForImage($mypage,$bot_instance) Or checkForImage($mypage2,$bot_instance) Then
	  _ConsoleWriteError('Restarting Game...' & @CRLF)
	  $Xaux = 39
	  $Yaux = 36
	  randomClick($x,$y,$Xaux,$Yaux)
	  Return 1
   EndIf
   Return 0
EndFunc

Func reloadGame($bot_instance)
   If checkForImage($reload,$bot_instance) Or checkForImage($reload2,$bot_instance) Then
	  _ConsoleWriteError('Reloading Game...' & @CRLF)
	  $Xaux = 37
	  $Yaux = 34
	  randomClick($x,$y,$Xaux,$Yaux)
	  Return 1
   EndIf
   Return 0
EndFunc

Func clickBack($bot_instance)
   If checkForImage($back,$bot_instance) Then
	  _ConsoleWriteError('Clicking Back...' & @CRLF)
	  $Xaux = 39
	  $Yaux = 39
	  randomClick($x,$y,$Xaux,$Yaux)
	  Return 1
   EndIf
   Return 0
EndFunc

Func clickTopMenu($bot_instance)
   If checkForImage($upperMenu,$bot_instance) Then
	  _ConsoleWrite('Clicking Upper Menu...' & @CRLF)
	  $xReal = $x
	  $yReal = $y
	  $Xaux = 33
	  $Yaux = 23
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  Return 1
   EndIf
   Return 0
EndFunc

Func closeTopMenu($bot_instance)
   If checkForImage($upperClose,$bot_instance) Then
	  _ConsoleWrite('Closing Upper Menu...' & @CRLF)
	  $xReal = $x
	  $yReal = $y
	  $Xaux = 33
	  $Yaux = 23
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  Return 1
   EndIf
   Return 0
EndFunc

Func clickOk($bot_instance)
   ;_ConsoleWrite('Looking for Dialog...' & @CRLF)
   For $i = 0 to Ubound($oks) - 1
	  If checkForImage($oks[$i],$bot_instance) Then
	  $Xaux = 140
	  $Yaux = 30
	  randomClick($x,$y,$Xaux,$Yaux)
	  _ConsoleWrite('Clicking Ok...' & @CRLF)
	  Return 1
	  EndIf
   Next
   Return 0
EndFunc

Func selectSummon($bot_instance)
   If $leechingSummons Then ;leeching summons
	  If checkForImage($special_summons,$bot_instance) or checkForImage($special_summons2,$bot_instance) Then
		 _ConsoleWrite('Selecting Special Summon...' & @CRLF)
		 $xReal = $x
		 $yReal = $y
		 $Xaux = 17				;button pixel size
		 $Yaux = 17
		 randomClick($xReal,$yReal,$Xaux,$Yaux)
	  Else
		 Return 0
	  EndIf

	  If selectSpecialSummon($bot_instance) Then
		 Return 1
	  Else
		 If checkForImage($select_summon,$bot_instance) or checkForImage($select_summon2,$bot_instance) Then
			_ConsoleWrite('Selecting Summon...' & @CRLF)
			$xReal = $x - 360			;correct the image into the real button pixel coordinates
			$yReal = $y - 25
			$Xaux = 385				;button pixel size
			$Yaux = 75
			randomClick($xReal,$yReal,$Xaux,$Yaux)
			Return 1
		 EndIf
	  EndIf
	  For $i = 0 to 20
			ControlSend($granblue_windows[$bot_instance][0], "", "", "{UP}")
	  Next
	  Return 0
   EndIf

   ;if it doesnt work it will just select whatever summon
   If checkForImage($select_summon,$bot_instance) or checkForImage($select_summon2,$bot_instance) Then
	  _ConsoleWrite('Selecting Summon...' & @CRLF)
	  $xReal = $x - 360			;correct the image into the real button pixel coordinates
	  $yReal = $y - 25
	  $Xaux = 385				;button pixel size
	  $Yaux = 75
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  Return 1
   EndIf
   Return 0
EndFunc

Func selectSpecialSummon($bot_instance)
   For $i = 0 to 3
	  For $j = 0 to 7
		 ControlSend($granblue_windows[$bot_instance][0], "", "", "{DOWN}")
	  Next
	  Sleep(1000)
	  If checkForImage($exp_summons1,$bot_instance) or checkForImage($exp_summons2,$bot_instance) or checkForImage($exp_summons3,$bot_instance) or checkForImage($exp_summons4,$bot_instance) Then
		 _ConsoleWrite('Selecting Exp-boosting Summon...' & @CRLF)
		 $xReal = $x
		 $yReal = $y ;- 32	;trouble when the name is in the middle but it's unclickable below the bottom panel
		 $Xaux = 100				;button pixel size
		 $Yaux = 16
		 randomClick($xReal,$yReal,$Xaux,$Yaux)
		 randomClick($xReal,$yReal,$Xaux,$Yaux) ;fails often
		 Return 1
	  EndIf
   Next
   Return 0
EndFunc

Func rejoinRaid($bot_instance)
   If checkForImage($rejoin,$bot_instance) Then
	  _ConsoleWrite('Re-Joining Unfinished Battle...' & @CRLF)
	  $xReal = $x - 279			;correct the image into the real button pixel coordinates
	  $yReal = $y - 31
	  $Xaux = 345				;button pixel size
	  $Yaux = 90
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  Return 1
   EndIf
   Return 0
EndFunc

Func cancelResumeQuest($bot_instance)
   If checkForImage($resumequest,$bot_instance) Then
	  If checkForImage($cancelresumequest,$bot_instance) Then
		 _ConsoleWrite('Not Resuming Quests...' & @CRLF)
		 $xReal = $x
		 $yReal = $y
		 $Xaux = 144
		 $Yaux = 27
		 randomClick($xReal,$yReal,$Xaux,$Yaux)
		 Return 1
	  EndIf
   EndIf
   Return 0
EndFunc

Func retreatedFromRaid($bot_instance)
   If checkForImage($retreatedraid,$bot_instance) Then
	  clickOk($bot_instance)
	  Return 1
   EndIf
   Return 0
EndFunc

Func clickQuestsButton($bot_instance)
   For $i = 0 to Ubound($questButtons) - 1
	  If checkForImage($questButtons[$i],$bot_instance) Then
		 _ConsoleWrite('Accesing Quest Menu...' & @CRLF)
		 $xReal = $x - 5
		 $yReal = $y - 10
		 $Xaux = 90
		 $Yaux = 70
		 randomClick($xReal,$yReal,$Xaux,$Yaux)
		 _resetTime_bi($bot_instance)
		 Return 1
	  EndIf
   Next
   Return 0
EndFunc

Func clickSpecialQButton($bot_instance)
;~    For $i = 0 to $raidButtonAmount - 1
;~ 	  If checkForImage($raidButtons[$i]) Then
;~ 		 _ConsoleWrite('Accesing Special Quests Menu...' & @CRLF)
;~ 		 $xReal = $x - 81
;~ 		 $yReal = $y
;~ 		 $Xaux = 110
;~ 		 $Yaux = 28
;~ 		 randomClick($xReal,$yReal,$Xaux,$Yaux)
;~ 		 _resetTime_bi()
;~ 		 Return 1
;~ 	  EndIf
;~    Next

   If checkForImage($questmenu,$bot_instance) Then
	  If checkForImage($homeref,$bot_instance) Then
		 _ConsoleWrite('Accesing Special Quests Menu...' & @CRLF)
		 $xReal = $x + 171
		 $yReal = $y + 381
		 $Xaux = 110
		 $Yaux = 27
		 randomClick($xReal,$yReal,$Xaux,$Yaux)
		 _resetTime_bi($bot_instance)
		 Return 1
	  EndIf
   EndIf
   Return 0
EndFunc

Func clickRaidButton($bot_instance)
;~    For $i = 0 to $raidButtonAmount - 1
;~ 	  If checkForImage($raidButtons[$i]) Then
;~ 		 _ConsoleWrite('Accesing Raid Menu...' & @CRLF)
;~ 		 $xReal = $x + 55
;~ 		 $yReal = $y
;~ 		 $Xaux = 110
;~ 		 $Yaux = 28
;~ 		 randomClick($xReal,$yReal,$Xaux,$Yaux)
;~ 		 _resetTime_bi()
;~ 		 Return 1
;~ 	  EndIf
;~    Next

   If checkForImage($questmenu,$bot_instance) Then
	  _ConsoleWrite('In Quest Menu' & @CRLF)
	  If checkForImage($homeref,$bot_instance) Then
		 _ConsoleWrite('Accesing Raid Menu...' & @CRLF)
		 $xReal = $x + 295
		 $yReal = $y + 379
		 $Xaux = 110
		 $Yaux = 27
		 randomClick($xReal,$yReal,$Xaux,$Yaux)
		 _resetTime_bi($bot_instance)
		 Return 1
	  EndIf
   EndIf
   Return 0
EndFunc

Func clickCoopButton($bot_instance)
   For $i = 0 to Ubound($coopButtons) - 1
	  If checkForImage($coopButtons[$i],$bot_instance) Then
		 _ConsoleWrite('Accessing Co-op...' & @CRLF)
		 $Xaux = 58
		 $Yaux = 34
		 randomClick($x,$y,$Xaux,$Yaux)
		 Return 1
	  EndIf
   Next
   Return 0
EndFunc

Func clickJoinaRoomButton($bot_instance)
   Sleep($wt)

   #cs TODO CHECK THAT WE ARE IN THE CORRECT MENU, SCROLLING DOWN CAUSES PROBLEM WHEN ALREADY IN ROOM
   For $i = 0 to 15
	  ControlSend($granblue_windows[$bot_instance][0], "", "", "{DOWN}")
   Next
   #ce
   For $i = 0 to Ubound($joinaButtons) - 1
	  If checkForImage($joinaButtons[$i],$bot_instance) Then
		 _ConsoleWrite('In the Lobby, Clicking Join...' & @CRLF)
		 $Xaux = 142
		 $Yaux = 33
		 randomClick($x,$y,$Xaux,$Yaux)
		 Return 1
	  EndIf
   Next
   Return 0
EndFunc

Func useBerries($bot_instance)
   If $use_berries Then
	  If checkForImage($berries,$bot_instance) Then
		 _ConsoleWrite('Using Berries...' & @CRLF)
		 If checkForImage($useberries,$bot_instance) or checkForImage($useberries2,$bot_instance) Then
			$xReal = $x
			$yReal = $y
			$Xaux = 96
			$Yaux = 28
			randomClick($xReal,$yReal,$Xaux,$Yaux)
			_ConsoleWrite('Berries Used!' & @CRLF)
			If checkForImageT($used,$wt,$bot_instance) Then
			   clickOk($bot_instance)
			EndIf
		 EndIf
		 If $use_Bberries Then
			If checkForImage($usebberries,$bot_instance) or checkForImage($usebberries2,$bot_instance) Then
			   _ConsoleWrite('Using Big Berries Instead...' & @CRLF)
			   $xReal = $x-190 	;-190 this values when using depleted use button
			   $yReal = $y
			   $Xaux = 85 	;85
			   $Yaux = 20	;20
			   randomClick($xReal,$yReal,$Xaux,$Yaux)
			   _ConsoleWrite('Berries Used!' & @CRLF)
			   If checkForImageT($used,$wt,$bot_instance) Then
				  clickOk($bot_instance)
			   EndIf
			EndIf
		 EndIf
	  EndIf
   EndIf
EndFunc

Func useElixirs($bot_instance)
   If $use_elixirs Then
	  If checkForImage($halfelixir,$bot_instance) or checkForImage($halfelixir2,$bot_instance) or checkForImage($halfelixir3,$bot_instance) or checkForImage($halfelixir4,$bot_instance) Then
		 _ConsoleWrite('Using Half Elixirs...' & @CRLF)
		 $xReal = $x - 13
		 $yReal = $y + 168
		 $Xaux = 90
		 $Yaux = 22
		 randomClick($xReal,$yReal,$Xaux,$Yaux)
		 _ConsoleWrite('Elixirs Used!' & @CRLF)
		 If checkForImageT($used,$wtl,$bot_instance) Then
			_ConsoleWrite('Ok Used!' & @CRLF)
			clickOk($bot_instance)
		 ElseIf checkForImageT($used,$wtl,$bot_instance) Then	;w8 a bit longer, sometimes it bypasses it
			_ConsoleWrite('Ok Used 2!' & @CRLF)
			clickOk($bot_instance)
		 EndIf
	  EndIf
   EndIf
EndFunc

Func combatFailed($bot_instance)
   If checkForImage($salutecombat,$bot_instance) or checkForImage($acceptsalute,$bot_instance) Then
	  _ConsoleWrite('Combat Has Failed!!' & @CRLF)
	  If not $combatFailedSent Then
		 sendTelegramMessage('COMBAT FAILED!!')
		 $combatFailedSent = True
	  EndIf
	  Return 1
   EndIf
   Return 0
EndFunc

;####	BAN AVOIDING FUNCTIONS	####
Func checkVerification()
   If checkForImage($verification) or checkForImage($verification2) or checkForImage($verification3)  Then
	  $verificationNeeded = 1
	  _ConsoleWriteError('-	VERIFICATION DIALOG TRIGGERED!' & @CRLF)
	  sendTelegramMessage('VERIFICATION DIALOG TRIGGERED!!!')
	  Local $hFilecheck = FileOpen(@ScriptDir & "\Log_verification.log", 1)
	  _FileWriteLog($hFilecheck, _NowTime() & ' ' & '-	VERIFICATION DIALOG TRIGGERED!')
	  ;Sleep(5400000)			; 90 minutes
	  screenShotVerification()
	  telegramVerification()
	  Return 1
	  ;Exit (1)
   EndIf
   Return 0
EndFunc

Func screenShotVerification()
   For $i = 0 To $gameInstances-1
	  If $granblue_windows[$i][0] <> 0 Then
		 If FileExists(@ScriptDir & "\screen\" & "\verif_"&$i&".jpg") Then
			FileDelete(@ScriptDir & "\screen\" & "\verif_"&$i&".jpg")
		 EndIf
		 _ScreenCapture_CaptureWnd(@ScriptDir & "\screen\" & "\verif_"&$i&".jpg", $granblue_windows[$i][0])
	  EndIf
   Next
EndFunc

Func verifyInstance($bot_instance,$vtext)
   activateGBWindow($bot_instance)
   Sleep(50)
   ControlSend($granblue_windows[$bot_instance][0], "", "", "{TAB}")
   ControlSend($granblue_windows[$bot_instance][0], "", "", $vtext)
   If checkForImage($sendVerification,$bot_instance) or checkForImage($sendVerification2,$bot_instance) Then
	  _ConsoleWrite('Verifying...' & @CRLF)
	  $Xaux = 48
	  $Yaux = 22
	  randomClick($x,$y,$Xaux,$Yaux)
   EndIf
   Sleep(2000)
   $verificationNeeded = 0
   Return 1
EndFunc

Func randomClick($xLeft,$yTop,$xOff,$yOff,$clicktimes=1)
   ;activateGBWindow()			;Make sure the window is active.
   $xRight = $xLeft+$xOff
   $yBottom = $yTop+$yOff
   ;_ConsoleWrite('ClickTimes: ' & $clicktimes & @CRLF)
   ;_ConsoleWrite('x:' & $xLeft & ' ' & $xRight & @CRLF)
   ;_ConsoleWrite('y:' & $yTop & ' ' & $yBottom & @CRLF)
   Sleep(Random(0,500,1))																	;sleeps from 0 to 0.2 seconds on each mouse click
   MouseClick("left", Random($xLeft,$xRight,1), Random($yTop,$yBottom,1), $clicktimes)		;clicks randomly on a box given the values from the image recognition + a value
   ;ControlClick($hwnd,"",$controlID,"left", $clicktimes, Random($xLeft,$xRight,1), Random($yTop,$yBottom,1))	;test background clicking
EndFunc

Func randomMove($xLeft,$yTop,$xOff,$yOff,$clicktimes=1)
   ;activateGBWindow()			;Make sure the window is active.
   $xRight = $xLeft+$xOff
   $yBottom = $yTop+$yOff

   Sleep(Random(0,500,1))																	;sleeps from 0 to 0.2 seconds on each mouse click
   MouseMove(Random($xLeft,$xRight,1), Random($yTop,$yBottom,1))
EndFunc