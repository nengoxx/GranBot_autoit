#include "_Coop.au3"
#include "_AngelHalo.au3"
#include "_RaidFinderSnipe.au3"
#include "_4Beasts.au3"
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

Sleep(2000)
While 1
   If $bot_raidSnipe == 1 Then
	  If $bot_4beast == 1 Then
		 checkState_4b()
	  Else
		 checkState_rfs()
	  EndIf
   EndIf
   If $bot_coop == 1 and $gameInstances > 1 Then
	  checkState_c()
   EndIf
   If $bot_angelHalo == 1 and $gameInstances > 1 Then
	  checkState_ah()
   EndIf
WEnd

Func getBotAmount()
   Return Int($bot_raidSnipe)+Int($bot_tweetdeck)+Int($bot_coop)+Int($bot_angelHalo)
EndFunc