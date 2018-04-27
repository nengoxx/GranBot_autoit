#include "Telegram UDF.au3"

#cs========================================================================
$msgData[0] = Offset of the current update (used to 'switch' to next update)
$msgData[1] = Username of the user
$msgData[2] = ChatID used to interact with the user
$msgData[3] = Text of the message
#ce========================================================================

Local $ChatID = ""
_InitBot("","")

;ConsoleWrite("Test _GetUpdates   -> "  & @TAB & _GetUpdates() & @CRLF)
;ConsoleWrite("Test _GetMe        -> "  & @TAB & _GetMe() & @CRLF)

;ConsoleWrite("Test _SendMsg      -> "  & @TAB & _SendMsg($ChatID,"bot Started") & @CRLF)
;ConsoleWrite("Test _GetChat      -> " & @TAB & _GetChat($ChatID) & @CRLF)
;ConsoleWrite("Test _SendPhoto    -> "  & @TAB & _SendPhoto($ChatID,"C:\image.jpg","Test _SendPhoto") & @CRLF)


Local $lastCommand = 0


Func sendTelegramMessage($m)
   ;_onlineWait()
   _SendMsg($ChatID,$m)
EndFunc

Func telegramVerification()
   ;_onlineWait()
   For $i = 0 to $gameInstances-1
	  _SendPhoto($ChatID,@ScriptDir & "\screen\" & "\verif_"&$i&".jpg"," instance "&$i)
   Next
   If waitVerification() Then
	  _SendMsg($ChatID,"verification succeeded!")
   EndIf
EndFunc

Func waitVerification()
   While 1
   ;_onlineWait()
   $msgData = _Polling()
   If (@error) Then ContinueLoop
   ;ConsoleWrite($msgData[0]&' '&$lastCommand&' '& $msgData[3]&' '& $msgData[1]& @CRLF)
   If $msgData[0] <> $lastCommand and $msgData[1] == "_USERNAME_CHANGE_ME" Then
	  If checkCommand($msgData[3]) Then
		 Return 1
	  EndIf
   EndIf
   $lastCommand = $msgData[0]
   WEnd
   Return 0 ;unreachable
EndFunc

Func getCommand()
   ;_onlineWait()
   $msgData = _PollingSingle()
   If (@error) Then Return 0
   If UBound($msgData) <> 4 Then Return 0
   If $lastCommand <> 0 and $msgData[0] <> $lastCommand and $msgData[1] == "_USERNAME_CHANGE_ME" Then
	  If checkCommand($msgData[3]) Then
		 Return 1
	  EndIf
   EndIf
   $lastCommand = $msgData[0]
   Return 0
EndFunc

Func checkCommand($command)
	  If $verificationNeeded == 1 and StringRegExp($command,"[0-9]_\w") Then			;verify
		 Local $splitverify = StringSplit($command,'_')
		 ;ConsoleWrite($ccommand & ' - ' & $splitverify[0] & ' ' & $splitverify[1]& @CRLF)
		 If $splitverify[0] == 2 and (Int($splitverify[1]) < $gameInstances) Then
			Return verifyInstance(Int($splitverify[1]),$splitverify[2])
		 Else
			_SendMsg($ChatID,"wrong verification number!")
			Return 0
		 EndIf
	  EndIf

	  ;more commands
	  If $command == "/screen" Then
		 For $i = 0 to $gameInstances-1
			If FileExists(@ScriptDir & "\screen\" & "\verif_"&$i&".jpg") Then
			   FileDelete(@ScriptDir & "\screen\" & "\verif_"&$i&".jpg")
			EndIf
			_ScreenCapture_CaptureWnd(@ScriptDir & "\screen\" & "\verif_"&$i&".jpg", $granblue_windows[$i][0])
			_SendPhoto($ChatID,@ScriptDir & "\screen\" & "\verif_"&$i&".jpg"," instance "&$i)
		 Next
		 If $verificationNeeded == 1 Then
			Return 0
		 Else
			Return 1
		 EndIf
	  EndIf

	  ;ONLY THE ABOVE COMMANDS ARE AVAILABLE WHEN VERIFICATION IS TRIGGERED
	  If $verificationNeeded == 1 Then
		 _SendMsg($ChatID,"verification is needed!")
		 Return 0
	  EndIf

	  ;bot management commands
	  If $command == "/bots" Then
		 _SendMsg($ChatID,'Raid Snipe: '&$bot_raidSnipe)
		 _SendMsg($ChatID,'TweetDeck: '&$bot_tweetdeck)
		 _SendMsg($ChatID,'Co-op: '&$bot_coop)
		 _SendMsg($ChatID,'Angel Halo: '&$bot_angelHalo)
		 Return 1
	  EndIf

	  If $command == "/config" Then
		 _SendMsg($ChatID,'Use elixirs/berries/Bberries: '&$use_elixirs&'/'&$use_berries&'/'&$use_Bberries)
		 _SendMsg($ChatID,'Join Pandemonium: '&$join_pandemonium)
		 _SendMsg($ChatID,'Raid EP: '&$neededEP)
		 Return 1
	  EndIf

	  If $command == "/berries" Then
		 If $use_berries == 0 or not $use_berries Then
			$use_berries = 1
			_SendMsg($ChatID,'using berries')
		 Else
			$use_berries = 0
			_SendMsg($ChatID,'not using berries')
		 EndIf
		 Return 1
	  EndIf

	  If $command == "/elixirs" Then
		 If $use_elixirs == 0 or not $use_elixirs Then
			$use_elixirs = 1
			_SendMsg($ChatID,'using elixirs')
		 Else
			$use_elixirs = 0
			_SendMsg($ChatID,'not using elixirs')
		 EndIf
		 Return 1
	  EndIf

	  If $command == "/switchfarm" Then
		 $angelHaloStage = -3
		 ;_SendMsg($ChatID,'switching quest type from ' & $farmQuestType)
		 If $farmQuestType > 2 Then	;if its 3 or more don't add 1, instead reset to 0
			$farmQuestType = 0
		 Else
			$farmQuestType = $farmQuestType + 1
		 EndIf
		 ;_SendMsg($ChatID,'to ' & $farmQuestType)
		 If $farmQuestType = 0 Then
			_SendMsg($ChatID,'farming angel halo')
		 ElseIf $farmQuestType = 1 Then
			_SendMsg($ChatID,'farming favorite quest')
		 ElseIf $farmQuestType = 2 Then
			_SendMsg($ChatID,'farming daily showdowns')
		 ElseIf $farmQuestType = 3 Then
			_SendMsg($ChatID,'farming GW Ex+')
		 Else
			_SendMsg($ChatID,'switchfarm error')
		 EndIf
		 Return 1
	  EndIf

	  If StringRegExp($command,"/ep\h[0-9]") Then
		 Local $splitcommand = StringSplit($command,' ')
		 If $splitcommand[0] == 2 Then
			$neededEP = Int($splitcommand[2])
			_SendMsg($ChatID,"ep needed changed to: " & Int($splitcommand[2]))
		 Else
			_SendMsg($ChatID,"wrong ep command!")
			Return 0
		 EndIf
		 Return 1
	  EndIf
	  If $command == "/raidf_r" Then
		 $raidSnipeStage = -3
		 _SendMsg($ChatID,'restarting raidfinder bot...')
		 Return 1
	  EndIf

	  If $command == "/coop" Then
		 If $bot_coop == 0 Then
			If getBotAmount() < $gameInstances Then
			   $bot_coop = 1
			   _SendMsg($ChatID,'co-op bot started')
			Else
			   _SendMsg($ChatID,'not enough game instances!')
			EndIf
		 Else
			$bot_coop = 0
			_SendMsg($ChatID,'co-op bot stopped')
		 EndIf
		 Return 1
	  EndIf
	  If $command == "/coop_pan" Then
		 If $join_pandemonium == 0 Then
			$join_pandemonium = 1
			_SendMsg($ChatID,'pandemonium rooms enabled')
		 Else
			$join_pandemonium = 0
			_SendMsg($ChatID,'pandemonium rooms disabled')
		 EndIf
		 setCoopRoomSelectionImages()
		 Return 1
	  EndIf
	  If $command == "/coop_leave" Then
		 $leave_room = 1
		 _SendMsg($ChatID,'leaving co-op room...')
		 Return 1
	  EndIf
	  If $command == "/coop_r" Then
		 $coopStage = -3
		 _SendMsg($ChatID,'restarting co-op bot...')
		 Return 1
	  EndIf

	  If $command == "/angel" Then
		 If $bot_angelHalo == 0 Then
			If getBotAmount() < $gameInstances Then
			   $bot_angelHalo = 1
			   _SendMsg($ChatID,'angel halo bot started')
			Else
			   _SendMsg($ChatID,'not enough game instances!')
			EndIf
		 Else
			$bot_angelHalo = 0
			_SendMsg($ChatID,'angel halo bot stopped')
		 EndIf
		 Return 1
	  EndIf

	  If $command == "/pause" Then
		 If $Paused Then
			$Paused = Not $Paused
			_SendMsg($ChatID,'bot unpaused')
		 Else
			_SendMsg($ChatID,'bot paused')
			TogglePause()
		 EndIf
		 Return 1
	  EndIf

	  If $command == "/reboot" Then
		 Shutdown(6)
		 Return 1
	  EndIf

	  ;unrecognized commands
	  If $command <> "" Then
		 _SendMsg($ChatID,"wrong command! "&$command)
	  EndIf
	  Return 0
EndFunc