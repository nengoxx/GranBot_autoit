#include-once

Func rewardRoom($bot_instance,$skipLooting=True)
   ;_ConsoleWrite('Checking rewards...' & @CRLF)
   If checkForImage($returnto_quests,$bot_instance) or checkForImage($returnto_quests2,$bot_instance) or checkForImage($returnto_quests3,$bot_instance) or checkForImage($returnto_pending,$bot_instance) Then			;click to go to room
	  _ConsoleWrite('Returning to Quests Menu...' & @CRLF)
	  $xReal = $x
	  $yReal = $y
	  $Xaux = 147
	  $Yaux = 27
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  _resetTime_bi($bot_instance)
	  resetAttack()
	  Sleep(1500) ;let it trigger the friend request, it will just click ok otherwise
   EndIf
   ;TODO rare loot

;~    coop stuff
   If checkForImage($expgained,$bot_instance) Then
	  If $skipLooting Then
		 If $bot_coop ==1 Then
			clickBack($bot_instance)
		 Else
			restartGame($bot_instance)
		 EndIf
	  Else
		 clickOk($bot_instance)
	  EndIf
   EndIf
   If checkForImage($skilllearned,$bot_instance) Then
	  clickOk($bot_instance)
   EndIf
   If checkForImage($newloot,$bot_instance) Then
	  clickOk($bot_instance)
   EndIf
   If checkForImage($closequest,$bot_instance) Then				;click to go to room
	  _ConsoleWrite('Closing Quest Dialog...' & @CRLF)
	  $xReal = $x
	  $yReal = $y
	  $Xaux = 146
	  $Yaux = 26
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
   EndIf
   If checkForImage($backtoroom,$bot_instance) Then				;click to go to room
	  _ConsoleWrite('Returning to Room...' & @CRLF)
	  $xReal = $x
	  $yReal = $y
	  $Xaux = 147
	  $Yaux = 29
	  randomClick($xReal,$yReal,$Xaux,$Yaux)
	  _resetTime_bi($bot_instance)
	  resetAttack()
   EndIf
   If checkForImage($friendreq,$bot_instance) Then
	  If checkForImage($cancelfriend,$bot_instance) Then			;click to go to room
		 _ConsoleWrite('Cancelling Friend Requests...' & @CRLF)
		 $xReal = $x
		 $yReal = $y
		 $Xaux = 147
		 $Yaux = 27
		 randomClick($xReal,$yReal,$Xaux,$Yaux)
		 _resetTime_bi($bot_instance)
	  EndIf
   EndIf
EndFunc