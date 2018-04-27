#include-once

Local $spamTime = 10000					;max spam time for raid sniping ingame(4beasts)
Local $spamMidTime = 30000				;middle spam time to wait for a raid to low its ep requiremets
Local $spamLongTime = 90000				;max spam time to wait for a raid to show up ingame(4beatst)

Local $errorTime = 30000 ;15000			;10 seconds to trigger error and reload
Local $errorOffset = 15000 ;5000
Local $idleTime = 1000000				;time to wait for EP(~20min)
Local $idleOffset = 120000
Local $attackIdleTime = 240000
Local $attackIdleOffset = 120000

Global $wt = 2500		;generic wait time
Global $wtl = 5000		;longerwait time

Local $hTime = 0
Local $hTime2 = 0

Local $max_bot_timers = 5
Local $botTimers[$max_bot_timers] = [0,0,0,0,0]

;# Timers ------------------------------------------------------------------------------------------------------
;~ Local Timer to use in the whole bot
#cs
Func _onTime($s)
   If $hTime = 0 Then
	  $hTime = TimerInit()
   EndIf
   If $hTime > 0 And TimerDiff($hTime) <= $s Then
	  Return 1
   EndIf
   Return 0
EndFunc

Func _getTime()
   Return TimerDiff($hTime)
EndFunc

Func _resetTime()
   $hTime = 0
EndFunc
#ce

;~ Generic Bot Instance timer
Func _onTime_bi($s,$bi)
   getCommand()	;get telegram commands each time it checks the timer

   If $botTimers[$bi] = 0 Then
	  $botTimers[$bi] = TimerInit()
   EndIf
   If TimerDiff($botTimers[$bi]) > 0 And TimerDiff($botTimers[$bi]) <= $s Then
	  Return 1
   EndIf
   ;ConsoleWrite('Time Run Out: ' &$bi&' '&$botTimers[$bi]&' - '&$botTimers[0]&' '&$botTimers[1]&' '&$botTimers[2]&' '&$botTimers[3] & @CRLF)
   Return 0
EndFunc

Func _getTime_bi($bi)
   Return TimerDiff($botTimers[$bi])
EndFunc

Func _resetTime_bi($bi)
   $botTimers[$bi] = 0
EndFunc

;~ Second Timer that won't interfere with the 1st one
Func _onTime2($s)
   If $hTime2 = 0 Then
	  $hTime2 = TimerInit()
   EndIf
   If $hTime2 > 0 And TimerDiff($hTime2) <= $s Then
	  Return 1
   EndIf
   Return 0
EndFunc

Func _getTime2()
   Return TimerDiff($hTime2)
EndFunc

Func _resetTime2()
   $hTime2 = 0
EndFunc

;# Specific Bot Timers -----------------------------------------------------------------------------------------

;# Randomizer functions ----------------------------------------------------------------------------------------
Func getIdleTime()
   Return Random($idleTime-$idleOffset,$idleTime,1)
EndFunc

Func getAttackIdleTime()
   Return Random($attackIdleTime-$attackIdleOffset,$attackIdleTime,1)
EndFunc

Func getErrorTime()
   Return Random($errorTime-$errorOffset,$errorTime,1)
EndFunc

Func getSpamTime($t)
   Local $spamOffset = 5000
   If $t = 0 Then
	  $spamOffset = 5000
	  Return Random($spamTime-$spamOffset,$spamTime,1)
   ElseIf $t = 1 Then
	  $spamOffset = 15000
	  Return Random($spamMidTime-$spamOffset,$spamMidTime,1)
   ElseIf $t = 2 Then
	  $spamOffset = 15000
	  Return Random($spamLongTime-$spamOffset,$spamLongTime,1)
   EndIf
EndFunc